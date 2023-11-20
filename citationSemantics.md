# Citation Semantics

RDF literals can be used to introduce RDF with non-standard semantics into the data. Many such semantics are possible, like un-assertedness, referential opacity, closed world assumption, unique name assumption, combinations thereof, etc. In this section we will concentrate on different kinds of citation. The section on [Configurable Semantics](configSemantics.md) discusses other options.

To introduce a graph with specific semantics it is *included* from a graph literal, e.g.:
```turtle
:Alice :said [ nng:includes ":s :p :o. :a :b :c"^^nng:GraphLiteral 
               nng:semantics nng:Quote ] 
```
If no semantics is specified, the graph literal is included according to regular RDF semantics, just like `owl:imports` includes an RDF ontology into a graph.

The semantics of the inclusion specify which operations may be performed on the included graph. A quoted inclusion for example is not amenable to entailments and is not asserted either.

To prevent problems with monotonicity, specific inclusion properties for each semantics can be specified, e.g.
```turtle
:Alice :said [ nng:quotes ":s :p :o. :a :b :c"^^nng:GraphLiteral ]
```
This provides an extra guarantee that no entailments are derived from the included graph before a semantics configuration has been retrieved that might forbid such an operation. 

To provide even more comfort, specific semantic modifiers like eg. `nng:Quote` can be defined and prepended to a graph literal (also omitting the datatype declaration), creating a nested graph with the specified semantics: 
```turtle
:Alice :said [nng:Quote]":s :p :o. :a :b :c"
```
To provide yet more comfort, special notations are provided, e.g.:
```turtle
:Alice :said []":s :p :o. :a :b :c"  # quote signs without {} signify nng:Quote
```
The next section will present all pre-configured semantics with their keywords and notations. 



## Citation Configurations

Special keywords and notations are introduced to support the most common use cases:
- reporting assertions without asserting them,
- providing records of assertions with lexical accuracy and
- the already introduced quotation semantics. 
This boils down to two aspects - an assertion may be asserted or not, and it may be interpreted or not - and four categories:

``` 
                  | referentially    | referentially
                  | transparent      | opaque
------------------|------------------|---------------
   asserted token | (NESTED) RDF     | RECORD      
                  | []{ :s :p :o }   | []{" :s :p :o "}
------------------|------------------|---------------
 unasserted type  | REPORT           | QUOTE    
                  | []"{ :s :p :o }" | []" :s :p :o "

NESTED  asserted token, referentially transparent 
        (a graph, nested or not, no literal involved, i.e. standard RDF)
REPORT  unasserted type, referentially transparent 
        (reported speech, akin to the use of RDF standard reification in the wild)
RECORD  asserted token, referentially opaque 
        (interpreted, but without co-denotation)
QUOTE   unasserted type, referentially opaque
        (like verbatim quoted speech, but not endorsed)

LITERAL last not least the bare graph literal
        " :s :p :o "^^nng:Graph
        since it's not included it is also not named by a blank node
            and the datatype declaration can't be omitted
        really just a datatyped string, but on demand accessible by a SPARQL engine
```
These configurations should cover most use cases that are not targeting specific semantic arrangements like Unique Name Assumption, Closed World Assumption, etc. Of course, there's always a way to advance even deeper into the rabbit hole...


```turtle
# VOCABULARY

nng:Record a rdfs:Class ;
    rdfs:comment "Interpreted, but without co-denotation - asserted token, referentially opaque" .

nng:records a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Record ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with record semantics: asserted and referentially opaque" .

nng:Report a rdfs:Class ;
    rdfs:comment "Reported speech, akin to the use of RDF standard reification in the wild - unasserted type, referentially transparent." .

nng:reports a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Report ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with report semantics: un-asserted and referentially transparent" .

nng:Quote a rdfs:Class ;
    rdfs:comment "Like verbatim quoted speech, but not endorsed - unasserted type, referentially opaque" .

nng:quotes a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Quote ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with quotation semantics: un-asserted and referentially opaque" .

```



