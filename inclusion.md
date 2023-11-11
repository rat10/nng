```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        
check again

```

# RDF Literals and Inclusion

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
:Alice :said ":s :p :o. :a :b :c"^^nng:Graph .
":s :p :o. :a :b :c"^^nng:Graph :assertedSoFar :zeroTimes .
```
Graph literals are the basic building block from which any specific semantics configurations can be derived. The respective mechanism is called *inclusion* and will be presented next.

We [might](https://github.com/rat10/sg/issues/2) also define a term literal datatype, e.g.:
```
"ex:Superman"^^nng:term
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
# DEFINITION

nng:GraphLiteral a rdfs:Class ;
    rdfs:comment "A literal whose datatype matches the enclosing RDF document, e.g. NNG, Turtle, TriG or JSON-LD".
```
We will in the following define ways in which the RDF contained in those literals can be introduced into the realm of interpretation. To that end it has to be ensured that query and reasoning engines can access the data contained in graph literals if applicable, i.e. they have to be able to parse RDF literal data types as if they were standard RDF data IFF the including property linking to those literals suggests so. 

> [NOTE] 
>
> Blank nodes in graph literals are always scoped to those literals and can’t be shared with outside RDF data. Anything else would be quite involved to implement and also wouldn't make much sense, as the meaning of an existential is defined by its attributes and those are local to the literal. Graphs provide the means to include all attributes that are relevant to define the meaning of an existential. If an existential is still considered important enough to share it with data outside the graph literal, it has to be skolemized - that seems like a reasonable demand.


## Configurable Semantics

RDF literals can be used to introduce RDF with non-standard semantics into the data. Many such semantics are possible, like un-assertedness, referential opacity, closed world assumption, unique name assumption, combinations thereof, etc. To introduce a graph with specific semantics, it is *included*, e.g.:
```
:Alice :said [ nng:includes ":s :p :o. :a :b :c"^^nng:Graph 
               nng:semantics nng:Quote ] 
```
If no semantics is specified, the graph literal is included according to regular RDF semantics, just like `owl:imports` includes an RDF file into a graph. Just like an ontology imported via `owl:imports` the included graph can not be modified in the including graph. 
[TODO] scrub this?

The semantics of the inclusion specify which operations may be performed on the included graph. A quoted inclusion for example is not amenable to entailments and is not asserted either.

To prevent problems with monotonicity, specific inclusion properties for each semantics can be specified, e.g.
```
:Alice :said [ nng:quotes ":s :p :o. :a :b :c"^^nng:Graph ]
```
This provides an extra guarantee that no entailments are derived from the included graph before a semantics configuration has been retrieved that might forbid such an operation. 

To provide even more comfort, specific semantic modifiers like eg. QUOTE can be defined and prepended to a graph literal (also omitting the datatype declaration), creating a nested graph with the specified semantics: 
```
:Alice :said [QUOTE]":s :p :o. :a :b :c"
```
To provide yet more comfort, special notations are provided, e.g.:
```
:Alice :said []":s :p :o. :a :b :c"
```
The next section will present all pre-configured semantics with their keywords and notations. 



## Semantics Configurations
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


### Examples
A few examples may illustrate the use cases for these semantic configurations. All these configurations have one thing in common: they are queryable in SPARQL (although, depending on configuration, a query might have to explicitly ask for them).


#### Unasserted Assertion

Unasserted assertions are a niche but recurring use case that so far isn't properly supported in RDF. Some participants in the RDF-star CG strongly argued in its favour. The intent is to document assertions that for any reason one doesn't want to endorse, e.g. because they are outdated, represent a contested viewpoint, don't pass a given reliability threshold, etc.

The RDF standard reification vocabulary is often used to implement unasserted assertions, but the specified semantics don't support this interpretation and its syntactic verbosity is considered a nuisance. A semantically sound and at the same time easy to use and understand mechanism would be a useful addition to RDF's expressive capabilities.

However, the semantics of existing approaches in this area, like RDF standard reification and RDF-star, differ in subtle but important aspects. NNG supports two kinds of unasserted assertions: *reports* with standard RDF referentially transparent semantics, and *quotes* with referentially opaque semantics.


##### Report
Reports resemble indirect speech in natural language. They don't claim verbatim equivalence but only document the meaning of some statements. Like quotes they are not actually asserted, but in any other respect they perform like regular RDF. We might for example neither want to endorse the following statement nor might we want to claim that this were verbatim Bob's words:
```
:Bob :said "{ :Moon :madeOf :Cheese }" .
``` 
This reports but doesn't assert Bob's claim. However, the IRIs refer to things in the realm of interpretation, they are not a form of quotation. Bob may have a used an IRI from Wikipedia to refer to the moon and the report would still be correct.
<!--
In some cases the syntactic fidelity of straight graph literals can be problematic. We might want to document that Bob made the claim that the moon is a big cheese ball, but we don't know the exact terms he uttered. We don't know if he said `:Moon` or `:moon` and we don't want to give the impression that we do, nor do we want to be dragged into arguments about such detail.
The semantics of RDF standard reification captures this intuition as it doesn't refer to the exact syntactic representation, it is not quotation. Instead it denotes the meaning, like any triple does per the RDF semantics: it refers not to the identifier `:Moon` but to Earth's moon itself. This intuition guides the definition of the following property:
-->

##### Quote
Quotes are used to document statements with lexical precision, but again without endorsing them. One may imagine a written statement issued to a court, or documenting a conversation where the precise account of the actual wording used is important. This may be useful for use cases like versioning, explainable AI, verifiable credentials, etc. The example somehow unrealistically assumes that Bob speaks in triples, but note the emphasis on `:LOVE` that the quote preserves:
```
:Bob :proclaimed []":i :LOVE :pineapples" .
```
Likewise, quotation semantics suppresses any transformations that are common in RDF processes to improve interoperability, e.g. replacing external vocabulary with inhouse terms that refer to the same meaning, entailing super- or subproperty relations or even just some syntactic normalizations.
<!--
A graph literal represents a quote, documenting with syntactic fidelity the assertion made (although the example somehow unrealistically assumes that Bob speaks in triples).
In a more specific arrangement we might want to document the revision history of a graph or implement an explainable AI approach. Here we aim to actually assert a statement, but also to document its precise syntactic form before any transformations or entailments. Such transformations are common in. However, sometimes it is desirable to retain the initial state of an assertion.
-->


##### Literal
The bare literal, besides its function as a building block for the inclusion mechanism, may find uses on its own, e.g. to keep graphs around that have not been properly defined yet
```
:Gx rdf:value " :x :y :z ."^^nng:Graph ;
    :status :Unconfirmed .
