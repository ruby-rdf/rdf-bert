require 'bertrpc'
require 'rdf'
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
        when Array      then RDF::Statement(*value).to_bert
        when RDF::Value then value.to_bert
        else RDF::Literal(value, options).to_bert
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
      case value
        when :f, :t, FalseClass, TrueClass, Integer, Float
          RDF::Literal(value)
        when Array, ::BERT::Tuple
          case tag = value.first
            when :'3' then RDF::Statement(*value[1..3].map { |term| unserialize(term) })
            when :'4' then RDF::Statement(*value[1..3].map { |term| unserialize(term) }, :context => unserialize(value[4])) # FIXME on Ruby 1.8
            when :'?' then RDF::Query::Variable.new(value[1])
            when :':' then RDF::Node(value[1])
            when :'<' then RDF::URI(value[1])
            when :'"' then RDF::Literal(value[1])
            when :'@' then RDF::Literal(value[1], :language => value[2])
            when :'^' then RDF::Literal(value[1], :datatype => value[2])
          end
        else
          raise ArgumentError, "invalid RDF/BERT value: #{value.inspect}"
      end
    end
  end
end
