## RDF Literals and Transclusion

RDF literals serve to enable use cases with non-standard semantics.


### Graph Literal and Term Literal

We define a graph literal datatype, e.g.

    ":s :p :o. :a :b :c"^^seg:graph

which represents the 
    referentially opaque,
    unasserted
    type
of an RDF graph.

It can be used like in the following very uninteresting example:

    :Alice :said ":s :p :o. :a :b :c"^^seg:graph .
    ":s :p :o. :a :b :c"^^seg:graph :assertedSoFar :zeroTimes .

We also define a term literal datatype, e.g.:

    "ex:Superman"^^seg:term .

The encoding of the RDF data in the literal has to follow the encompassing RDF graph, so no specific mention of Turtle, JSON-LD etc.


### Configurable Semantics

RDF literals can be used to introduce RDF with non-standard semantics into the data. Many such semantics are possible, like un-assertedness, referential opacity, closed world assumption, unique name assumption, combinations thereof, etc. To introduce a graph with specific semantics, it is _transcluded_:

    :Alice :says [ seg:transcludes ":s :p :o. :a :b :c"^^seg:graph 
                   seg:semantics seg:Quote ] 

If no semantics is specified, the graph literal is transcluded according to regular RDF semantics, just like owl:imports transcludes an RDF file.

To prevent problems with monotonicity specific transclusion properties for each semantics can be specified, e.g.

    :Alice :says [ seg:transcludesQuote ":s :p :o. :a :b :c"^^seg:graph ]

To provide even more comfort, specific semantic modifiers like eg. QUOTED can be defined and prepended to a graph literal (also omitting the datatype declaration), creating a nested graph with the specified semantics: 

    :Alice :says [QUOTED]":s :p :o. :a :b :c"

To provide yet even more syntactic sugar a special notation is introduced to support a relatively common use case: documenting assertions without asserting them. To better disambiguate it from a quotation (which emphasizes verbatim fidelity and is indeed asserted) we do however chose the name 'record', as it records the meaning of some RDF graph. A record is a
    referentially transparent,
    un-asserted
    type
of an RDF graph.  The syntax for this special semantics configuration is {" ..." }, e.g.:

    :Bob :said {" :Moon :madeOf :Cheese "} .

With less syntactic sugar this is equal to 

    :Bob :said [RECORD]":Moon :madeOf :Cheese" .


So far only graph literals have been discussed, but also term literals provide interesting applications. The well known Superman-problem can be expressed as follows:

    :LoisLane :loves [QUOTED]{:Superman} .

Note how references to Lois Lane and the concept of loving are still referentially transparent, as they should be.
Note however that we also run into a difficulty here: the quoted ':Superman' is asserted, so enclosing it in quote signs would give the wrong intuition. That's why we enclosed it in squiggly brackets.
An unasserted RECORD however would be encoded in quote signs, e.g.:

    :Bob :considered [RECORD]":Crazy" .


