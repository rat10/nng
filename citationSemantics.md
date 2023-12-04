# Citation Semantics

<!--

TODO  at least a quote

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


[]{...}                 include nested
[]{"..."}               include record
[]"{...}"               include report
[]"..."                 include quote
[ex:Yps]"..."           include Yps
[rdf:nil]"..."          include undefined
"..."^^nng:ttl          not included but queryable
"..."^^xsd:string       don't bother

-->



RDF literals can be used to introduce RDF with non-standard semantics into the data. Many such semantics are possible, like un-assertedness, referential opacity, closed world assumption, unique name assumption, combinations thereof, etc. This section concentrates on different kinds of citation. The section on [Configurable Semantics](configSemantics.md) discusses other options.

### Specifying Inclusion Semantics

NNG provides maybe a bit too much different ways to specify the semantics of an inclusion.

#### Separate nng:semantics Statement
To introduce a graph with specific semantics it is *included* from a graph literal, e.g.:
```turtle
:Alice :said [ nng:includes ":s :p :o. :a :b :c"^^nng:ttl 
               nng:semantics nng:Quote ] 
```
The semantics of the inclusion specify which operations may be performed on the included graph. A quoted inclusion for example is not amenable to entailments and is not asserted either.

#### Combined Inclusion+Semantics Statement
To prevent problems with monotonicity, specific inclusion properties for each semantics can be specified, e.g.
```turtle
:Alice :said [ nng:quotes ":s :p :o. :a :b :c"^^nng:ttl ]
```
This provides an extra guarantee that no entailments are derived from the included graph before a semantics configuration has been retrieved that might forbid such an operation. 

#### Specifying Inclusion Semantics Inline
To provide even more comfort, specific semantic modifiers like eg. `nng:Quote` can be defined and prepended to a graph literal (also omitting the datatype declaration), creating a nested graph with the specified semantics: 
```turtle
:Alice :said [nng:Quote]":s :p :o. :a :b :c"
```

#### Ultimate Syntactic Sugar to Specify Citation Semantics
To provide yet more comfort, special notations are provided to specify a select set of citation semantics, e.g.:
```turtle
:Alice :said []":s :p :o. :a :b :c"  # quote signs without {} signify nng:Quote
```
The next section will present all pre-configured semantics with their keywords and notations. 



## Citation Configurations

The RDF*/star Community Group was quite determined that an annotation device should also provide means to document unasserted assertions and that references to the annotated triples should be referentially opaque. Not all of this made sense to us and some of it we found indeed rather dangerous in the context of annotation, but the needs so expressed nonetheless make sense. We therefore strived to provide a sound mechanism to express the most common forms of citation in a succinct and well-structured way.

Special keywords and notations are introduced to support the most common use cases:
- reporting assertions without asserting them,
- providing records of assertions with lexical accuracy and
- quoting statements with lexical accuracy, but without asserting them. 
This boils down to two aspects - an assertion may be asserted or not, and it may be interpreted or not - and four categories:

