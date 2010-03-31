BERT-RPC Proxy for RDF.rb
=========================

This is an [RDF.rb][] plugin that adds support for proxying RDF
[repository][RDF::Repository] operations over the [BERT-RPC][] binary
protocol developed by [GitHub][].

* <http://github.com/bendiken/rdf-bert>

Protocol Description
--------------------

Protocol Serialization
----------------------

Protocol Operations
-------------------

### `(rdf:graphs)`

### `(rdf:subjects graph*)`

### `(rdf:predicates graph*)`

### `(rdf:empty? graph*)`

### `(rdf:count graph*)`

### `(rdf:exist? graph triple+)`

### `(rdf:query graph pattern)`

### `(rdf:insert graph triple+)`

### `(rdf:delete graph triple+)`

### `(rdf:clear graph*)`

Documentation
-------------

* {RDF::BERT}
  * {RDF::BERT::Client}
  * {RDF::BERT::Server}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.3)
* [BERT-RPC](http://rubygems.org/gems/bertrpc) (>= 1.3.0)

Installation
------------

The recommended installation method is via RubyGems. To install the latest
official release, do:

    % [sudo] gem install rdf-bert

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/rdf-bert.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/rdf-bert/tarball/master

Authors
-------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

`RDF::BERT` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[RDF.rb]:          http://rdf.rubyforge.org/
[RDF::Repository]: http://rdf.rubyforge.org/RDF/Repository.html
[BERT-RPC]:        http://bert-rpc.org/
[GitHub]:          http://github.com/
