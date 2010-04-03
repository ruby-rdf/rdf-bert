BERT-RPC Repository Proxy for RDF.rb
====================================

This is an [RDF.rb][] plugin that adds support for proxying RDF
[repository][RDF::Repository] operations over the simple and efficient
[Erlang][]-compatible [BERT-RPC][] binary protocol specified and
open-sourced by [GitHub][].

* <http://github.com/bendiken/rdf-bert>

BERT-RPC Client Examples
------------------------

    require 'rdf/bert'

### Connecting to a remote repository over BERT-RPC

    repository = RDF::BERT::Client.new(:host => "localhost", :port => 9999)

### Obtaining information about the remote repository

Remote BERT-RPC repositories support all [RDF::Repository] methods, e.g.:

    repository.empty?
    repository.count

### Iterating over all RDF statements in the remote repository

Remote BERT-RPC repositories support all [RDF::Enumerable] methods, e.g.:

    repository.each_statement do |statement|
      puts statement.inspect
    end

### Adding new RDF statements to the remote repository

Remote BERT-RPC repositories support all [RDF::Mutable] methods, e.g.:

    repository << [RDF::Node.new, RDF.type, RDF::FOAF.Person]

### Querying the remote repository for triple patterns

Remote BERT-RPC repositories support all [RDF::Queryable] methods, e.g.:

    repository.query([nil, RDF.type, RDF::FOAF.Person]) do |statement|
      puts "Found a person: #{statement.subject}"
    end

BERT-RPC Server Examples
------------------------

You can use either [BERTREM][] or [Ernie][] to setup and run a BERT-RPC
daemon that serves an RDF repository over the wire. BERTREM is written in
Ruby, uses [EventMachine][] for its event processing, and is very easy to
get going with. Ernie is a Ruby/Erlang hybrid developed by and used at
GitHub, and takes rather more setup to get started with. The following
examples will all use BERTREM.

### Serving an initially empty in-memory repository over BERT-RPC

    require 'rdf/bert'
    require 'bertrem'

    repository = RDF::Repository.new

    RDF::BERT::Server.run(repository, :port => 9999)

### Serving an initially seeded in-memory repository over BERT-RPC

    require 'rdf/bert'
    require 'bertrem'

    repository = RDF::Repository.load('/path/to/data.nt')

    RDF::BERT::Server.run(repository, :port => 9999)

### Proxying a local or remote Sesame HTTP repository over BERT-RPC

    require 'rdf/bert'
    require 'rdf/sesame'
    require 'bertrem'

    sesame = RDF::Sesame::Server.new("http://localhost:8080/openrdf-sesame")

    RDF::BERT::Server.run(sesame.repository(:SYSTEM), :port => 9999)

Protocol Description
--------------------

BERT and BERT-RPC specify a flexible binary serialization and an RPC
protocol compatible with the philosophies of dynamic languages such as Ruby,
Python, Perl, JavaScript, Erlang, Lua, etc. BERT aims to be as simple as
possible while maintaining support for the advanced data types we have come
to know and love. BERT-RPC is designed to work seamlessly within a
dynamic/agile development workflow. The BERT-RPC philosophy is to eliminate
extraneous type checking, IDL specification, and code generation. This
frees the developer to actually get things done.

* __BERT__ (Binary ERlang Term) is a flexible binary data interchange format
  based on (and compatible with) Erlang's binary serialization format.

* __BERPs__ (Binary ERlang Packets) are used for transmitting BERTs over the
  wire. A BERP is simply a BERT prepended with a four byte length header,
  where the highest order bit is first in network order.

* __BERT-RPC__ is a transport-layer agnostic protocol for performing remote
  procedure calls using BERPs as the serialization mechanism. BERT-RPC
  supports caching directives, asynchronous operations, and both call and
  response streaming.

For more information on BERT and BERT-RPC, see GitHub cofounder Tom
Preston-Werner's RubyConf 2009 presentation and the related blog posts:

* <http://bit.ly/rubyconf2009-bert-ernie-ruby-erlang-presentation>
* <http://github.com/blog/530-how-we-made-github-fast>
* <http://github.com/blog/531-introducing-bert-and-bert-rpc>
* <http://github.com/blog/606-announcing-ernie-2-0-and-2-1>

Protocol Operations
-------------------

The following functions are all specified in the BERT-RPC `rdf` module and
are thus shown accordingly prefixed. Function signatures are depicted in
[S-expression][] syntax where e.g. `(foo:bar 1 (2) "3")` is equivalent to
the BERT list `[:foo, :bar, 1, [2], "3"]` in Ruby syntax. Variadic arguments
and results are indicated using `*` to mean zero or more such elements and
`+` to mean one or more such elements.

The functions that have meaningful return values are meant to be used with
BERT-RPC's synchronous `call` request type. Some operations have no useful
return value and can thus be used with the asynchronous `cast` request type;
these operations can thus be pipelined for increased performance.

