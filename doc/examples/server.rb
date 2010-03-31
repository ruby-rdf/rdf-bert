#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib')))
require 'rdf/bert'
require 'bertrem'

BERTREM::Server.log.level = Logger::DEBUG

repository = RDF::Repository.new

RDF::BERT::Server.run(repository, :port => 9999)
