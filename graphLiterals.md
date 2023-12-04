# Graph Literals and Inclusion

<!-- TODO  a lot...

a graph literal always represents *at least* a quote
i.e. per default it's
     unasserted
     referentially opaque
consequently if a graph literal is included via an unknown property
(which could be 
    an unknown attempt on a formal semantics like ex:inAsThatNewSemantics, 
    but just as well a pretty un-semantic ex:said )
it can still be queried.
to prevent even that, there's still xsd:string



implementation
    the essential aspect of graph literals is that they are 
        queryable
        but can not be part of the target graph
            if a query does not explicitly add them
    so they have to be kept separate from normal, asserted triples
    there's many ways to implement that
        standard reification + unstar mapping
        un/folding of strings
        profiles
        extra bits per triple in the database
        separate datasets
        an extra step in the query process
        new "system" graphs
        etc
    but that is implementation detail
        and out of scope of this proposal


define a relation between 
    -   abstract graph type (ie a graph literal)
    -   concrete graph token (ie a nested graph)
    one indirection that bridges the gap between
        the platonic ideal of the rdf model theory and
        the semantic web as we know it


what about normalization
    with quoting? rather not
    with records, reports?
    yet another type of graph literals?

-->



Graph literals enable use cases with non-standard semantics. They provide a way to
- reference RDF graphs for purposes like documentation and quotation,
- implement more specific arrangements different from the standard RDF semantics, and
- manage their inclusion into the active data via specific properties. 

The literal-based inclusion mechanism ensures that statements with special semantics are not processed like standard RDF, which could result in unwanted entailments (that could then not be taken back because of the monotonic nature of RDF).



## Graph Literal

We define a graph literal datatype, e.g.
```turtle
":s :p :o. :a :b :c"^^nng:ttl
```
which represents the 
- referentially opaque
- unasserted
- type
of an RDF graph.

It can be used like in the following, quite uninspiring example:
```turtle
:Alice :said ":s :p :o. :a :b :c"^^nng:ttl .
":s :p :o. :a :b :c"^^nng:ttl :assertedSoFar :zeroTimes .
```
Graph literals are the basic building block from which any specific semantics configurations can be derived. The respective mechanism is called *inclusion* and will be presented below.


### Datatype Encoding

Graph literals should be supported in common serialization formats like Turtle, JSON-LD, N-Triples, N-Quads, RDF/XML, NNG etc. We use a made up `nng:ttl` datatype declaration in examples throughout this proposal, but the details have still to be worked out. 

When including graph literals, e.g. `[]" :a :b :c" :d :e ."` it should be possible to omit the datatype declaration as long as the datatype of includ*ing* graph and includ*ed* graph literal match.
> [TODO] The prototype implementation does support this in some cases, but not all.
<!-- 
so if you always work with nng, you never have to declare the type
however, it has to be possible to specifically declare the type
    as otherwise it would be impossible to preserve an
    original encoding (which is a valid use case for literals)
-->

### Prior Work
Graph literals have been proposed before, e.g. by [Herman](https://www.w3.org/2009/07/NamedGraph.html) and [Zimmermann](https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html), to encode RDF graphs as literals, typed by a to be defined RDF literal datatype, e.g.:
```turtle
"ex:x a owl:Thing"^^rdf:turtle
``` 
The approach has two important advantages:
- graph literals provide very intuitive usability characteristics, because the literal syntax is easy to understand as a verbatim representation of unasserted statements.
- graph literals don't require a modification of RDF model and syntax, but merely the definition of a new datatype. 

We take up the approach because we consider it ideally suited to implement different semantics via configurable inclusion.

To that end we introduce the Graph Literal class:
```turtle
# VOCABULARY

nng:GraphLiteral a rdfs:Class ;
    rdfs:comment "A literal whose datatype matches the enclosing RDF document, e.g. NNG, Turtle, TriG or JSON-LD".
```
We will in the following define ways in which the RDF contained in those literals can be introduced into the realm of interpretation. To that end it has to be ensured that query and reasoning engines can access the data contained in graph literals if applicable, i.e. they have to be able to parse RDF literal data types as if they were standard RDF data IFF the including property linking to those literals suggests so. 

> [NOTE] 
>
> Blank nodes in graph literals are always scoped to those literals and can’t be shared with outside RDF data. Anything else would be quite involved to implement and also wouldn't make much sense, as the meaning of an existential is defined by its attributes and those are local to the literal. Graphs provide the means to include all attributes that are relevant to define the meaning of an existential. If an existential is still considered important enough to share it with data outside the graph literal, it has to be skolemized - that seems like a reasonable demand.



## Inclusion

Inclusion offers the possibility to parse a graph literal and add its content into a graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements. This works very much like `owl:imports` for ontologies. However, unlike `owl:imports` it is not transitive and included graph literals are not allowed to contain other graph literals. 
This has technical reasons as it puts less strain on the parser, but also conceptual ones: a graph literal should be self-contained and free of any kind of ambiguity.

Importing a literal into a graph doesn't create a nested graph but includes the statements from the graph literal into a graph. The including graph may be explicitly named or referenced as the local graph.

```turtle
# VOCABULARY

nng:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:NestedGraph ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```

The following example includes a graph literal into another graph (local or not):

```turtle
ex:Graph_1 nng:includes ":s :p :o . :u :v :w ."^^nng:ttl .
```

To include a graph literal into the local graph a syntactically more elegant approach is available, using a self-referencing identifier, `THIS` (see the section on [mappings](mappimg.md)), to refer to the enclosing nested graph:

```turtle
THIS nng:includes ":s :p :o . :u :v :w ."^^nng:ttl .
```

Inclusion means that the graph can be assumed to contain the statements from the included literal. Those statements therefore can not only be queried but also reasoned on, new entailments can be derived, etc. However, new entailments can not be written back into the graph literal. Therefore the only guarantee that this mechanism provides is a reference to an original state.

Inclusion may also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages.



## Naming an Included Graph Literal

All examples above used anonymous nested graph literals. Explicit naming can be implemented via property lists, e.g.
```turtle
[rdfs:label ex:X; nng:semantics nng:Quote]":s :p :o"
```
This is a bit awkward, but providing more syntactic sugar for such a corner case would seem too much of a stretch.



## Term Literal

We [might](https://github.com/rat10/sg/issues/2) also define a term literal datatype, e.g.:
```turtle
"ex:Superman"^^nng:TermLiteral 
```

See [Term Semantics Syntactic Sugar](configSemantics.md) for more detail.