```


##### Term Literal
So far only graph literals have been discussed, but also term literals might provide interesting applications. The well known Superman-problem could be expressed as follows:
```
:LoisLane :loves [QUOTE]":Superman" .
```
Note how references to Lois Lane and the concept of loving are still referentially transparent, as they should be. However, support for graph terms is still an open [issue](https://github.com/rat10/sg/issues/2).


#### "Asserted assertions"

##### Record / Literalization
Records do introduce statements into the universe of interpretation, but they don't allow the interpretation to diverge from the lexical form. They are meant to be interpreted "literally". So like quotes they provide verbatim correctness, but they also are indeed asserted, not merely documented.

Similar semantics have been proposed in Notation3 for so-called formulas and by the RDF-star Community Group report for so-called quoted triples. In both those proposals however the statements are not asserted.
<!--  
Literalization: an assertion is made, but IRIs are interpreted *verbatim* so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3.
-->

##### Nested Named Graphs with Regular RDF Semantics
For completeness lets establish that standard nested named graph have standard RDF semantics. So in the following nested named graph
```
[]{ :Alice :buys :Car .}
```
the statement `:Alice :buys :Car` is interpreted exactly as if stated in a regular RDF graph.



## Defining a Semantics

A [vocabulary](vocabulary.md) is provided to define the precise semantics of `REPORT`, `RECORD`, `QUOTE` and some other configurations like e.g. closed world and unique name assumption. We envision extensions of this mechanism towards e.g. lists and other shapes with more predictable properties than the open world semantics of RDF can provide, and also for close-to-the-metal applications like versioning, verifiable credentials, etc.

Such semantics will not have the benefit of built-in syntactic sugar nor the pre-defined semantics indicators, but they can still be encoded quite concisely, using the square bracket syntactic sugar together with namespaced identifiers, e.g.
```
:Bob :claims [nng:APP]":s :p :o.  :a :b :c"
```
if an unabbreviated form
```
:Bob :claims [ nng:includes ":s :p :o. :a :b :c"^^nng:Graph 
               nng:semantics nng:App ] 
```
is considered too verbose.



## Naming an Included Graph Literal

All examples above used anonymous nested graph literals. Explicit naming can be implemented via property lists, e.g.
```
[rdfs:label ex:X; nng:semantics nng:QUOTE]":s :p :o"
```
This is a bit awkward, but providing more syntactic sugar for such a corner case would seem quite a stretch.




## Transclusion, Inclusion and `owl:imports``

[TODO] scrub transclusion and move definitions to vocabulary



#### Import via Inclusion

Inclusion offers the possibility to parse a graph literal and add its content into a graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements. This works very much like `owl:imports` for ontologies and the respective property, `nng:includes`, is named to allude to that similarity.

Importing a literal into a graph doesn't create a nested graph but includes the statements from the graph literal into a graph. The including graph may be explicitly named or referenced as the local graph.

The following example includes a graph literal into another graph (local or not):
```
ex:Graph_1 nng:includes ":s :p :o . :u :v :w ."^^nng:Graph .
```
To include a graph literal into the local graph a syntactically more elegant approach is available, using a self-referencing identifier, `this` (see the page on [mappings](mappimg.md)), to refer to the enclosing nested graph:
```
THIS nng:includes ":s :p :o . :u :v :w ."^^nng:Graph .
```
Inclusion means that the graph can be assumed to contain the statements from the included literal. Those statements therefore can not only be queried but also reasoned on, new entailments can be derived, etc. However, new entailments can not be written back into the graph literal. Therefore the only guarantee that this mechanism provides is a reference to an original state.

Inclusion may also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages. We envision such applications w.r.t. [shapes](ramblings/shapes.md).


#### Import via Transclusion

Transclusion in the most basic arrangement only includes by reference, meaning that a transcluded graph is asserted and can be queried, but it is referentially opaque and no entailments can be derived - blocking any kind of change to and inference on the transcluded data, much like the semantics of Notation3 formulas and RDF-star triple terms per the semantics presented in the CG report, as in the following example:
```
THIS nng:transcludes ":s :p :o"^^nng:Graph .
```

However, transclusion also makes it possible to configure the semantics of transcluded graph literals. Mediating access through the transclusion property guarantees that such semantics arrangements are obeyed and no unintended entailments can leak into transcluding graphs. Configurable semantics are discussed in detail only later [below](#configurable-semantics), so a simple example has to suffice here:
```
THIS nng:transcludes [
    rdf:value ":s :p :o"^^nng:Graph ;
    nng:semantics nng:APP
] .
```
An additional annotation with a semantics attribute, in this case `nng:APP`, can loosen the very restrictive base semantics to arrange for use cases driven by e.g. application intuitions like a Closed World Assumption, an Unique Name Assumption, etc.