## Examples
A few examples may illustrate the use cases for these semantic configurations. All these configurations have one thing in common: they are [queryable](querying.md) in SPARQL (although, depending on configuration, a query might have to explicitly ask for them).


### "Unasserted Assertion"

Unasserted assertions are a niche but recurring use case that so far isn't properly supported in RDF. Some participants in the RDF-star CG strongly argued in its favour. The intent is to document assertions that for any reason one doesn't want to endorse, e.g. because they are outdated, represent a contested viewpoint, don't pass a given reliability threshold, etc.

The RDF standard reification vocabulary is often used to implement unasserted assertions, but the specified semantics don't support this interpretation and its syntactic verbosity is considered a nuisance. A semantically sound and at the same time easy to use and understand mechanism would be a useful addition to RDF's expressive capabilities.

However, the semantics of existing approaches in this area, like RDF standard reification and RDF-star, differ in subtle but important aspects. NNG supports two kinds of unasserted assertions: *reports* with standard RDF referentially transparent semantics, and *quotes* with referentially opaque semantics.


#### Report
Reports resemble indirect speech in natural language. They don't claim verbatim equivalence but only document the meaning of some statements. Like quotes they are not actually asserted, but in any other respect they perform like regular RDF. We might for example neither want to endorse the following statement nor might we want to claim that this were verbatim Bob's words:
```turtle
:Bob :said []"{ :Moon :madeOf :Cheese }" .
``` 
This reports but doesn't assert Bob's claim. However, the IRIs refer to things in the realm of interpretation, they are not a form of quotation. Bob may have a used an IRI from Wikipedia to refer to the moon and the report would still be correct.
<!--
In some cases the syntactic fidelity of straight graph literals can be problematic. We might want to document that Bob made the claim that the moon is a big cheese ball, but we don't know the exact terms he uttered. We don't know if he said `:Moon` or `:moon` and we don't want to give the impression that we do, nor do we want to be dragged into arguments about such detail.
The semantics of RDF standard reification captures this intuition as it doesn't refer to the exact syntactic representation, it is not quotation. Instead it denotes the meaning, like any triple does per the RDF semantics: it refers not to the identifier `:Moon` but to Earth's moon itself. This intuition guides the definition of the following property:
-->
<!--

### reification
```turtle
# VOCABULARY

nng:StatementGraph a rdfs:Class ;
    rdfs:subClassOf rdf:Statement, nng:GraphLiteral ;
    rdfs:comment "A Graph Literal describing the meaning of an RDF graph" .

nng:states a rdf:Property ;
    rdfs:range nng:StatementGraph ;
    rdfs:comment "The literal object describes the original meaning of a graph" .
```
To safe us from discussions about what Bob said verbatim, but concentrate on the meaning of what he said, we would reformulate the above assertion as:
```
:Bob nng:states ":Moon :madeOf :Cheese"^^nng:GraphLiteral .
```
Again, the graph literal is not asserted (and we have no intention to do so), but we are also not bound or even fixated on its syntactic accuracy. We just get along the fact.

To be free in the choice of properties, the following modelling primitive can be used:
```
:Bob :uttered [
    rdf:value ":Moon :madeOf :Cheese"^^nng:GraphLiteral ;
    a nng:StatementGraph .
] 
```
Note that by default no entailments would be derived from the graph literal. Only the additional typing of the literal as statement graph will allow RDF engines to derive further facts and e.g. replace `:Moon` by `:moon`.

Mapped to RDF standard reification this would be equal to:
```
:Bob :uttered [
    a rdf:Statement ;
    rdf:subject :Moon ;
    rdf:predicate :madeOf ;
    rdf:object :Cheese .
]
```
-->


