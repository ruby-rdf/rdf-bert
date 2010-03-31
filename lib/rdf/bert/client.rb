module RDF; module BERT
  ##
  class Client < RDF::Repository
    ##
    def initialize(url_or_options = {})
      host = url_or_options[:host] || 'localhost'
      port = url_or_options[:port] || 9999
      @server = BERTRPC::Service.new(host, port)
    end

    ##
    # Returns `true` if this repository contains no RDF statements.
    #
    # @return [Boolean]
    # @see    RDF::Enumerable#empty?
    def empty?
      @server.call.rdf.empty?
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    # @see    RDF::Enumerable#count
    def count
      @server.call.rdf.count
    end

    ##
    # Returns `true` if this repository contains the given RDF statement.
    #
    # @param  [Statement] statement
    # @return [Boolean]
    # @see    RDF::Enumerable#has_statement?
    def has_statement?(statement)
      @server.call.rdf.exist?(*RDF::BERT.serialize_statement(statement))
    end

    ##
    # Enumerates each RDF statement in this repository.
    #
    # @yield  [statement]
    # @yieldparam [Statement] statement
    # @return [Enumerator]
    # @see    RDF::Enumerable#each_statement
    def each(&block)
      graphs = [nil] + @server.call.rdf.graphs
      graphs.each do |graph|
        context = RDF::BERT.unserialize_value(graph)
        triples = @server.call.rdf.query(graph, [nil, nil, nil])
        triples.each do |triple|
          statement = RDF::BERT.unserialize_statement(triple)
          statement.context = context
          block.call(statement)
        end
      end
    end

    ##
    # Inserts the given RDF statement into the underlying storage.
    #
    # @param  [RDF::Statement] statement
    # @return [void]
    def insert_statement(statement)
      @server.cast.rdf.insert(*RDF::BERT.serialize_statement(statement))
    end

    ##
    # Deletes the given RDF statement from the underlying storage.
    #
    # @param  [RDF::Statement] statement
    # @return [void]
    def delete_statement(statement)
      @server.cast.rdf.delete(*RDF::BERT.serialize_statement(statement))
    end

    ##
    # Deletes all RDF statements from this repository.
    #
    # @return [void]
    # @see    RDF::Mutable#clear
    def clear_statements
      @server.cast.rdf.clear
    end

    ##
    # Queries `self` for RDF statements matching the given pattern.
    #
    # @example
    #     queryable.query([nil, RDF::DOAP.developer, nil])
    #     queryable.query(:predicate => RDF::DOAP.developer)
    #
    # @param  [Query, Statement, Array(Value), Hash] pattern
    # @yield  [statement]
    # @yieldparam [Statement]
    # @return [Array<Statement>]
    def query(pattern, &block)
      case pattern
        when Hash       then query(Statement.new(pattern), &block)
        when Array      then query(Statement.new(*pattern), &block)
        when RDF::Statement
          results = []
          graphs = [nil] + @server.call.rdf.graphs
          graphs.each do |graph|
            context = RDF::BERT.unserialize_value(graph)
            triples = @server.call.rdf.query(graph, RDF::BERT.serialize_triple(pattern.to_triple))
            triples.each do |triple|
              statement = RDF::BERT.unserialize_statement(triple)
              statement.context = context
              if block_given?
                block.call(statement)
              else
                results << statement
              end
            end
          end
          results.extend(RDF::Enumerable, RDF::Queryable)
        else super
      end
    end
  end
end; end
