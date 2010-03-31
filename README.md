BERT-RPC Proxy for RDF.rb
=========================

This is an [RDF.rb][] plugin that adds support for proxying RDF
[repository][RDF::Repository] operations over the [BERT-RPC][] binary
protocol developed by [GitHub][].

* <http://github.com/bendiken/rdf-bert>

Examples
--------

    require 'rdf/bert'

### Connecting to a remote repository over BERT-RPC

    repository = RDF::BERT::Client.new(:host => "localhost", :port => 9999)

Protocol Description
--------------------

From the [BERT and BERT-RPC specification][BERT-RPC]:

> BERT and BERT-RPC are an attempt to specify a flexible binary
> serialization and RPC protocol that are compatible with the philosophies
> of dynamic languages such as Ruby, Python, Perl, JavaScript, Erlang, Lua,
> etc. BERT aims to be as simple as possible while maintaining support for
> the advanced data types we have come to know and love. BERT-RPC is
> designed to work seamlessly within a dynamic/agile development workflow.
> The BERT-RPC philosophy is to eliminate extraneous type checking, IDL
> specification, and code generation. This frees the developer to actually
> get things done.

Protocol Operations
-------------------

The following BERT-RPC functions are all specified in the `rdf` module and
are thus shown accordingly prefixed. Function signatures are depicted in
[S-expression][] syntax. Variadic functions are indicated using `*` to mean
zero or more such parameters and `+` to mean one or more such parameters.

### `(rdf:graphs)`

Returns a list of all graphs in the repository.

    >>> (rdf:graphs)
    <<< (graph*)

### `(rdf:subjects graph*)`

Returns a list of all unique subjects in the given graphs. If no graphs were
specified, returns all unique subjects in the entire repository.

    >>> (rdf:subjects)
    <<< (resource*)

### `(rdf:predicates graph*)`

Returns a list of all unique predicates in the given graphs. If no graphs
were specified, returns all unique predicates in the entire repository.

    >>> (rdf:predicates)
    <<< (resource*)

### `(rdf:empty? graph*)`

Returns `true` if the given graphs are empty (contain no triples). If no
graphs were specified, returns `true` in case the entire repository is
devoid of statements.

    >>> (rdf:empty? "<http://example.org/graph2/>")
    <<< true
    
    >>> (rdf:empty?)
    <<< false

### `(rdf:count graph*)`

    >>> (rdf:count)
    <<< 42

### `(rdf:exist? graph triple+)`

    >>> (rdf:exists? nil ("_:g123" "http://xmlns.com/foaf/0.1/name" "J. Random Hacker"))

### `(rdf:query graph pattern)`

    >>> (rdf:query nil (nil nil nil))

### `(rdf:insert graph triple+)`

    >>> (rdf:insert ...)

### `(rdf:delete graph triple+)`

    >>> (rdf:delete ...)

### `(rdf:clear graph*)`

    >>> (rdf:clear)
    >>> (rdf:clear "<http://rdf.rubyforge.org/>")

Protocol Serialization
----------------------

### URIs

    "<http://rdf.rubyforge.org/>"

### Blank nodes

    "_:g2165678200"

### Literals

    "\"Hello, world!\""
    "\"Hello, world!\"@en"
    "\"3.1415\"^^<http://www.w3.org/2001/XMLSchema#double>"

### Triples

    ("<http://rdf.rubyforge.org/>" "<http://purl.org/dc/terms/title>" "\"RDF.rb\"")

### Patterns

    (nil "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>" nil)

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
[S-expression]:    http://en.wikipedia.org/wiki/S-expression