``` 
                 | referentially    | referentially
                 | transparent      | opaque
-----------------|------------------|---------------
  asserted token | (NESTED) RDF     | RECORD      
                 | []{ :s :p :o }   | []{" :s :p :o "}
-----------------|------------------|---------------
 unasserted type | REPORT           | QUOTE    
                 | []"{ :s :p :o }" | []" :s :p :o "

NESTED  asserted token, referentially transparent 
        (a graph, nested or not, no literal involved, i.e. standard RDF)
REPORT  unasserted type, referentially transparent 
        (reported speech, akin to RDF standard reification as used "in the wild")
RECORD  asserted token, referentially opaque 
        (interpreted, but without co-denotation)
QUOTE   unasserted type, referentially opaque
        (like verbatim quoted speech, and not endorsed)

LITERAL last not least the bare graph literal
        ":s :p :o."^^nng:ttl
        since it is not included, it is also not named by a blank node
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
A few examples may illustrate the use cases for these semantic configurations. All these configurations have one thing in common: they are [queryable](querying.md) in SPARQL. However, a query will have to explicitly include them so that unasserted quotes can't pop up in unassuming result sets.


### "Unasserted Assertion"

Unasserted assertions are a niche but recurring use case that so far isn't properly supported in RDF. Many participants of the RDF-star CG strongly argued in its favour. The intent is to document assertions that for some reason one doesn't want to endorse, e.g. because they are outdated, represent a contested viewpoint, don't pass a given reliability threshold, etc.

The RDF standard reification vocabulary is often used to implement unasserted assertions, but the specified semantics don't support this interpretation and its syntactic verbosity is considered a nuisance. A semantically sound and at the same time easy to use and understand mechanism would be a useful addition to RDF's expressive capabilities.

However, the semantics of existing approaches in this area, like RDF standard reification and RDF-star, differ in subtle but important aspects. NNG supports two kinds of unasserted assertions: *reports* with standard RDF referentially transparent semantics, and *quotes* with referentially opaque semantics.


#### Report
Reports resemble indirect speech in natural language. The aim is not to reproduce a statement in verbatim equivalence, but only to document the meaning of it. Like quotes reports are not actually asserted, but in any other respect they perform like regular RDF. We might for example neither want to endorse the following statement nor might we want to claim that this were Bob's words verbatim:
```turtle
:Bob :said []"{ :Moon :madeOf :Cheese }" .
``` 
This reports but doesn't assert Bob's claim. The IRIs refer to things in the realm of interpretation, they are not a form of quotation. Bob may have a used an IRI from Wikipedia to refer to the moon and the report would still be correct. This semantics is very similar to that of RDF standard reification.

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
:Bob nng:states ":Moon :madeOf :Cheese"^^nng:ttl .
```
Again, the graph literal is not asserted (and we have no intention to do so), but we are also not bound or even fixated on its syntactic accuracy. We just get along the fact.

To be free in the choice of properties, the following modelling primitive can be used:
```
:Bob :uttered [
    rdf:value ":Moon :madeOf :Cheese"^^nng:ttl ;
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
:UC rdf:value " :x :y :z ."^^nng:ttl ;
    :status :UnConfirmed .
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
[]{ :s :p :o } nng:statedAs ":S :p :O"^^nng:ttl .
```
In the following example the literal is accompanied by a hash value to improve security:
```
[]{ :s :p :o } nng:statedAs [
    rdf:value ":S :p :O"^^nng:ttl ;
    nng:hash "4958b2dad87fef40b4b4c25ab9ae72b2"^^MD5
]
```
Note that while the graph literal is accompanying an assertion of the same type, itself it is unasserted.



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
For completeness lets establish that standard nested named graphs have standard RDF semantics. So in the following nested named graph
```turtle
[]{ :Alice :buys :Car .}
```
the statement `:Alice :buys :Car` is interpreted exactly as if stated in a regular RDF graph.

And the following code includes a graph literal as nested graph:
```turtle
:Doug :knows [ nng:includes ":Earth a :Sphere"^^nng:ttl ;
               nng:semantics nng:NestedGraph ]
```



## Defining a Semantics

A [vocabulary](configSemantics.md) is provided to define the precise semantics of `REPORT`, `RECORD`, `QUOTE`  
<!-- 
    TODO we should actually do that in the vocabulary definition above -->
and some other configurations like e.g. closed world and unique name assumption. We envision extensions of this mechanism towards e.g. lists and other shapes with more predictable properties than the open world semantics of RDF can provide, and also for close-to-the-metal applications like versioning, verifiable credentials, etc.

Such semantics will not have the benefit of built-in syntactic sugar nor the pre-defined semantics indicators, but they can still be encoded quite concisely, using the square bracket syntactic sugar together with namespaced identifiers, e.g.
```turtle
:Bob :claims [nng:APP]":s :p :o.  :a :b :c"
```
if an unabbreviated form
```turtle
:Bob :claims [ nng:includes ":s :p :o. :a :b :c"^^nng:ttl 
               nng:semantics nng:App ] 
```
is considered too verbose.

