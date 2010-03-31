module RDF; module BERT
  ##
  class Server
    def self.start(host = 'localhost', port = 9999)
      require 'eventmachine' unless defined?(::EM)
      require 'bertrem' unless defined?(::BERTREM)

      EM.run do
        server = self.new(RDF::Repository.new)
        BERTREM::Server.mod(:rdf, lambda do
          self.public_instance_methods(false).each do |method_name|
            BERTREM::Server.fun(method_name.to_sym, server.method(method_name.to_sym))
          end
        end)
        BERTREM::Server.start(host, port)
      end
    end

    def initialize(repository, options = {})
      @repository = repository
      @options    = options.dup
    end

    ##
    # @private
    def version
      return RDF::BERT::VERSION.to_a
    end

    ##
    def graphs
      @repository.contexts.map { |value| RDF::BERT.serialize_value(value) }
    end

    ##
    def subjects(*graphs)
      @repository.subjects.map { |value| RDF::BERT.serialize_value(value) } # FIXME: support named graphs
    end

    ##
    def predicates(*graphs)
      @repository.predicates.map { |value| RDF::BERT.serialize_value(value) } # FIXME: support named graphs
    end

    ##
    def empty?(*graphs)
      if graphs.empty?
        return @repository.empty?
      else
        raise NotImplementedError.new('rdf:empty?') # TODO: support named graphs
      end
    end

    ##
    def count(*graphs)
      if graphs.empty?
        return @repository.count
      else
        raise NotImplementedError.new('rdf:count') # TODO: support named graphs
      end
    end

    ##
    def clear(*graphs)
      case
        when graphs.empty?
          @repository.clear
        else
          graphs.each do |graph|
            context = RDF::BERT.unserialize_value(graph)
          end
          raise NotImplementedError.new('rdf:clear') # TODO: support named graphs
      end
      return true
    end

    ##
    def exist?(graph, *triples)
      context = RDF::BERT.unserialize_value(graph)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize_statement(triple)
            statement.context = context if context
            return false unless @repository.has_statement?(statement)
          else
            return false # TODO: support triple identifiers
        end
      end
      return true
    end

    ##
    def known?(graph, *triples)
      return triples.map do |triple|
        case triple
          when Array then exist?(graph, triple)
          else false # TODO: support triple identifiers
        end
      end
    end

    ##
    def query(graph, *patterns)
      result  = []
      context = RDF::BERT.unserialize_value(graph)
      patterns.each do |pattern|
        @repository.query(RDF::BERT.unserialize_triple(pattern)) do |statement|
          if statement.context == context
            result << RDF::BERT.serialize_triple(statement.to_triple)
          end
        end
      end
      return result
    end

    ##
    def insert(graph, *triples)
      context = RDF::BERT.unserialize_value(graph)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize_statement(triple)
            statement.context = context if context
            @repository.insert(statement)
        end
      end
      return true
    end

    ##
    def delete(graph, *triples)
      context = RDF::BERT.unserialize_value(graph)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize_statement(triple)
            statement.context = context if context
            @repository.delete(statement)
        end
      end
      return true
    end
  end
end; end
