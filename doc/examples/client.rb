#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'rdf/bert'

repository = RDF::BERT::Client.new(:host => "localhost", :port => 9999)

repository.load("http://rdf.rubyforge.org/doap.nt")

repository.query([nil, nil, nil]) do |statement|
  puts statement.inspect
end
