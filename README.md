BERT-RPC Proxy for RDF.rb
=========================

This is an [RDF.rb][] plugin that adds support for proxying RDF
[repository][RDF::Repository] operations over the simple and efficient
[BERT-RPC][] binary protocol developed and open-sourced by [GitHub][].

* <http://github.com/bendiken/rdf-bert>

Examples
--------

    require 'rdf/bert'

### Connecting to a remote repository over BERT-RPC

    repository = RDF::BERT::Client.new(:host => "localhost", :port => 9999)

Protocol Description
--------------------

BERT and BERT-RPC are an attempt to specify a flexible binary serialization
and RPC protocol that are compatible with the philosophies of dynamic
languages such as Ruby, Python, Perl, JavaScript, Erlang, Lua, etc. BERT
aims to be as simple as possible while maintaining support for the advanced
data types we have come to know and love. BERT-RPC is designed to work
seamlessly within a dynamic/agile development workflow. The BERT-RPC
philosophy is to eliminate extraneous type checking, IDL specification, and
code generation. This frees the developer to actually get things done.

* __BERT__ (Binary ERlang Term) is a flexible binary data interchange format
  based on (and compatible with) Erlang's binary serialization format.

* __BERPs__ (Binary ERlang Packets) are used for transmitting BERTs over the
  wire. A BERP is simply a BERT prepended with a four byte length header,
  where the highest order bit is first in network order.

* __BERT-RPC__ is a transport-layer agnostic protocol for performing remote
  procedure calls using BERPs as the serialization mechanism. BERT-RPC
  supports caching directives, asynchronous operations, and both call and
  response streaming.

For more information on BERT and BERT-RPC, see the original developers' blog
posts:

* <http://github.com/blog/530-how-we-made-github-fast>
* <http://github.com/blog/531-introducing-bert-and-bert-rpc>
* <http://github.com/blog/606-announcing-ernie-2-0-and-2-1>

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

    >>> (rdf:exist? nil ("_:g123" "http://xmlns.com/foaf/0.1/name" "J. Random Hacker"))

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

RDF values (blank nodes, URI references, and literals) are represented as
BERT strings containing the values' canonical [N-Triples][] forms. RDF
triples are represented as three-term BERT lists containing such BERT
strings.

### Blank nodes

Blank nodes are serialized on the wire as BERT strings of the form
`"_:[A-Za-z][A-Za-z0-9]*"`:

    RDF::BERT.serialize(RDF::Node.new)
    #=> "_:g2165237140"
    
    RDF::BERT.encode(RDF::Node.new)
    #=> "\203m\000\000\000\r_:g2165237140"
    
    RDF::BERT.unserialize("_:g2165237140")
    #=> #<RDF::Node(_:g2165237140)>
    
    RDF::BERT.decode("\203m\000\000\000\r_:g2165237140")
    #=> #<RDF::Node(_:g2165237140)>

### URI references

URI references are serialized on the wire as BERT strings that begin with an
initial `'<'` character, are followed by the string representation of the
URI reference, and are terminated by a final `'>'` character:

    RDF::BERT.serialize(RDF::URI.new("http://rdf.rubyforge.org/"))
    #=> "<http://rdf.rubyforge.org/>"
    
    RDF::BERT.encode(RDF::URI.new("http://rdf.rubyforge.org/"))
    #=> "\203m\000\000\000\e<http://rdf.rubyforge.org/>"
    
    RDF::BERT.unserialize("<http://rdf.rubyforge.org/>")
    #=> #<RDF::URI(http://rdf.rubyforge.org/)>
    
    RDF::BERT.decode("\203m\000\000\000\e<http://rdf.rubyforge.org/>")
    #=> #<RDF::URI(http://rdf.rubyforge.org/)>

### Plain literals

RDF string literals that do not have an accompanying language tag or
datatype URI are serialized on the wire as BERT strings that begin with an
initial `'"'` (double quote) character, are followed by the N-Triples
escaped form of the string literal, and are terminated by a final `'"'`
character:

    RDF::BERT.serialize("Hello, world!")
    #=> "\"Hello, world!\""
    
    RDF::BERT.encode("Hello, world!")
    #=> "\203m\000\000\000\017\"Hello, world!\""
    
    RDF::BERT.unserialize("\"Hello, world!\"")
    #=> #<RDF::Literal("Hello, world!")>
    
    RDF::BERT.decode("\203m\000\000\000\017\"Hello, world!\"")
    #=> #<RDF::Literal("Hello, world!")>

### Language-tagged literals

