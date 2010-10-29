require 'bert'
require 'bert/decode' # use the pure-Ruby decoder

module BERT
  ##
  # Extensions for the BERT type constants.
  module Types
    # @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#NEW_FLOAT_EXT
    NEW_FLOAT = 70
  end # Types

  ##
  # Extensions for the BERT encoder.
  class Encode
    include Types

    # @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#NEW_FLOAT_EXT
    def write_new_float(float)
      write_1 NEW_FLOAT
      out.write([float].pack('G')) # 8 bytes, big-endian IEEE format
    end
    alias_method :write_float, :write_new_float # use by default

    # @see http://github.com/mojombo/bert/pull/10
    alias_method :write_any_raw_without_to_bert, :write_any_raw
    def write_any_raw(obj)
      obj = obj.to_bert if obj.respond_to?(:to_bert)
      write_any_raw_without_to_bert(obj)
    end
  end # Encode

  ##
  # Extensions for the BERT decoder.
  class Decode
    include Types

    # @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#NEW_FLOAT_EXT
    def read_new_float
      fail("Invalid Type, not a float") unless read_1 == NEW_FLOAT
      read_string(8).unpack('G').first
    end

    alias_method :read_any_raw_without_new_float, :read_any_raw
    def read_any_raw
      case peek_1
        when NEW_FLOAT then read_new_float
        else read_any_raw_without_new_float
      end
    end
  end # Decode
end # BERT
