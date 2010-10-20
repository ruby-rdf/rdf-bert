module RDF; module BERT
  ##
  class Client < RDF::Repository
    ##
    def initialize(url_or_options = {})
      host = url_or_options[:host] || 'localhost'
      port = url_or_options[:port] || DEFAULT_PORT
      @server = BERTRPC::Service.new(host, port)
    end

    ##
    # @private
    def supports?(feature)
      case feature.to_sym
        when :context then true  # statement contexts / named graphs
        else super
      end
    end

    ##
    # @private
    def empty?
      @server.call.rdf.empty?
    end

    ##
    # @private
    def count
      @server.call.rdf.count
    end

    ##
    # @private
    def has_statement?(statement)
      @server.call.rdf.exist?(RDF::BERT.serialize(statement))
    end

    ##
    # @private
    def each_statement(&block)
      if block_given?
        contexts = [nil] + @server.call.rdf.contexts
        contexts.each do |context|
          triples = @server.call.rdf.query(context, RDF::BERT.serialize([nil, nil, nil]))
          context = RDF::BERT.unserialize(context)
          triples.each do |triple|
            statement = RDF::BERT.unserialize(triple)
            statement.context = context
            block.call(statement)
          end
        end
      end
      enum_statement
    end
    alias_method :each, :each_statement

  protected

    ##
    # @private
    def insert_statement(statement)
      @server.cast.rdf.insert(nil, RDF::BERT.serialize(statement)) # FIXME
    end

    ##
    # @private
    def delete_statement(statement)
      @server.cast.rdf.delete(nil, RDF::BERT.serialize(statement)) # FIXME
    end

    ##
    # @private
    def clear_statements
      @server.cast.rdf.clear
    end

    ##
    # @private
    def query_pattern(pattern, &block)
      contexts = [nil] + @server.call.rdf.contexts
      contexts.each do |context|
        triples = @server.call.rdf.query(context, RDF::BERT.serialize(pattern))
        context = RDF::BERT.unserialize(context)
        triples.each do |triple|
          statement = RDF::BERT.unserialize(triple)
          statement.context = context
          block.call(statement)
        end
      end
    end
  end
end; end