### `(rdf:graphs)`

Returns a list of all named graphs in the repository.

The results list contains URI references and/or blank nodes. Note that the
results do _not_ include the default graph (represented as `nil` in other
operations) which is to be considered always present.

    >>> (rdf:graphs)
    <<< (resource*)

### `(rdf:subjects graph*)`

Returns a list of all unique triple subjects in the given graphs. If no
graphs were explicitly specified, returns all unique subjects in the entire
repository.

    >>> (rdf:subjects)
    <<< (resource*)

### `(rdf:predicates graph*)`

Returns a list of all unique triple predicates in the given graphs. If no
graphs were explicitly specified, returns all unique predicates in the entire
repository.

    >>> (rdf:predicates)
    <<< (resource*)

### `(rdf:empty? graph*)`

Returns `true` if the given graphs are empty, i.e. they contain no triples.
If no graphs were explicitly specified, returns `true` in case the entire
repository is devoid of RDF statements.

    >>> (rdf:empty? "<http://example.org/mygraph/>")
    <<< boolean
    
    >>> (rdf:empty?)
    <<< boolean

### `(rdf:count graph*)`

Returns the number of triples in the given graphs summed. If no graphs were
explicitly specified, returns the total number of RDF statements in the
entire repository.

    >>> (rdf:count)
    <<< integer

    >>> (rdf:count "_:foobar" "<http://example.org/mygraph/>")
    <<< integer

### `(rdf:exist? graph triple+)`

Checks whether one or more triples exist in the given graph. Returns `true`
if all specified triples exist in the graph, `false` otherwise.

    >>> (rdf:exist? nil ("_:jhacker" "<http://xmlns.com/foaf/0.1/name>" "\"J. Random Hacker\""))
    <<< boolean

### `(rdf:query graph pattern)`

Executes a triple pattern query on the given graph, returning the list of
triples matching the given pattern.

    >>> (rdf:query nil (nil nil nil))
    <<< (triple*)

### `(rdf:insert graph triple+)`

Inserts one or more triples into the given graph.

No meaningful result is guaranteed to be returned, making this a suitable
operation for BERT-RPC's asynchronous `cast` request type.

    >>> (rdf:insert nil ("_:jhacker" "<http://xmlns.com/foaf/0.1/name>" "\"J. Random Hacker\""))
    <<< nil

### `(rdf:delete graph triple+)`

Deletes one or more triples from the given graph.

No meaningful result is guaranteed to be returned, making this a suitable
operation for BERT-RPC's asynchronous `cast` request type.

    >>> (rdf:delete nil ("_:jhacker" "<http://xmlns.com/foaf/0.1/name>" "\"J. Random Hacker\""))
    <<< nil

### `(rdf:clear graph*)`

Deletes any and all triples from the given graphs. If no graphs were
explicitly specified, deletes any and all RDF statements from the entire
repository.

No meaningful result is guaranteed to be returned, making this a suitable
operation for BERT-RPC's asynchronous `cast` request type.

    >>> (rdf:clear)
    <<< nil
    
    >>> (rdf:clear "<http://rubygems.org/>")
    <<< nil

Protocol Serialization
----------------------

RDF values (blank nodes, URI references, and literals) are represented as
BERT strings using the appropriate canonical [N-Triples][] lexical forms.
RDF triples are represented as three-term BERT lists containing such BERT
strings for the subject, predicate and object.

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
wire as BERT strings just like plain literals, but contain the added
language tag at the end of the string, after the concluding `'"'` (double
quote) character:

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
wire as BERT strings like plain literals, but contain the added absolute
datatype URI at the end of the string, after the concluding `'"'` (double
quote) character:

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
triples, the only difference being that `nil`, represented in BERT as the
`t[:bert, :nil]` tuple, is an allowed value in place of any of the list
terms and is used to represent a wildcard matching any RDF value:

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

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.4)
* [BERT-RPC](http://rubygems.org/gems/bertrpc) (>= 1.3.0) for RPC client usage
* [BERTREM][] (>= 0.0.7) or [Ernie][] for RPC server usage

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
[RDF::Enumerable]: http://rdf.rubyforge.org/RDF/Enumerable.html
[RDF::Mutable]:    http://rdf.rubyforge.org/RDF/Mutable.html
[RDF::Queryable]:  http://rdf.rubyforge.org/RDF/Queryable.html
[BERT-RPC]:        http://bert-rpc.org/
[GitHub]:          http://github.com/
[BERTREM]:         http://rubygems.org/gems/bertrem
[Ernie]:           http://rubygems.org/gems/ernie
[EventMachine]:    http://rubyeventmachine.com/
[Erlang]:          http://en.wikipedia.org/wiki/Erlang_(programming_language)
[S-expression]:    http://en.wikipedia.org/wiki/S-expression
[N-Triples]:       http://en.wikipedia.org/wiki/N-Triples
