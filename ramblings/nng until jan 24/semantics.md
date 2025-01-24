# Semantics

This proposal aims to provide nested graphs with a solid semantics that is both easy to use and formally well defined.
Barring more specific arrangements - introduced in section [Configurable Semantics](#configurable-semantics) below - all nested statements are asserted and referentially transparent, i.e. nested or not, they are regular RDF statements governed by standard RDF semantics.

Naming every nested graph may be felt as a departure from the set-based intuitions of RDF on the surface, but at the core it is not, as will be discussed [below](#types-and-sets). On the surface however the hope is that this approach enables the reconciliation of integration focused design aspects of RDF (which is concerned with types of statements) and application-driven intuitions of practitioners (which often focus on individual occurrences of such types). Such an outcome would be a notable improvement over the status quo, where all too often "practitioners" feel bossed around by "semanticists" for no good reason, and therefore well worth the effort.


## A Very Regular Semantics, Asserted and Referentially Transparent

In our approach nested graphs are both asserted and referentially transparent, i.e. statements in nested graphs follow the regular RDF semantics and are interpreted, i.e. part of the domain of discourse. This differentiates our take on nested graphs from other well-known approaches like RDF standard reification, formulas in Notation3, the original proposal for Named Graphs by Carroll et al 2005, and RDF-star.
Those approaches in our opinion try to solve too many problems at once, overloading a meta-modelling mechanism - which itself is sorely lacking from RDF - with very specific semantic tooling that make it unnecessarily hard to use for any mainstream use case. The results of that overloading have been mixed: Notation3 remained a niche application of interest mainly to logicians, named graphs as implemented and used in the wild didn’t follow the semantics as proposed by Carroll at al and the proposed RDF-star semantics is met with a lot of scepticism and doesn't meet the use case requirements. 

We do not intend to diminish or contest the value of such advanced semantic operators, but we think that separating specialist needs like syntactically faithful representation, configurable semantics and modalities from the basic representational construct is in everybody's best interest: it keeps the basic construct easy to use for basic needs like grouping and administrative annotations, and increases the probability that involved semantics, when applied via reserved constructs, do actually reflect the users' intent and are properly understood and followed. 

Following the 80/20 design principle we propose to implement non-standard semantics via a special instrument extending nested graphs expressivity, ascribing them to the nested graph via a syntactic extension. That syntactic instrument will be discussed in section [Configurable Semantics](#configurable-semantics) below. It is based on graph literals implemented as a new datatype in RDF, a proposal first made more than a decade ago.


## Graph sources

Graphs as defined in RDF are a mathematical abstraction and an RDF Graph is defined as a set of RDF statements, i.e. the statements themselves define a graph. Practical issues like the need to name a graph or refer to it are not defined. There also is no formal notion of a graph that is changing over time. However, the concept of a graph understood as a *source* is informally introduced. The specification of RDF 1.1 Concepts and Abstract Syntax in section 1.5 on [RDF and Change over Time](https://www.w3.org/TR/rdf11-concepts/#change-over-time) says: "We informally use the term *RDF source* to refer to a persistent yet mutable source or container of RDF graphs. An RDF source is a resource that may be said to have a state that can change over time. A snapshot of the state can be expressed as an RDF graph. For example, any web document that has an RDF-bearing representation may be considered an RDF source. Like all resources, RDF sources may be named with IRIs and therefore described in other RDF graphs."

This concept guides our intuition about the relation between a nested graph and its name. A nested graph has a certain amount of identity: it serves a purpose, providing a description composed of one or multiple statements. That description may change over time by adding, updating or removing statements and yet, by being collected within the same nested graph, it has identity as being the description of an entity of some kind.
As hinted at in the specification, a fitting analogy might be a web page with some embedded RDFa data, or a file with RDF data serialized as Turtle, or a SPARQL endpoint returning a set of triples in response to a certain query. All those data sources may change over time, and their identity is constituted by them referring to some entity in the real world via their name and address. 
The name itself however is defined to have no meaning, just like all IRIs are treated in RDF. Of course, in practice IRIs often carry meaning, but as customary in logic in general and in RDF model theory specifically, it is ignored here.

In other words, the name of a nested graph refers to what the graph is about. The triples enclosed by a pair of curly brackets may change without the graph name changing. It is the responsibility of the author to ensure the creation of a new identifier if the topic of the graph changes. One might aim for a design more focused on immutability, where a graph name changes whenever the statements it contains change, but that is beyond the scope of this proposal. 

Consequently, two graphs by different names but containing the same set of triples are two different graphs. However, no two graphs by the same name can exist - irrespective if the triples they contain are the same or not - and the statements they contain will be merged into one graph by that name (the usual considerations w.r.t. [union or merge](https://www.w3.org/TR/rdf11-mt/#shared-blank-nodes-unions-and-merges) of blank nodes apply).


## Types and Sets

The RDF model theory is based on sets, as is customary in model-theoretic formalizations. Sets also intuitively provide a solid foundation for RDF, as one of its foci is on integration and re-use of data from disparate sources, where the stated fact itself - *what* is being said - is of primary importance and not why it was said, by whom, how many times etc.

However, many scenarios would benefit from a more instance-focused approach.
Applications often disambiguate occurrences of facts based on provenance, temporal or spatial criteria, propositional attitudes etc. 
Demanding data modelling cases would like to annotate a main fact with finer detail or additional context, but without burying the main topic in a meandering n-ary construct. 

Such practices shift the focus from the relation type to its instances, thereby getting in conflict with the set-based formalization of RDF. The nested graph approach tries to harmonize the technical foundation with these advanced needs by sticking to sets as the basic formalization, but understanding and implementing statement instances as subsets. That subsetting construct itself is sugar coated - via the default provision of anonymous identifiers - to make it feel like actual instantiation to the user. 


### Sub-Type or Instance

It would be possible to treat the annotated statement either as an instance of a statement of that type or as its subtype. Singleton properties in different papers treated the singleton property first as an instance of the relation, then as a subtype, but in a third paper dodged the question and settled for a rather informally defined "having" relation (for detail see Section 4.2.3.3 in my master thesis [PDF](https://gitlab.com/rat10/between-facts-and-knowledge/-/blob/main/Between_Facts_and_Knowledge_1.0.2.pdf)). 
Since nested graphs can be recursively nested it seems appropriate to define the relation as a subtype relation, honouring the fact that a nested graph can itself again contain nested graphs, etc.

> [NOTE] 
>
> Actually there is not so much of a difference between subsetting and instantiation. The distinction is a matter of perspective, of intended usage - a line drawn in the sand. OWL punning for example shows how relative this concept is. We shouldn't be too obsessed with this issue, except that we do of course need to always be clear which perspective we take when we talk about an entity. 

### Set or Bag

The fact that anonymous identifiers are hidden from users in the surface syntax may lead to the impression that nested graphs have bag semantics, i.e. that they allow to state the same statement multiple times. That might give rise to the impression that this proposal breaks with the set-based semantics of RDF. This concern is unfounded, but the intuition of a bag semantics at the surface is intended.
A user may very well note the same nested graph multiple times, for whatever reason that might be, and that will feel and behave exactly like a bag of multiple identical nested graphs. Even if they contain the exact same statement, they will be displayed as separate entities, e.g.:
```
:MyGraph1{ :a :b :c } :d :e .
[]{ :a :b :c }
[]{ :a :b :c }
```
However, since each nested graph it identified by its own identifier - blank node or IRI -, they technically and semantically are different nested graphs, and a graph containing a number of such seemingly identical nested graphs is still a set (although applications may choose to lean identical anonymous nested graphs).


### Unification of Nested Graphs

There exist of course multiple ways and reasons to reduce the verbosity of this arrangement:

- applications may decide to unify nested graphs containing the same statements if they do not want to keep count of such instances. 
- applications may decide to lean a result set that contains the same statement with different, but in the context of the query irrelevant annotations.
- applications may materialize "views" in which duplicate nested graphs are suppressed, because the view does not take into account the annotations that differentiate them.

All those arrangements generate dimensionally reduced sets, either on the fly for queries, or as an additional view, or permanently by deletions and updates in the data.
Early/eager unification of duplicate nested graphs will reduce complexity in the data, but might loose detail compared to late unification in generated views or query results. It depends again on the needs of applications which path they should choose.
Crucially this proposal allows to postpone that decision as long as suitable, contrary to the standard RDF approach which at least in theory favours eager and early unification.


#### Anonymous Nested Graphs

Nested graphs that have not been explicitly named by the user are implicitly identified by automatically provided blank nodes. This makes them subject to RDF's rules for the handling of blank nodes, especially the choice between union and merge, that only an application can sensibly make. Consequently it is also an application decision if two anonymous nested graphs with the same content get merged into one nested graphs or if they are differentiated by providing them with different (blank node) names.
In the example of the section on [naming](#naming) above it would be the decision of the application if the anonymous nested graph `_:g6` is leaned away or kept around. An OWL reasoner (establishing an application environment itself) will always lean them, in a SPARQL query 'counting semantics' will probably be applied and both instances returned - both approaches are possible and viable. This follows the well-known path of blank node treatment in RDF: leaning is possible, but not required.

This can intuitively be understood as a late binding approach to set based data integration: statements, even if they are of the same type, are kept separate as long as it is not clear that they can safely be merged because what differentiated them at some point may no longer be of importance.
It may well be that applications decide to keep different instances of the same statement around for a long time and unify them only in response to queries, e.g. a query that doesn't ask for specific instances of the same type of triple may be shown only the type, once - maybe amended by a hint to different instances and how they differ. Contrast that with the early binding of RDF, that rather favours early optimization of integration over fine-grained differentiation. 

In RDF the focus on early optimization for the sake of performant and sound integration tends to collide with application specific intuitions, creating tensions and the need for workarounds and out-of-band solutions. The discrepancy between the theoretical focus on leaning e.g. in reasoning and the practical focus on instances e.g. in querying is something that RDF won't be able to get rid of, as it reflects the different needs of integration (favouring types) and application (working  instances) of data. We hope that the Janus-faced treatment of types with nested graphs provides a more intuitive formalization, resulting in sounder practical applications.


#### Explicitly Named Nested Graphs

The arrangement described so far mainly concerns anonymous nested graphs. OTOH it is also possible and probably often favorable, to explicitly name nested graphs, as this allows for easier reference of graph structures across the boundaries of line based serializations. However, explicit naming has to follow a few rules. The following set of explicitly named nested graphs would be illegal, as no two nested graphs by the same name are allowed in one set, no matter if they contain the same set of statements or not:
```
:MyGraph___1{ :a :b :c } :d :e .
:ThisGraph_2{ :f :g :h } 
:ThisGraph_2{ :i :k :l }          # illegal
:ThatGraph_3{ :m :n :o } 
:ThatGraph_3{ :m :n :o }          # illegal
```
Applications that encounter multiple graphs by the same name, e.g. when merging data from multiple sources, should merge those graphs into one composed of the superset of the statements they contain. However, this is not a strict rule and applications may also choose to rename those graphs and all references to them in the respective sources. A reason for such an approach might be that it is evident from context that the names of those nested graphs were rather arbitrarily chosen and the graphs describe very different entities.
Of course, two graphs by the same name and the same content and without differentiating annotations should just be merged. If however e.g. their provenance is to be recorded, renaming them would probably be more advisable.


### ForEach, ForAll, "ForItself"

It is not per se evident what an annotation to a graph is meant to refer to precisely and the spectrum of intuitions is wide. The annotation might be meant to refer to:

- the whole nested graph construct itself,
- all triples contained in that graph, individually, like in a `for each` loop,
- every individual term in every triple, as another interpretation of `for each`,
- or sometimes just a specific triple, or term, which a human user might easily be able to recognize by context or by the domain of the attributing relation.

Intuitions will inevitably vary, depending on the use case at hand. Leaving the question unanswered is an imprecision that can be helpfully convenient at times.
Notation3 for example takes that approach with lists, leaving it undefined if an attribution to a list means the list itself or its members.
Our proposal extends that approach by making such vagueness the convenient default - to not get in the way of applications that don't need more expressivity - but provides an additional facility to address an entity with more specificity, see the section on [Fragment Identification](#fragment-identification) below. 


## Qualification 

> [NOTE] 
>
> In a recent conversation with Enrico I got the impression that I'm running into open doors with the following discussion. The third example in [RDF-star behaviours](https://github.com/w3c/rdf-star-wg/wiki/Semantics%3A-Behaviour-catalogue#example-cases-in-concrete-syntax) seems to reflect the exact same intuition. In the Community Group however the following interpretation didn't seem to be shared by everybody.

Nested graphs promote the unannotated core of an assertion to the front, while keeping its more detailed and annotated refinement nearby and in reach.

Annotating statements is often argued to be unacceptable in RDF as it would jeopardize monotonicity: one of the basic principles of the RDF semantics is that no statement is allowed to rule into the truth value of another statement.
However, even in the very popular use case of provenance an annotation may be able to influence the perception of the validity of a statement - just imagine the source being a notorious peddler of fake news - and therefore be considered non-monotonic.
RDF standard reification avoids the semantic issue by referring not to the statement type or an actual instance, but rather to the *event* that some statement was stated (which it describes via the reification quad).
Singleton properties take a different approach in that they state an annotated fact in its own right, but allow to entail the unannotated fact from the singleton property instance/subtype.
Our proposal takes that approach one step further by syntactically promoting the unannotated supertype to the front, whereas the annotated subtype is only hinted at via the annotations themselves.

Take for example the following annotated fact:
```
[]{ 
    []{:Obama :presidentOf :USA} :from 2008; :until 2016 .
} :source :Wikidata .
```
The fact that that statement about Obama's presidency occurs in a nested graph (which itself is nested inside another nested graph) doesn’t cut into its truth value in any way, nor does the fact that it is itself annotated. 
Its nesting context certainly provides more information about it, which again may lead to further conclusions, etc. - but this glass is always considered half full, never half empty: more detail doesn’t mean less validity of the more general fact in the nested graph.

This proposal strictly takes the stand that annotating a statement *adds* information. This doesn't cut into the validity of the statement itself. Granted, it does cut into the number of worlds in which this statement is true. That however is the whole purpose of RDF: any additional statement to a graph (or, in theory at least, for the whole of RDF data out there, anywhere) makes the description of the world more precise, and that's exactly what we should be after. 
The one thing that definitely is forbidden is too call another statement false. Any other attribution however is fair game.

Put another way: no description is ever complete - there is always more to know, more detail to consider, more context to take into account. That doesn’t - and in RDF is explicitly forbidden to - diminish the validity of the un-annotated, un-detailed, un-contextualized basic fact, encoded as a simple single triple. It does however require a certain restraint when interpreting data. A statement like ":Obama :presidentOf :USA" should never be interpreted as to be valid *now* unless such detail is explicitly provided or can be concluded from the application environment. A useful general guideline to interpreting data might be to "curb your enthusiasm", i.e. don’t read more into a statement than is actually provided. Of course the way properties are named often supports certain unfounded intuitions, but OTOH who would want to replace `:presidentOf` with an annoyingly correct`:isOrWasOrWillBePresidentOf`, etc.

Since the topic of qualification is quite contested we would like to illustrate this seemingly obvious point with one more example:
```
:a :b :c ;
   :o :p .
```
Nothing in the definition of RDF would support the claim that the truth value of the first statement `:a :b :c` is changed by the second one, `:a :o :p`, although the second statement clearly may change our view on `:a` which again may change our interpretation of `:a :b :c`.
The same intuition applies to statement annotations: they just add more detail.

To offer yet another approach: the semantically soundest way to annotate statements in RDF would be to replace every node in a statement by a blank node, attribute those blank nodes with a primary value (using e.g. `rdf:vale` or `rdf:type` or `rdfs:subClassOf` and `rdfs:subPropertyOf` as properties) and add annotations as further attributes. An existential is a very malleable entity ;-) Of course this would be unreasonably verbose. It is reasonable to provide syntactic sugar - which is exactly what we propose with nested graphs - but we hope to have clarified that such syntactic sugar is semantically standing on solid ground. The next section will present different approaches to implementing a mapping from nested graphs to standard RDF 1.1 triples and named graphs.
