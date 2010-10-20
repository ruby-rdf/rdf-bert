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
    def self.encode(value, options = {})
      ::BERT.encode(serialize(value, options))
    end

    ##
    def self.serialize(value, options = {})
      case value
        when Array
          serialize_triple(value)
        when RDF::Statement
          serialize_statement(value)
        when RDF::Value
          serialize_value(value)
        else
          serialize_value(RDF::Literal.new(value, options))
      end
    end

    ##
    def self.serialize_statement(statement)
      [serialize_value(statement.context), serialize_triple(statement.to_triple)]
    end

    ##
    def self.serialize_triple(triple)
      triple.map { |value| serialize_value(value) }
    end

    ##
    def self.serialize_value(value)
      RDF::NTriples::Writer.serialize(value)
    end

    ##
    def self.decode(data)
      unserialize(::BERT.decode(data))
    end

    ##
    def self.unserialize(value)
      case value
        when Array
          unserialize_triple(value)
        else
          unserialize_value(value)
      end
    end

    ##
    def self.unserialize_statement(triple, options = {})
      RDF::Statement.new(*(unserialize_triple(triple) + [options]))
    end

    ##
    def self.unserialize_triple(triple)
      triple.map { |value| unserialize_value(value) }
    end

    ##
    def self.unserialize_value(value)
      value ? RDF::NTriples::Reader.unserialize(value) : nil # TODO: fixed in RDF.rb 0.1.4
    end
  end
end
