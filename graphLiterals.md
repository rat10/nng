# RDF Literals and Inclusion

```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

read again as a whole

```


RDF literals serve to enable use cases with non-standard semantics. They provide a way to
- reference RDF graphs for purposes beyond mere documentation and quotation, but implement any specific semantics arrangements different from the standard RDF semantics, and
- manage their inclusion into the active data via specific properties. This ensures that statements with special semantics are not processed like standard RDF, which could result in unwanted entailments (that could then not be taken back because of the monotonic nature of RDF).



## Graph Literal and Term Literal

We define a graph literal datatype, e.g.
```
":s :p :o. :a :b :c"^^nng:Graph
```
which represents the 
- referentially opaque
- unasserted
- type
of an RDF graph.

It can be used like in the following, quite uninspiring example:
```
:Alice :said ":s :p :o. :a :b :c"^^nng:GraphLiteral .
":s :p :o. :a :b :c"^^nng:GraphLiteral :assertedSoFar :zeroTimes .
```
Graph literals are the basic building block from which any specific semantics configurations can be derived. The respective mechanism is called *inclusion* and will be presented next.

We [might](https://github.com/rat10/sg/issues/2) 
[TODO can we clear this up?]
also define a term literal datatype, e.g.:
```
"ex:Superman"^^nng:TermLiteral 
```


### Encoding
The encoding of the RDF data in the literal has to follow the enclosing RDF graph, so the datatype does not specifically mention Turtle, JSON-LD etc.

### Prior Work
Graph literals have been proposed before, e.g. by [Herman](https://www.w3.org/2009/07/NamedGraph.html) and [Zimmermann](https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html), to encode RDF graphs as literals, typed by a to be defined RDF literal datatype, e.g.:
```
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

Inclusion offers the possibility to parse a graph literal and add its content into a graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements. This works very much like `owl:imports` for ontologies and the respective property, `nng:includes`, is named to allude to that similarity.

Importing a literal into a graph doesn't create a nested graph but includes the statements from the graph literal into a graph. The including graph may be explicitly named or referenced as the local graph.

```turtle
# VOCABULARY

nng:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:GraphSource ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```

The following example includes a graph literal into another graph (local or not):

```
ex:Graph_1 nng:includes ":s :p :o . :u :v :w ."^^nng:GraphLiteral .
```

To include a graph literal into the local graph a syntactically more elegant approach is available, using a self-referencing identifier, `THIS` (see the page on [mappings](mappimg.md)), to refer to the enclosing nested graph:

```
THIS nng:includes ":s :p :o . :u :v :w ."^^nng:GraphLiteral .
```

Inclusion means that the graph can be assumed to contain the statements from the included literal. Those statements therefore can not only be queried but also reasoned on, new entailments can be derived, etc. However, new entailments can not be written back into the graph literal. Therefore the only guarantee that this mechanism provides is a reference to an original state.

Inclusion may also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages.



<!--

## Transclusion

Transclusion in the most basic arrangement only includes by reference, meaning that a transcluded graph is asserted and can be queried, but it is referentially opaque and no entailments can be derived - blocking any kind of change to and inference on the transcluded data, much like the semantics of Notation3 formulas and RDF-star triple terms per the semantics presented in the CG report, as in the following example:
```
THIS nng:transcludes ":s :p :o"^^nng:GraphLiteral .
```

However, transclusion also makes it possible to configure the semantics of transcluded graph literals. Mediating access through the transclusion property guarantees that such semantics arrangements are obeyed and no unintended entailments can leak into transcluding graphs. Configurable semantics are discussed in detail only later [below](#configurable-semantics), so a simple example has to suffice here:
```
THIS nng:transcludes [
    rdf:value ":s :p :o"^^nng:GraphLiteral ;
    nng:semantics nng:APP
] .
```
An additional annotation with a semantics attribute, in this case `nng:APP`, can loosen the very restrictive base semantics to arrange for use cases driven by e.g. application intuitions like a Closed World Assumption, an Unique Name Assumption, etc.

The respective property is defined as:
```turtle
# VOCABULARY

nng:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:Graph ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Transcludes the literal via reference. Transcluding a graph literal provides certain immutability guarantees for the transcluded graph." .
```

-->








## Naming an Included Graph Literal

All examples above used anonymous nested graph literals. Explicit naming can be implemented via property lists, e.g.
```
[rdfs:label ex:X; nng:semantics nng:QUOTE]":s :p :o"
```
This is a bit awkward, but providing more syntactic sugar for such a corner case would seem too much of a stretch.



