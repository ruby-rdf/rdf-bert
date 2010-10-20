module RDF; module BERT
  ##
  class Server
    def self.run(repository = nil, options = {})
      require 'eventmachine' unless defined?(::EM)

      ::EM.run do
        self.start(repository, options)
      end
    end

    def self.start(repository = nil, options = {})
      self.start_with_bertrem(repository, options)
    end

    ##
    # @see https://rubygems.org/gems/bertrem
    def self.start_with_bertrem(repository = nil, options = {})
      require 'bertrem' unless defined?(::BERTREM)

      host = options[:host] || '0.0.0.0'
      port = options[:port] || DEFAULT_PORT

      EM.run do
        server = self.new(repository)
        BERTREM::Server.mod(:rdf, lambda do
          self.public_instance_methods(false).each do |method_name|
            BERTREM::Server.fun(method_name.to_sym, server.method(method_name.to_sym))
          end
        end)
        BERTREM::Server.start(host, port)
      end
    end

    ##
    # @see https://rubygems.org/gems/ernie
    def self.start_with_ernie(repository = nil, options = {})
      require 'ernie' unless defined?(::Ernie)

      server = self.new(repository)
      Ernie.mod(:rdf, lambda do
        self.public_instance_methods(false).each do |method_name|
          Ernie.fun(method_name.to_sym, server.method(method_name.to_sym))
        end
      end)
    end

    ##
    # @param  [RDF::Repository] repository
    def initialize(repository = nil, options = {})
      @repository = repository || RDF::Repository.new
      @options    = options.dup
    end

    ##
    # @private
    # @return [Array]
    def version
      return RDF::BERT::VERSION.to_a
    end

    ##
    # @return [Array]
    def contexts
      @repository.contexts.map { |value| RDF::BERT.serialize(value) }
    end

    ##
    # @return [Array]
    def subjects(*contexts)
      if contexts.empty?
        @repository.subjects.map { |value| RDF::BERT.serialize(value) }
      else
        raise NotImplementedError, 'rdf:subjects' # TODO: support named graphs
      end
    end

    ##
    # @return [Array]
    def predicates(*contexts)
      if contexts.empty?
        @repository.predicates.map { |value| RDF::BERT.serialize(value) }
      else
        raise NotImplementedError, 'rdf:predicates' # TODO: support named graphs
      end
    end

    ##
    # @return [Boolean]
    def empty?(*contexts)
      if contexts.empty?
        return @repository.empty?
      else
        raise NotImplementedError, 'rdf:empty?' # TODO: support named graphs
      end
    end

    ##
    # @return [Integer]
    def count(*contexts)
      if contexts.empty?
        return @repository.count
      else
        raise NotImplementedError, 'rdf:count' # TODO: support named graphs
      end
    end

    ##
    # @return [Boolean]
    def clear(*contexts)
      if contexts.empty?
        @repository.clear
      else
        contexts.map! { |context| RDF::BERT.unserialize(context) }
        raise NotImplementedError, 'rdf:clear' # TODO: support named graphs
      end
      return true
    end

    ##
    # @param  [Object] context
    # @return [Boolean]
    def exist?(context, *triples)
      context = RDF::BERT.unserialize(context)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize(triple)
            statement.context = context if context
            return false unless @repository.has_statement?(statement)
          else
            return false # TODO: support triple identifiers
        end
      end
      return true
    end

    ##
    # @param  [Object] context
    # @return [Array]
    def known?(context, *triples)
      return triples.map do |triple|
        case triple
          when Array then exist?(context, triple)
          else false # TODO: support triple identifiers
        end
      end
    end

    ##
    # @param  [Object] context
    # @return [Array]
    def query(context, *patterns)
      result  = []
      context = RDF::BERT.unserialize(context)
      patterns.each do |pattern|
        pattern = RDF::BERT.unserialize(pattern)
        pattern.context = context if context
        @repository.query(pattern) do |statement|
          result << statement # FIXME
        end
      end
      return result
    end

    ##
    # @param  [Object] context
    # @return [Boolean]
    def insert(context, *triples)
      context = RDF::BERT.unserialize(context)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize(triple)
            statement.context = context if context
            @repository.insert(statement)
        end
      end
      return true
    end

    ##
    # @param  [Object] context
    # @return [Boolean]
    def delete(context, *triples)
      context = RDF::BERT.unserialize(context)
      triples.each do |triple|
        case triple
          when Array
            statement = RDF::BERT.unserialize(triple)
            statement.context = context if context
            @repository.delete(statement)
          else # TODO: support triple identifiers
        end
      end
      return true
    end
  end
end; end
