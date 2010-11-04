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

    repository = RDF::BERT::Client.new(:host => "localhost", :port => 8000)

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

    RDF::BERT::Server.run(repository, :port => 8000)

### Serving an initially seeded in-memory repository over BERT-RPC

    require 'rdf/bert'
    require 'bertrem'

    repository = RDF::Repository.load('/path/to/data.nt')

    RDF::BERT::Server.run(repository, :port => 8000)

### Proxying a local or remote Sesame HTTP repository over BERT-RPC

    require 'rdf/bert'
    require 'rdf/sesame'
    require 'bertrem'

    sesame = RDF::Sesame::Server.new("http://localhost:8080/openrdf-sesame")

    RDF::BERT::Server.run(sesame.repository(:SYSTEM), :port => 8000)

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

_Note: this section has not yet been updated for RDF::BERT 0.2.x._

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

_Note: this section is in the process of being updated for RDF::BERT 0.2.x._

### Variables

Query variables are serialized on the wire as BERT tuples of the form
`t[:'?', variable.name.to_sym]`:

    RDF::BERT.serialize(RDF::Query::Variable.new(:subject))
    #=> t[:"?", :subject]
    
    RDF::BERT.encode(RDF::Query::Variable.new(:subject))
    #=> "\x83h\x02d\x00\x01?d\x00\asubject"
    
    RDF::BERT.unserialize(t[:"?", :subject])
    #=> #<RDF::Query::Variable(?subject)>
    
    RDF::BERT.decode("\x83h\x02d\x00\x01?d\x00\asubject")
    #=> #<RDF::Query::Variable(?subject)>

### Blank nodes

Blank nodes are serialized on the wire as BERT tuples of the form
`t[:':', node.id.to_sym]`:

    RDF::BERT.serialize(RDF::Node.new(:foobar))
    #=> t[:":", :foobar]
    
    RDF::BERT.encode(RDF::Node.new(:foobar))
    #=> "\x83h\x02d\x00\x01:d\x00\x06foobar"
    
    RDF::BERT.unserialize(t[:":", :foobar])
    #=> #<RDF::Node(_:foobar)>
    
    RDF::BERT.decode("\x83h\x02d\x00\x01:d\x00\x06foobar")
    #=> #<RDF::Node(_:foobar)>

### URI references

URI references are serialized on the wire as BERT tuples of the form
`t[:'<', uri.to_s]`:

    RDF::BERT.serialize(RDF::URI("http://rdf.rubyforge.org/"))
    #=> t[:<, "http://rdf.rubyforge.org/"]
    
    RDF::BERT.encode(RDF::URI("http://rdf.rubyforge.org/"))
    #=> "\x83h\x02d\x00\x01<m\x00\x00\x00\x19http://rdf.rubyforge.org/"
    
    RDF::BERT.unserialize(t[:<, "http://rdf.rubyforge.org/"])
    #=> #<RDF::URI(http://rdf.rubyforge.org/)>
    
    RDF::BERT.decode("\x83h\x02d\x00\x01<m\x00\x00\x00\x19http://rdf.rubyforge.org/")
    #=> #<RDF::URI(http://rdf.rubyforge.org/)>

### Plain literals

RDF literals that do not have an accompanying language tag or datatype URI
are serialized on the wire as BERT tuples of the form
`t[:'"', literal.value.to_s]`:

    RDF::BERT.serialize("Hello, world!")
    #=> t[:"\"", "Hello, world!"]
    
    RDF::BERT.encode("Hello, world!")
    #=> "\x83h\x02d\x00\x01\"m\x00\x00\x00\rHello, world!"
    
    RDF::BERT.unserialize(t[:"\"", "Hello, world!"])
    #=> #<RDF::Literal("Hello, world!")>
    
    RDF::BERT.decode("\x83h\x02d\x00\x01\"m\x00\x00\x00\rHello, world!")
    #=> #<RDF::Literal("Hello, world!")>

### Language-tagged literals

RDF literals that have an accompanying language tag are serialized on the
wire as BERT tuples of the form
`t[:'@', literal.value.to_s, literal.language.to_sym]`:

    RDF::BERT.serialize("Hello, world!", :language => :en)
    #=> t[:"@", "Hello, world!", :en]
    
    RDF::BERT.encode("Hello, world!", :language => :en)
    #=> "\x83h\x03d\x00\x01@m\x00\x00\x00\rHello, world!d\x00\x02en"
    
    RDF::BERT.unserialize(t[:"@", "Hello, world!", :en])
    #=> #<RDF::Literal("Hello, world!"@en)>
    
    RDF::BERT.decode("\x83h\x03d\x00\x01@m\x00\x00\x00\rHello, world!d\x00\x02en")
    #=> #<RDF::Literal("Hello, world!"@en)>

### Datatyped literals

RDF literals that have an accompanying datatype URI are serialized on the
wire as BERT tuples of the form
`t[:'^', literal.value.to_s, literal.datatype.to_s]`:

    RDF::BERT.serialize("Hello, world!", :datatype => RDF::XSD.string)
    #=> t[:^, "Hello, world!", "http://www.w3.org/2001/XMLSchema#string"]
    
    RDF::BERT.encode("Hello, world!", :datatype => RDF::XSD.string)
    #=> "\x83h\x03d\x00\x01^m\x00\x00\x00\rHello, world!m\x00\x00\x00'http://www.w3.org/2001/XMLSchema#string"
    
    RDF::BERT.unserialize(t[:^, "Hello, world!", "http://www.w3.org/2001/XMLSchema#string"])
    #=> #<RDF::Literal("Hello, world!"^^<http://www.w3.org/2001/XMLSchema#string>)>
    
    RDF::BERT.decode("\x83h\x03d\x00\x01^m\x00\x00\x00\rHello, world!m\x00\x00\x00'http://www.w3.org/2001/XMLSchema#string")
    #=> #<RDF::Literal("Hello, world!"^^<http://www.w3.org/2001/XMLSchema#string>)>

