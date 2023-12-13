# Graph Literals and Inclusion


Graph literals enable use cases with non-standard semantics. They provide a way to
- reference RDF graphs for purposes like documentation and quotation,
- implement more specific semantics arrangements different from the standard RDF semantics, and
- manage their inclusion into the active data via specific properties. 

The literal-based inclusion mechanism ensures that statements with special semantics are not processed like standard RDF, which could result in unwanted entailments (that could then not be taken back because of the monotonic nature of RDF). Implementations however are not forced to implement graph literals as actual strings, but are rather encouraged to store them as RDF triples (albeit hidden from standard procedures) to facilitate querying, reasoning, etc, as discussed below.


## Graph Literal

We define a graph literal datatype which represents the 

- referentially opaque
- unasserted
- type

of an RDF graph, e.g.:

```turtle
":s :p :o. :a :b :c."^^nng:ttl
```

The approach has two important advantages:
- graph literals provide very intuitive usability characteristics, because the literal syntax is easy to understand as a verbatim representation of unasserted statements.
- graph literals don't require a modification of RDF model and syntax, but merely the definition of a new datatype. 

To that end we introduce the Graph Literal class:
```turtle
# VOCABULARY

nng:GraphLiteral a rdfs:Class ;
    rdfs:comment "An RDF literal whose datatype is either explicitly given, e.g. NNG, Turtle, TriG or JSON-LD or which matches the enclosing RDF document,".
```

> [NOTE] 
>
> Blank nodes in graph literals are always scoped to those literals and can’t be shared with outside RDF data. Anything else would be quite involved to implement and also wouldn't make much sense, as the meaning of an existential is defined by its attributes and those are local to the literal. Graphs provide the means to include all attributes that are relevant to define the meaning of an existential. If an existential is still considered important enough to share it with data outside the graph literal, it has to be skolemized - that seems like a reasonable demand.

Graph literals can be used like in the following, quite uninspiring example:
```turtle
:Alice :said ":s :p :o. :a :b :c"^^nng:ttl .
":s :p :o. :a :b :c"^^nng:ttl :assertedSoFar :zeroTimes .
```

However, more than that graph literals are the basic building block from which any specific semantics configurations can be derived. The respective mechanism is called *inclusion* and we will in the following define ways in which the RDF contained in those literals can be included into the realm of interpretation. 


### Abstract Graph

Graph literals provide a device to bridge the gap between graphs as the RDF model theory understands them - abstract types, a platonic abstraction - and graphs as they are used in practice - tokens or graph sources, mutable and concrete. This however is a separate discussion that we just would like to hint at here.



### Implementation

To that end it has to be ensured that RDF engines can access the data contained in graph literals if applicable, i.e. they have to be able to access RDF literal data types as if they were standard RDF data. 

There exist many ways to implement this:
- documenting them via RDF standard reification + RDF-star unstar mapping
- dynamic un/folding of strings 
- storing them like regular triples but hint at their "literal-ness" via profiles or service description
- storing them like regular triples but with a DB-specific extra bit that marks them as literals
- storing them like regular triples in separate datasets
- storing them like regular triples, but annotated as "literals", and access controlled via an extra step in the query process
- storing them like regular triples, but in hidden system graphs
- etc
but this is implementation detail and a detailed discussion is out of scope of this proposal. 

Dydra's implementation stores literals like named graphs, annotates those graphs as literals and introduces an extra loop in the query process that makes sure that they are not included into the target graph if not explicitly asked for in a query (either when explicitly matching a literal in a WHERE clause or when more generally addressing all literals of a certain type in the FROM clause).


### Datatype Encoding

Graph literals should be supported in common serialization formats like Turtle, JSON-LD, N-Triples, N-Quads, RDF/XML, NNG etc. We use a made up `nng:ttl` datatype declaration in examples throughout this proposal, but the details have still to be worked out. 

When including graph literals, e.g. `[] << :a :b :c . >>` it is possible to omit the datatype declaration as long as the datatype of includ*ing* graph and includ*ed* graph literal match. But it is possible to declare the datatype e.g. when faithful representation of a serialization is desired (as may well be the case when working with literals).

TODO this is WRONG - datatype encoding is ALWAYS OMITTED, otherwise it's not syntactic sugar for inclusion

> [TODO] Is an option to normalize graph literals desirable?


### Prior Work

Graph literals have been proposed before, e.g. by [Herman](https://www.w3.org/2009/07/NamedGraph.html) and [Zimmermann](https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html), to encode RDF graphs as literals, typed by a to be defined RDF literal datatype.
We take up the approach because we consider it ideally suited to implement different semantics via configurable inclusion.


### Term Literal

So far only graph literals have been discussed, but also term literals might provide interesting applications. 
The well known Superman-problem could be expressed as follows:
```turtle
:LoisLane :loves []{":Superman"} .
```
or 
```turtle
:LoisLane :loves "ex:Superman"^^nng:TermLiteral .
```
Note how references to Lois Lane and the concept of loving are still referentially transparent, as they should be, whereas the reference to Superman is referentially opaque. See the section on [Configurable Semantics](configSemantics.md) for more detail on this and other possible use cases. However, support for term literals is still an open [issue](https://github.com/rat10/sg/issues/2). 




## Inclusion

Inclusion offers the possibility to add the content of a graph literal into a named graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements, much like transclusion of nested named graphs or even `owl:imports` for ontologies. 

However, there are important differences between inclusion and  transclusion of nested graphs or `owl:imports`:
- inclusion is not transitive and included graph literals are not allowed to contain other graph literals. <!-- TODO included graph literals are not allowed or just ignored? --> This has technical reasons as it puts less strain on the parser, but also conceptual ones: a graph literal should be self-contained and free of any kind of ambiguity such as that introduced by references to external sources.
- inclusion has configurable semantics and is a two-part process, requiring also to specify a desired semantics. Without such a specification the semantics of the included graph is undefined: the included literal is then queryable but has no meaning. 

Here we only discuss the bare inclusion process. Possible semantics and their application are discussed on two separate pages, [Citation Semantics](citationSemantics.md) and [Configurable Semantics](configSemantics.md). 


```turtle
# VOCABULARY

nng:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:NestedGraph ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```

The following example includes a graph literal into another graph, albeit with yet undefined semantics:

```turtle
ex:Graph_1 nng:includes ":s :p :o . :u :v :w ."^^nng:ttl .
```

Inclusion means that the statement from a graph literal become accessible in the context of the including graph and under the conditions that the semantics of the inclusion defines. Without such a definition the statements can be queried given they are explicitly addressed (see [querying](querying.md) for detail).

Given an inclusion with well-defined semantics those statements can be queried and also reasoned on. However, new entailments can not be written back into the graph literal. Therefore this mechanism guarantees a reference to an original state. 

Consequently inclusion may also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages, or even application-specific semantics based on Closed World assumption etc. That will be discussed in the pages on [Citation Semantics](citationSemantics.md) and [Configurable Semantics](configSemantics.md).


<!-- TODO ## Naming an Included Graph Literal

All examples above used anonymous nested graph literals. Explicit naming can be implemented via property lists, e.g.
```turtle
[rdfs:label ex:X; nng:semantics nng:Quote]":s :p :o"
```
This is a bit awkward, but providing more syntactic sugar for such a corner case would seem too much of a stretch.
-->

