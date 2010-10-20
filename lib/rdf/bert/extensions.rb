##
# RDF/BERT extensions for RDF values.
module RDF::Value
  def to_bert
    raise NotImplementedError, "#{self.class}#to_bert"
  end
end

##
# RDF/BERT extensions for statements.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html
class RDF::Statement
  def to_bert
    if has_context?
      BERT::Tuple[:'4', *to_quad.map(&:to_bert)]
    else
      BERT::Tuple[:'3', *to_triple.map(&:to_bert)]
    end
  end
end

##
# RDF/BERT extensions for variables.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html
class RDF::Query::Variable
  def to_bert
    BERT::Tuple[:'?', to_sym]
  end
end

##
# RDF/BERT extensions for blank nodes.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html
class RDF::Node
  def to_bert
    BERT::Tuple[:':', to_sym]
  end
end

##
# RDF/BERT extensions for URIs.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html
class RDF::URI
  def to_bert
    BERT::Tuple[:'<', to_s]
  end
end

##
# RDF/BERT extensions for RDF literals.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html
class RDF::Literal
  def to_bert
    case
      when plain?    then BERT::Tuple[:'"', to_s]
      when language? then BERT::Tuple[:'@', to_s, language.to_sym]
      when datatype? then BERT::Tuple[:'^', to_s, datatype.to_s]
    end
  end
end

##
# RDF/BERT extensions for boolean literals.
#
# Note: booleans are not encoded as BERT booleans (which are comparatively
# inefficient), but rather simply as one-character atoms.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#SMALL_ATOM_EXT
class RDF::Literal::Boolean
  def to_bert
    true? ? :t : :f
  end
end

##
# RDF/BERT extensions for integer literals.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#SMALL_INTEGER_EXT
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#INTEGER_EXT
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#SMALL_BIG_EXT
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#LARGE_BIG_EXT
class RDF::Literal::Integer
  def to_bert
    to_i
  end
end

##
# RDF/BERT extensions for floating-point literals.
#
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#FLOAT_EXT
# @see http://erlang.org/doc/apps/erts/erl_ext_dist.html#NEW_FLOAT_EXT
class RDF::Literal::Double
  def to_bert
    to_f
  end
end