However, as a special case due to efficiency considerations, datatyped
literals having the datatypes `xsd:boolean`, `xsd:integer`, or `xsd:double`
are serialized into their direct BERT equivalents, as described in the
following sections.

#### Boolean literals

RDF boolean literals, i.e. literals having the datatype `xsd:boolean`,
are serialized on the wire as the BERT atoms `:t` and `:f`:

    RDF::BERT.serialize(true)
    #=> :t
    
    RDF::BERT.encode(true)
    #=> "\x83d\x00\x01t"
    
    RDF::BERT.unserialize(:t)
    #=> #<RDF::Literal::Boolean("true"^^<http://www.w3.org/2001/XMLSchema#boolean>)>
    
    RDF::BERT.decode("\x83d\x00\x01t")
    #=> #<RDF::Literal::Boolean("true"^^<http://www.w3.org/2001/XMLSchema#boolean>)>

#### Integer literals

RDF integer literals, i.e. literals having the datatype `xsd:integer`, are
serialized on the wire as BERT integers:

    RDF::BERT.serialize(42)
    #=> 42
    
    RDF::BERT.encode(42)
    #=> "\x83a*"
    
    RDF::BERT.unserialize(42)
    #=> #<RDF::Literal::Integer("42"^^<http://www.w3.org/2001/XMLSchema#integer>)>
    
    RDF::BERT.decode("\x83a*")
    #=> #<RDF::Literal::Integer("42"^^<http://www.w3.org/2001/XMLSchema#integer>)>

#### Floating-point literals

RDF floating-point literals, i.e. literals having the datatype `xsd:double`,
are serialized on the wire as BERT double-precision floats:

    RDF::BERT.serialize(3.1415)
    #=> 3.1415
    
    RDF::BERT.encode(3.1415)
    #=> "\x83F@\t!\xCA\xC0\x83\x12o"
    
    RDF::BERT.unserialize(3.1415)
    #=> #<RDF::Literal::Double("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)>
    
    RDF::BERT.decode("\x83F@\t!\xCA\xC0\x83\x12o")
    #=> #<RDF::Literal::Double("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)>

### Triples

RDF triples are serialized on the wire as BERT tuples of the form:
`[:'3', subject, predicate, object]`, where each term is a BERT value or
tuple in accordance with the serialization described in the preceding
sections:

    RDF::BERT.serialize([RDF::Node.new(:foobar), RDF::DC.title, "Foobar"])
    #=> t[:"3", t[:":", :foobar], t[:<, "http://purl.org/dc/terms/title"], t[:"\"", "Foobar"]]
    
    RDF::BERT.encode([RDF::Node.new(:foobar), RDF::DC.title, "Foobar"])
    #=> "\x83h\x04d\x00\x013h" + 
    #   "\x02d\x00\x01:d\x00\x06foobarh" +
    #   "\x02d\x00\x01<m\x00\x00\x00\x1Ehttp://purl.org/dc/terms/titleh" + 
    #   "\x02d\x00\x01\"m\x00\x00\x00\x06Foobar"
    
    RDF::BERT.unserialize(t[:"3", t[:":", :foobar], t[:<, "http://purl.org/dc/terms/title"], t[:"\"", "Foobar"]])
    #=> #<RDF::Statement(_:foobar <http://purl.org/dc/terms/title> "Foobar" .)>
    
    RDF::BERT.decode("\x83h\x04d\x00\x013h\x02d\x00\x01:d\x00\x06foobarh"...)
    #=> #<RDF::Statement(_:foobar <http://purl.org/dc/terms/title> "Foobar" .)>

### Triple patterns

RDF triple patterns are serialized on the wire in the same way as are
triples, the only difference being that query variables and `nil`,
represented in BERT as the `t[:bert, :nil]` tuple, are allowed values in
place of any of the terms and are used for wildcard matching:

    RDF::BERT.serialize([nil, RDF.type, nil])
    #=> t[:"3", nil, t[:<, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"], nil]
    
    RDF::BERT.encode([nil, RDF.type, nil])
    #=> "\x83h\x04d\x00\x013h\x02d\x00\x04bertd\x00\x03nilh" +
    #   "\x02d\x00\x01<m\x00\x00\x00/http://www.w3.org/1999/02/22-rdf-syntax-ns#typeh" +
    #   "\x02d\x00\x04bertd\x00\x03nil"
    
    RDF::BERT.unserialize(t[:"3", nil, t[:<, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"], nil])
    #=> #<RDF::Statement(nil <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> nil .)>
    
    RDF::BERT.decode("\x83h\x04d\x00\x013h\x02d\x00\x04bertd\x00\x03nilh"...)
    #=> #<RDF::Statement(nil <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> nil .)>

Documentation
-------------

<http://rdf.rubyforge.org/bert/>

* {RDF::BERT}
  * {RDF::BERT::Client}
  * {RDF::BERT::Server}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.2.3)
* [BERT-RPC](http://rubygems.org/gems/bertrpc) (>= 1.3.0) for RPC client usage
* [BERTREM][] (>= 0.0.7) or [Ernie][] (>= 2.4.0) for RPC server usage

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of `RDF::BERT`, do:

    % [sudo] gem install rdf-bert

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/rdf-bert.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/rdf-bert/tarball/master

Author
------

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

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
