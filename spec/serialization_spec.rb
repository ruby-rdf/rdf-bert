require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::BERT do
  EXAMPLES = {
    :bnode => {:in => RDF::Node.new(id = 'foobar'), :out => "_:#{id}"},
    :uri   => {:in => RDF::URI.new(uri = RDF::DC.title.to_s), :out => "<#{uri}>"},
    :lit1  => {:in => RDF::Literal.new(text = 'Hello'), :out => "\"#{text}\""},
  }

  context "serializing into BERT" do
    it "should serialize blank nodes" do
      RDF::BERT.serialize_value(EXAMPLES[:bnode][:in]).should == EXAMPLES[:bnode][:out]
    end

    it "should serialize URIs" do
      RDF::BERT.serialize_value(EXAMPLES[:uri][:in]).should == EXAMPLES[:uri][:out]
    end

    it "should serialize literals" do
      RDF::BERT.serialize_value(EXAMPLES[:lit1][:in]).should == EXAMPLES[:lit1][:out]
    end

    it "should serialize triples" do
      # TODO
    end

    it "should serialize statements" do
      # TODO
    end
  end

  context "unserializing from BERT" do
    it "should unserialize blank nodes" do
      RDF::BERT.unserialize_value(EXAMPLES[:bnode][:out]).should == EXAMPLES[:bnode][:in]
    end

    it "should unserialize URIs" do
      RDF::BERT.unserialize_value(EXAMPLES[:uri][:out]).should == EXAMPLES[:uri][:in]
    end

    it "should unserialize literals" do
      RDF::BERT.unserialize_value(EXAMPLES[:lit1][:out]).should == EXAMPLES[:lit1][:in]
    end

    it "should unserialize triples" do
      # TODO
    end

    it "should unserialize statements" do
      # TODO
    end
  end
end
