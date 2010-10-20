require 'rdf'
require 'rdf/ntriples'
require 'bertrpc'
require 'rdf/bert/extensions'

module RDF
  module BERT
    autoload :Client,  'rdf/bert/client'
    autoload :Server,  'rdf/bert/server'
    autoload :VERSION, 'rdf/bert/version'

    ##
    # @param  [String] value
    # @return [String]
    def self.encode(value, options = {})
      ::BERT.encode(serialize(value, options))
    end

    ##
    # @param  [Object] value
    # @return [String]
    def self.serialize(value, options = {})
      case value
        when Array      then RDF::Statement.new(*value).to_bert
        when RDF::Value then value.to_bert
        else RDF::Literal.new(value, options).to_bert
      end
    end

    ##
    # @param  [String] data
    # @return [RDF::Value]
    def self.decode(data)
      unserialize(::BERT.decode(data))
    end

    ##
    # @param  [Object] value
    # @return [RDF::Value]
    def self.unserialize(value)
      raise NotImplementedError, "RDF/BERT unserialization not yet implemented" # TODO
    end
  end
end