#### Quote
Quotes are used to document statements with lexical precision, but again without endorsing them. One may imagine a written statement issued to a court, or documenting a conversation where the precise account of the actual wording used is important. This may be useful for use cases like versioning, explainable AI, verifiable credentials, etc. The example somehow unrealistically assumes that Bob speaks in triples, but note the emphasis on `:LOVE` that the quote preserves:
```turtle
:Bob :proclaimed []":i :LOVE :pineapples" .
```
Likewise, quotation semantics suppresses any transformations that are common in RDF processes to improve interoperability, e.g. replacing external vocabulary with inhouse terms that refer to the same meaning, entailing super- or subproperty relations or even just some syntactic normalizations.
<!--
A graph literal represents a quote, documenting with syntactic fidelity the assertion made (although the example somehow unrealistically assumes that Bob speaks in triples).
In a more specific arrangement we might want to document the revision history of a graph or implement an explainable AI approach. Here we aim to actually assert a statement, but also to document its precise syntactic form before any transformations or entailments. Such transformations are common in. However, sometimes it is desirable to retain the initial state of an assertion.
-->


#### Literal
The bare literal, besides its function as a building block for the inclusion mechanism, may find uses on its own, e.g. to keep graphs around that have not been properly defined yet
```turtle
:G1 rdf:value " :x :y :z ."^^nng:GraphLiteral ;
    :status :Unconfirmed .
```

Graph literals can be used to document state, e.g. when implementing versioning, explainable AI or verifiable credentials.

```turtle
# VOCABULARY

nng:statedAs a rdf:Property ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "The object describes the original syntactic form of a graph" .
```

The following example shows how this can be used to document some normalization:
```
[]{ :s :p :o } nng:statedAs ":S :p :O"^^nng:Graph
```
In the following example the literal is accompanied by a hash value to improve security:
```
[]{ :s :p :o } nng:statedAs [
    rdf:value ":S :p :O"^^nng:GraphLiteral ;
    nng:hash "4958b2dad87fef40b4b4c25ab9ae72b2"^^MD5
]
```
Note that while the graph literal is accompanying an assertion of the same type, itself it is unasserted.






#### Term Literal
So far only graph literals have been discussed, but also term literals might provide interesting applications. The well known Superman-problem could be expressed as follows:
```turtle
:LoisLane :loves [Quote]":Superman" .
```
Note how references to Lois Lane and the concept of loving are still referentially transparent, as they should be. However, support for graph terms is still an open [issue](https://github.com/rat10/sg/issues/2).  
[TODO] don't forget to update when this is decided


### "Asserted assertions"

#### Record / Literalization
Records do introduce statements into the universe of interpretation, but they don't allow the interpretation to diverge from the lexical form. They are meant to be interpreted "literally". So like quotes they provide verbatim correctness, but they also are indeed asserted, not merely documented.
```turtle
:Denis :called []{":Proposal :literally :Madness"}.
```

<!--  
Literalization: an assertion is made, but IRIs are interpreted *verbatim* so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3.
-->

#### Nested Named Graphs with Regular RDF Semantics
For completeness lets establish that standard nested named graph have standard RDF semantics. So in the following nested named graph
```turtle
[]{ :Alice :buys :Car .}
```
the statement `:Alice :buys :Car` is interpreted exactly as if stated in a regular RDF graph.



## Defining a Semantics

A [vocabulary](configSemantics.md) is provided to define the precise semantics of `REPORT`, `RECORD`, `Quote`  
[TODO] we should actually do that in the vocabulary definition above  
and some other configurations like e.g. closed world and unique name assumption. We envision extensions of this mechanism towards e.g. lists and other shapes with more predictable properties than the open world semantics of RDF can provide, and also for close-to-the-metal applications like versioning, verifiable credentials, etc.

Such semantics will not have the benefit of built-in syntactic sugar nor the pre-defined semantics indicators, but they can still be encoded quite concisely, using the square bracket syntactic sugar together with namespaced identifiers, e.g.
```turtle
:Bob :claims [nng:APP]":s :p :o.  :a :b :c"
```
if an unabbreviated form
```turtle
:Bob :claims [ nng:includes ":s :p :o. :a :b :c"^^nng:GraphLiteral 
               nng:semantics nng:App ] 
```
is considered too verbose.
