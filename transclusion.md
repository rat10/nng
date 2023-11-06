
# RDF Literals and Transclusion

RDF literals serve to enable use cases with non-standard semantics.



## Graph Literal and Term Literal

We define a graph literal datatype, e.g.
```
":s :p :o. :a :b :c"^^sg:Graph
```
which represents the 
- referentially opaque
- unasserted
- type
of an RDF graph.

It can be used like in the following, quite uninspiring example:
```
:Alice :said ":s :p :o. :a :b :c"^^sg:Graph .
":s :p :o. :a :b :c"^^sg:Graph :assertedSoFar :zeroTimes .
```
Graph literals are the basic building block from which any specific semantics configurations can be derived. The respective mechanism is called *transclusion* and will be presented next.

We [might](https://github.com/rat10/sg/issues/2) also define a term literal datatype, e.g.:
```
"ex:Superman"^^sg:term
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

We take up the approach because we consider it ideally suited to implement different semantics via configurable transclusion.

To that end we introduce the Graph Literal class:
```
DEF

sg:GraphLiteral a rdfs:Class ;
    rdfs:comment "A literal whose datatype matches the enclosing RDF document, e.g. SG, Turtle, TriG or JSON-LD".
```
We will in the following define ways in which the RDF contained in those literals can be introduced into the realm of interpretation. To that end it has to be ensured that query and reasoning engines can access the data contained in graph literals if applicable, i.e. they have to be able to parse RDF literal data types as if they were standard RDF data IFF the transcluding property linking to those literals suggests so. 

> [NOTE] 
>
> Blank nodes in graph literals are always scoped to those literals and can’t be shared with outside RDF data. Anything else would be quite involved to implement and also wouldn't make much sense, as the meaning of an existential is defined by its attributes and those are local to the literal. Graphs provide the means to include all attributes that are relevant to define the meaning of an existential. If an existential is still considered important enough to share it with data outside the graph literal, it has to be skolemized - that seems like a reasonable demand.


## Configurable Semantics

RDF literals can be used to introduce RDF with non-standard semantics into the data. Many such semantics are possible, like un-assertedness, referential opacity, closed world assumption, unique name assumption, combinations thereof, etc. To introduce a graph with specific semantics, it is *transcluded*, e.g.:
```
:Alice :said [ sg:transcludes ":s :p :o. :a :b :c"^^sg:Graph 
               sg:semantics sg:Quote ] 
```
If no semantics is specified, the graph literal is transcluded according to regular RDF semantics, just like `owl:imports`` transcludes an RDF file into a graph. Just like an ontology imported via `owl:imports` the transcluded graph can not be modified in the transcluding graph. The semantics of the transclusion specify which operations may be performed on the transcluded graph. A quoted transclusion for example is not amenable to entailments and is not asserted either.

To prevent problems with monotonicity, specific transclusion properties for each semantics can be specified, e.g.
```
:Alice :said [ sg:transcludesQuote ":s :p :o. :a :b :c"^^sg:Graph ]
```
This provides an extra guarantee that no entailments are derived from the transcluded graph before a semantics configuration has been retrieved that might forbid such an operation. 

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
        " :s :p :o "^^sg:Graph
        since it's not transcluded it is also not named by a blank node
            and the datatype declaration can't be omitted
        really just a datatyped string, but on demand accessible by a SPARQL engine
```


### Examples
A few examples may illustrate the use cases for these semantic configurations.


#### Quote
Quotes are used to document statements with lexical precision, but without endorsing them. One may imagine a written statement issued to a court, or documenting a conversation where the precise account of the actual wording is important. This may be useful for use cases like versioning, explainable AI, verifiable credentials, etc.

#### Record
Records do introduce statements into the universe of interpretation, but they don't allow the interpretation to diverge from the lexical form. So like quotes they provide verbatim correctness, but they also are indeed asserted, not merely documented.

#### Report
Reports resemble indirect speech in natural language. They don't claim verbatim equivalence but only document the meaning of some statements. Like quotes they are not actually asserted, but in any other respect they perform like regular RDF. We might for example neither want to endorse teh following statement nor dow e want to claim that this were verbatim Bob's words:
```
:Bob :said "{ :Moon :madeOf :Cheese }" .
``` 

#### Literal
The bare literal, besides its function as a building block for the transclusion mechanism, may find uses on its own, e.g. to keep graphs around that have not been properly defined yet
```
:Gx rdf:value " :x :y :z ."^^sg:Graph ;
    :status :Unconfirmed .
```

#### Term Literal
So far only graph literals have been discussed, but also term literals might provide interesting applications. The well known Superman-problem could be expressed as follows:
```
:LoisLane :loves [QUOTE]":Superman" .
```
Note how references to Lois Lane and the concept of loving are still referentially transparent, as they should be. However, support for graph terms is still an open [issue](https://github.com/rat10/sg/issues/2).



## Defining a Semantics

A [vocabulary](vocabulary.md) is provided to define the precise semantics of `REPORT`, `RECORD`, `QUOTE` and some other configurations like e.g. closed world and unique name assumption. We envision extensions of this mechanism towards e.g. lists and other shapes with more predictable properties than the open world semantics of RDF can provide, and also for close-to-the-metal applications like versioning, verifiable credentials, etc.

Such semantics will not have the benefit of built-in syntactic sugar nor the pre-defined semantics indicators, but they can still be encoded quite concisely, using the square bracket syntactic sugar together with namespaced identifiers, e.g.
```
:Bob :claims [sg:APP]":s :p :o.  :a :b :c"
```
if an unabbreviated form
```
:Bob :claims [ sg:transcludes ":s :p :o. :a :b :c"^^sg:Graph 
               sg:semantics sg:App ] 
```
is considered too verbose.



## Naming a transcluded Graph Literal

All examples above used anonymous nested graph literals. Explicit naming can be implemented via property lists, e.g.
```
[rdfs:label ex:X; sg:semantics sg:QUOTE]":s :p :o"
```
This is a bit awkward, but providing more syntactic sugar for such a corner case would seem quite a stretch.