[TODO] 
i know you hate this! please read on, and in the end think about it and then lets discuss it. in a way i hate it too, but if this doesn't work, then the whole concept of configurable semantics might not work
or it might work only in a very rudimentary way where literals can be queried, but can only be returned as a whole (e.g.. you can query literals for what ALice likes, but you can't get ":Cheese" as a result, you can only get the whole literal, eg "Alice likes Cheese. Bob likes Skiing. Carol likes ...."^^seg:graph 


So, to recap: 

We have the following syntactic constructs:

    []{ :s :p :o }
            a nested graph, asserted, referentially transparent, token.
    ":s :p :o"^^seg:graph  
            an RDF graph literal, un-asserted, referentially opaque, type
    [QUOTED]":s :p :o"
            an very short way to express transclusion with opaque semantics
    {":s :p :o"}
            syntactic sugar for a special and quite popular semantics: 
            unasserted, but referentially transparent type
            aka RECORD
    [QUOTED]{:Superman} 
            a RDF term with configurable semantics, asserted
    [RECORD]":Crazy"
            a RDF term with configurable semantics, un-asserted


We have the following ways to define the semantics of a transclusion
 
    [ seg:transcludes ":s :p :o"^^seg:graph ]
            transcludes the graph literal like owl:imports imports an RDF file
    [ seg:transcludesQuoted ":s :p :o"^^seg:graph ]
            transcludes the graph literal with a specific semantics, here 
            referentially opaque
    [QUOTED]":s :p :o"
            an even shorter way to express the same

We have the following semantics
 
    NESTED  asserted, referentially transparent, token (the nested graph, no literal involved)
    LITERAL unasserted, referentially opaque, type (really just a datatyped string)
    RECORD  unasserted, referentially transparent, type 
    QUOTED  asserted, referentially opaque (i.e no co-denotation), token

    of these, only QUOTED is not supported by specific syntactic sugar.
    thereby it is the blueprint for any other semantics configuration
    that users may define.

[TODO] is RECORD a good name? does it invoke the sense of being un-asserted?

### Defining Semantics Modifiers

Yeah, how do we do that? Obviously, LITERAL and RECORD are hard coded because they are supported special syntactic sugar. 
But what about QUOTED and anything beyond? It seems like we have to use (namespaced) IRIs.
For a vocabulary to define semantics see the long introduction to Semantic Graphs.


### Querying

We have to differentiate between 
- regular RDF data and data *in/from* literals.
- data *in* graph literals and data transcluded *from* graph literals with special semantics.
- data with semantics defining it as asserted or un-asserted data.

A query MUST NOT return results *in* RDF literals or *transcluded with un-asserted semantics* from RDF literals if not explicitly asked for (to prevent accidental confusion of asserted and un-asserted data).
A query MUST return RDF literals *transcluded with asserted semantics* and it MUST annotate the returned data with those semantics (because asserted data has to be visible, but its specific semantics have to be visible too).

Explicitly asking for literal data with un-asserted semantics can be performed in two ways: either use a WITH modifier to the query or explicitly ask for the content of a literal.
Any query asking specifically for data from a literal will get those results without having to select the literal type in a WITH clause.
A query using the 'WITH' modifier will include results from all literals of that type:
- LITERAL will include all ":s :p :o"^^seg:graph and ":s"^^seg:term literals, transcluded or not
- TRANSCLUDED will include all transcluded literals, asserted and un-asserted, but not their LITERAL source
- RECORD will include all unasserted transparent types

Annotating the returned data with semantics is performed in a similar way as when authoring. However, asserted terms are not put in quotes:
- a term in a result set is encoded as a term literal, e.g. [QUOTED]:Superman, [RECORD]":Superman"
- a graph in a CONSTRUCT result is encoded as a graph term, e.g. [QUOTED]{:s :p :o}, [RECORD]":s :p :o"

[TODO] no quotes around asserted literals - is that a good idea? and feasible?

Just to clarify: graph literals that are transcluded without semantics modifiers have regular RDF semantics and  queried and the results are displayed like regular RDF data - because that's what they are - without any prepended semantics modifier.

PROBLEM: how will the query engine know that some semantics is asserted or un-asserted? Will it have t look up the semantics' definition on the web?


### Examples

    prefix : <http://ex.org/>
    prefix seg: <http://rat.io/seg/>
    
    :X seg:transcludes ":Alice :likes :Skiing"^^seg:graph .
    :Bob :says ":Moon :madeOf :Cheese"^^seg:graph .
    :Alice :said ":s :p :o. :a :b :c"^^seg:graph .
    [:Y QUOTED]":ThisGraph :is :Quoted" .
    :LoisLane :loves [QUOTED]":Superman", :Skiing, [RECORD]":ClarkKent" .
    :Kid :loves [RECORD]":Superman" .
    :Carol :claims {":Denis :goes :Swimming"} .
    [:Y]{:Some :dubious :Thing}
    :ClarkKent owl:sameAs :Superman .
    :ClarkKent :loves :LoisLane .

#### what to expect without WITH clause or explicit addressing

    SELECT ?s
    WHERE  { ?s ?p :Superman }

    here i would like the result to include 
        :LoisLane
        because she loves the opaque (but asserted) version of :Superman
    but 
        not :Kid 
        because it loves an unasserted comic figure (poor kid)


    SELECT ?o
    WHERE { :LoisLane :loves ?o }

    here i would like to see
        [QUOTED]:Superman
        :Skiing
    but
        not 
        [RECORD]":ClarkKent"


    SELECT ?o
    WHERE { :moon ?p ?o}

    here i would like to see
        nothing
        because the respective candidate is a literal

#### what to expect with WITH clause

Query modifiers are introduced by a 'WITH' clause and use the provided semantics identifiers, e.g. LITERAL, TRANSCLUDED, RECORD, OPAQUE:

    SELECT ?s 
    WHERE  { ?s ?p :Superman }
    WITH   RECORD

    here i would like to see
        :LoisLane  # because she loves the opaque (but asserted) version of :Superman
        :Kid       # because it loves the record Superman


    SELECT ?o
    WHERE { :LoisLane :loves ?o }
    WITH   RECORD

    here i would like to see
        [QUOTED]:Superman       # no quotes around this IRI because it's asserted
        :Skiing
        [RECORD]":ClarkKent"


    SELECT ?o
    WHERE { :moon ?p ?o}
    WITH LITERAL

    here i would like to see
        [LITERAL]":Cheese"
        because the respective candidate is a literal


[TODO]   what if also the name of the nested graph that this value originated from has to be recorded? then the syntax becomes quite convoluted.
            


#### what to expect with Explicit Addressing

If a query addresses a graph literal explicitly, its results are rendered like regular RDF.

    :Alice :said ":s :p :o. :a :b :c"^^seg:graph .

[HELP]  i'd like to address the graph literal
        but how do i do that?
        maybe i need the following little helpers:

    seg:hasSource rdfs:range seg:GraphLiteral .
    []{:a :b :c} seg:hasSource ":A :b :C"^^seg:graph

    # select all objects in the literal
    # assuming that graph literals are graphs too (ie referenced per graph keyword) ???
    SELECT ?so
    WHERE ?a seg:hasSource ?src
          graph ?src { ?ss ?sp ?so }





#### what to expect when CONSTRUCTing results

Currently that's future work, as result sets are the more immediate need. 
However, I expect that constructed graphs will also contain
    - terms from nested graphs with special semantics or 
    - nested terms with special semantics
so it will again be necessary to be able to encode semantics per term. In the case where  whole statements have the same semantics they have to be encoded as nested graphs.