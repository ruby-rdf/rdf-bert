require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::BERT do
  EXAMPLES = {
    'variables' => [
      [RDF::Query::Variable.new(id = :foo),
       BERT::Tuple[:'?', id.to_sym]],
    ],
    'blank nodes' => [
      [RDF::Node(id = :foobar),
       BERT::Tuple[:':', id.to_sym]],
    ],
    'URIs' => [
      [RDF::URI(uri = RDF::DC.title.to_s),
       BERT::Tuple[:'<', uri.to_s]],
    ],
    'plain literals' => [
      [RDF::Literal(text = 'Hello'),
       BERT::Tuple[:'"', text.to_s]],
    ],
    'language-tagged literals' => [
      [RDF::Literal(text = 'Hello', :language => (lang = :en)),
       BERT::Tuple[:'@', text.to_s, lang.to_sym]],
    ],
    'datatyped literals' => [
      [RDF::Literal(text = 'Hello', :datatype => (type = RDF::XSD.string)),
       BERT::Tuple[:'^', text.to_s, type.to_s]],
    ],
    'xsd:double literals' => [
      [RDF::Literal(3.1415), 3.1415],
    ],
    'xsd:float literals' => [
      [RDF::Literal(3.1415, :datatype => RDF::XSD.float),
       BERT::Tuple[:'^', '3.1415', RDF::XSD.float.to_s]],
    ],
    'triples' => [
      [RDF::Statement(s = RDF::Node.new, p = RDF.type, o = RDF::FOAF.Person),
       BERT::Tuple[:'3',
         BERT::Tuple[:':', s.to_sym],
         BERT::Tuple[:'<', p.to_s],
         BERT::Tuple[:'<', o.to_s]]]
    ],
    'quads' => [
      [RDF::Statement(s = RDF::Node.new, p = RDF.type, o = RDF::FOAF.Person, :context => (c = RDF::Node.new)),
       BERT::Tuple[:'4',
         BERT::Tuple[:':', s.to_sym],
         BERT::Tuple[:'<', p.to_s],
         BERT::Tuple[:'<', o.to_s],
         BERT::Tuple[:':', c.to_sym]]]
    ],
  }

  context "serializing into RDF/BERT" do
    EXAMPLES.each do |example_type, examples|
      examples.each do |(example_input, example_output)|
        it "should serialize #{example_type}" do
          RDF::BERT.serialize(example_input).should == example_output
        end
      end
    end
  end

  context "unserializing from RDF/BERT" do
    EXAMPLES.each do |example_type, examples|
      examples.each do |(example_output, example_input)|
        it "should unserialize #{example_type}" do
          RDF::BERT.unserialize(example_input).should == example_output
        end
      end
    end
  end
end