RDF literals that have an accompanying language tag are serialized on the
wire as BERT strings just like plain literals (see above), but contain the
added language tag at the end of the string, after the concluding `'"'`
(double quote) character:

    RDF::BERT.serialize("Hello, world!", :language => :en)
    #=> "\"Hello, world!\"@en"
    
    RDF::BERT.encode("Hello, world!", :language => :en)
    #=> "\203m\000\000\000\022\"Hello, world!\"@en"
    
    RDF::BERT.unserialize("\"Hello, world!\"@en")
    #=> #<RDF::Literal("Hello, world!"@en)>
    
    RDF::BERT.decode("\203m\000\000\000\022\"Hello, world!\"@en")
    #=> #<RDF::Literal("Hello, world!"@en)>

### Datatyped literals

RDF literals that have an accompanying datatype URI are serialized on the
wire as BERT strings like plain literals (see above), but contain the added
absolute datatype URI at the end of the string, after the concluding `'"'`
(double quote) character:

    RDF::BERT.serialize(3.1415)
    #=> "\"3.1415\"^^<http://www.w3.org/2001/XMLSchema#double>"
    
    RDF::BERT.encode(3.1415)
    #=> "\203m\000\000\0003\"3.1415\"^^<http://www.w3.org/2001/XMLSchema#double>"
    
    RDF::BERT.unserialize("\"3.1415\"^^<http://www.w3.org/2001/XMLSchema#double>")
    #=> #<RDF::Literal("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)>
    
    RDF::BERT.decode("\203m\000\000\0003\"3.1415\"^^<http://www.w3.org/2001/XMLSchema#double>")
    #=> #<RDF::Literal("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)>

### Triples

RDF triples are serialized on the wire as three-term BERT lists of the form
`[subject, predicate, object]`, where each term is a BERT string containing
the N-Triples representation of the given value, as described in the
preceding sections.

    RDF::BERT.serialize([RDF::Node.new(:foobar), RDF::DC.title, "Foobar"])
    #=> ["_:foobar", "<http://purl.org/dc/terms/title>", "\"Foobar\""]
    
    RDF::BERT.encode([RDF::Node.new(:foobar), RDF::DC.title, "Foobar"])
    #=> "\203l\000\000\000\003m\000\000\000\b_:foobar" +
    #   "m\000\000\000 <http://purl.org/dc/terms/title>m\000\000\000\b\"Foobar\"j"
    
    RDF::BERT.unserialize(["_:foobar", "<http://purl.org/dc/terms/title>", "\"Foobar\""])
    #=> [#<RDF::Node(_:foobar)>, #<RDF::URI(http://purl.org/dc/terms/title)>, #<RDF::Literal("Foobar")>]
    
    RDF::BERT.decode("\203l\000\000\000\003m\000\000\000\b_:foobar"...)
    #=> [#<RDF::Node(_:foobar)>, #<RDF::URI(http://purl.org/dc/terms/title)>, #<RDF::Literal("Foobar")>]

### Triple patterns

RDF triple patterns are serialized on the wire in the same way as are
triples (see above), the only difference being that `nil`, represented in
BERT as the `t[:bert, :nil]` tuple, is an allowed value in place of any of
the list terms:

    RDF::BERT.serialize([nil, RDF.type, nil])
    #=> [nil, "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>", nil]
    
    RDF::BERT.encode([nil, RDF.type, nil])
    #=> "\203l\000\000\000\003h\002d\000\004bertd\000\003nil" +
    #   "m\000\000\0001<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>" +
    #   "h\002d\000\004bertd\000\003nilj"
    
    RDF::BERT.unserialize([nil, "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>", nil])
    #=> [nil, #<RDF::URI(http://www.w3.org/1999/02/22-rdf-syntax-ns#type)>, nil]
    
    RDF::BERT.decode("\203l\000\000\000\003h\002d\000\004bertd\000\003nil"...)
    #=> [nil, #<RDF::URI(http://www.w3.org/1999/02/22-rdf-syntax-ns#type)>, nil]

Documentation
-------------

<http://rdf.rubyforge.org/bert/>

* {RDF::BERT}
  * {RDF::BERT::Client}
  * {RDF::BERT::Server}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.3)
* [BERT-RPC](http://rubygems.org/gems/bertrpc) (>= 1.3.0) for RPC client usage
* [BERTREM](http://rubygems.org/gems/bertrem) or
  [Ernie](http://rubygems.org/gems/ernie) for RPC server usage

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
[N-Triples]:       http://en.wikipedia.org/wiki/N-Triples
