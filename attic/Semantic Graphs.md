# Semantic Graphs (SG) - DRAFT



## Abstract

RDF is a knowledge representation formalism optimized for simplicity. Its design favours ease of use and straightforward scalability. However, this simplicity comes at a cost: RDF struggles with complex information needs.
It makes it quite cumbersome to model information that is not so simple, but is rich on facets, detail and context. 
Navigating such involved constructs often requires to first get familiar with their specific modelling choices and style.
Even if the data itself is straightforward, it might lack detail and context when re-used in other applications.
Such use cases - complex information modelling needs like e.g. in fact checking or the cultural heritage domain, and complexity that stems from integrating disparate sources in new, unforeseen applications - struggle with the limited expressivity that RDF provides and have to resort to complicated modelling techniques like involved ontology design patterns and out-of-band means like the only loosely defined named graph mechanism.

This is not to say that RDF doesn’t work well. Indeed it does surprisingly well, on a big scale, with a lot of noteworthy achievements and successes - despite _and_ because of its simplicity. Consequently this simplicity should not be jeopardized. 
However, RDF could well use some tooling to manage complex situations that consistently frustrate users and lead to involved and incompatible workarounds, reducing its attractiveness as knowledge representation formalism and hindering data integration and exchange.

This proposal introduces a set of tools to extend RDF's expressivity in a variety of ways and directions. However, the proposed extensions stay in the background as long as possible. They don’t require to be used, but aim to just be in reach when the need for disambiguation and increased expressivity arises. This restraint is essential not just to ensure backwards compatibility, but also to guarantee that simple tasks remain simple, and the extra tooling to manage complexity doesn’t get in the way of straightforward use cases.


<!-- https://derlin.github.io/bitdowntoc/ -->
[TOC]


## Introduction

The domain of knowledge representation is rich on issues that even with a high degree of thoughtful precision and elaborate tooling can only be mastered imperfectly. No description is ever complete, no formalism can ever comprehensively bridge the gap between what we have in our mind and whatever language we use to express it. If in doubt RDF delegates such intricacies to out-of-band arrangements: it relies on usage and application domains to disambiguate meanings and provide necessary context. 

This approach works well in reasonably aligned environments where data providers and users share roughly the same idea and conceptualization of a domain.
Still, such alignments should not be a requirement, as that would endanger the vision of the Semantic Web as an instrument to re-use self-describing data in unforeseen ways and new types of applications. 
However in practice re-use and interlinking between different application domains seems to be rather the exception than the norm, as e.g. studies on the deployment of `owl:sameAs` in the Linked Open Data cloud suggest. 


> [TODO] 	introduce the most important issues:
> ```
>    meta modelling
>        administrative annotations
>        qualification instead of complicated n-ary relations
>            composition of data into bags, lists, nested structures
>    identification
>        disambiguating IRI references
>        contextualized sameAs
>    application intuitions
>        CWA, UNA
>    reasoning
>        n3
>        rule engines
>        surfaces/FOL
>        explainable AI
> ```
<!---
SNIPPET
Named Graph semantics and practice
Named graphs as specified in [Carroll et al 2005](https://dl.acm.org/doi/10.1145/1060745.1060835) are 
A) referentially opaque and 
B) instances (as only the pair of name and graph fully determines their identity - the same set of triples with a different name constitutes a different named graph). 
Named graphs per RDF 1.1 are 
A) referentially transparent (because what else could they be in the absence of further fixings) and 
B) the semantics of the connection between graph and name is undefined (in practice it is often overloaded by applications that use the name to address the graph but refer to something else, e.g. the topic of the graph). Applications of course have the power to override referential transparency, to fix naming semantics (e.g. in SPARQL the name unequivocally _addresses_ a graph and different named graphs may contain the exact same set of triples), etc. but that is all outside the realm of what RDF specifies and can’t be relied upon in data exchange. 
Named graphs as defined by Carroll et al were designed to extend the expressivity of RDF towards speech act semantics (tailored to faithfully record the syntactic detail of sources). The work provides examples of applications that require faithful representations of RDF data, where meaning is also determined by syntactic detail and e.g. co-denotation is considered a problem rather than a feature.
Named graphs as defined in SPARQL and later RDF 1.1 are designed to help data management. They provide a hook to apply out-of-band application-specific semantics to RDF data. This allows triple store vendors to standardize an essential part of data management without being bothered by the specifics and limitations of RDF. That makes sense, it is widely considered very useful, indispensable even in large applications, and shouldn’t be touched. 
However, not touching that basic arrangement doesn’t mean that this needs to be the end of the story, because this arrangement can be extended without touching the base case. And extending named graphs towards a semantically sound formalisation has always been a goal of those that feel that RDF’s expressiveness is too limited, that n-ary relations are too cumbersome to model involved knowledge structures and that named graphs can provide the missing syntactic sugar for meta-modelling, qualification and grouping of triples.

SNIPPET
A means to explicate the semantics hidden in out-of-band application fixings was pondered by the RDF 1.1 WG already, see [WG Note](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/). It is easy to do and it hurts absolutely nobody, especially not the installed base and not any future installations as long as it isn’t mandatory (which IMO it shouldn’t be). 
It could be used to e.g. describe in the default graph the naming semantics of named graphs, e.g. if their name denotes something else, or merely addresses the graph, or what have you.
It could be used in the default graph or in each named graph to describe the intended referentiality (opaque, transparent, semi-something), 
or the entailment regime (eg RDFS, OWL 2 DL), etc. Entailment regimes can already by described by the [SPARQL Service Description](https://www.w3.org/TR/sparql11-service-description/) vocabulary.
This needs no complicated agreements and nobody is required to conform to such a description. Free-wheeling implementations of RDF 1.1 named graphs can proceed as if nothing happened, others can use this mechanism to implement Notation3 systems or [BLogic/Surfaces](https://www.slideshare.net/PatHayes/blogic-iswc-2009-invited-talk)-inspired First Order Logic reasoners. 
-->

Approaches to these problems have been discussed since the early days of the Semantic Web. Proposals ranged from triple-centric solutions like vocabularies and n-ary design patterns and the infamous RDF standard reification vocabulary to extensions of the triple formalism like quads, nested graphs in Notation3, named graphs as proposed by Carroll et al 2005, named graphs as standardized in SPARQL and later RDF 1.1, a sub-typing mechanism called singleton properties and most recently nested or quoted annotated triples in RDF*/star.
However, none of these approaches was able to hit the sweet spot of enough expressivity combined with ease of use and intuitiveness. RDF standard reification is syntactically verbose and equipped with a rather counter-intuitive semantics. Named Graphs as proposed by Carroll et al and the recent RDF-star proposal come with a very specialized semantics that doesn't meet common needs and expectations. Singleton properties do come with a mainstream semantics, but lack the necessary amount of syntactic sugar. Named graphs as specified in SPARQL and RDF 1.1 lack a formal semantics and are syntactically impoverished as they don't support nesting like their syntactic ancestor, the so-called formulas in Notation3. 
Many more proposals have been brought forward, often targeted as specific problem domains like provenance or temporal/spatial qualification, but failed to garner enough adoption to become a shared de-facto standard.

Our proposal, named SEmantic Graphs, or SEG for short, tries to learn the right lessons from this rich history. It tackles the problem space in steps, the basic building block being a syntactic device to address (sets of) triples. That base serves as the anchor point for more involved constructs to tackle more specific problems. This proposal hopes to employ useful abstractions that group the most important and frequent tasks into a set of different syntactic devices. It aims to keep orthogonal issues separate and thereby reduce the danger of overwhelming the user with too many choices and subtle differentiations.



## Nested Graphs

The most important device missing from RDF is a means to attribute statements. Attribution can come in many different forms and flavors: annotation, contextualization, qualification, administrative housekeeping, mere grouping or any other form of stating something about some statement. RDF doesn't provide a syntactically concise and semantically sound means to that effect. That is where nested graphs come in.

Nested graphs provide the means to address statements, as single statements as well as sets thereof. In their most minimal, but already very useful form they are realized by simply a pair of curly brackets and a preceding pair of square brackets to indicate identity. There semantics is purposefully minimalistic too: they address a snippet of regular RDF data that may change over time, described informally by RDF 1.1 as an RDF *source*. They may be given an explicit name by the user to facilitate attribution, but in their most basic form each pair of curly brackets is identified by a newly minted blank node.

### Characteristics in a Nutshell

Nested graphs are
- asserted
- occurrences/subtypes
- referentially transparent
- independent from named graphs
- all part of the same target graph

Nested graphs have
- configurable semantics
- fine-grained addressing of fragments
- soundly defined semantics via mapping to triples 
- high expressivity that doesn't get into the way of normal tasks
- a default semantics that meets application intuitions without breaking RDF semantics



### Modelling

The main goal of nested graphs is to make it easy to encode and navigate complex information in RDF. This task has many facets: emphasize the main information among all the detail, express administrative as well as modal meta information, inject some basic structure like objects and lists into a meandering graph, preserve context when integrating data, support the need of applications for a more mainstream closed world semantics, etc. It seems that 

#### Cross-cutting Concerns

Nesting of graphs provides much more expressive freedom than the one-dimensional approach of named graphs. Under the hood nested graphs can be implemented straightforwardly with named graphs. On the surface however they provide a much more flexible modelling primitive to work with, as graphs are can be used to model any aspect in parallel. There's no need to decide if they should be used to model provenance or viewpoints or temporality or what have you.

[TODO] 	example

#### Structural Resilience to Change 

Because of implicit flattening, annotating a triple doesn't change the structure of the graph - in this respect this proposal is very similar to the RDFn approach. This is an advantage over n-ary relations, as refining a node doesn't invalidate existing queries. If the refinement has the character of additional detail which doesn't change what's of primary importance, it can very well be added as an annotation to an existing fact and the original fact remains almost untouched - almost, not totally, as it is now enclosed in curly brackets for qualification.

[TODO] 	example

#### Updates on Annotations

This approach to naming can also help with issues like how to manage updates and deletes on annotated data as described e.g. by Lassila et al. in [The OneGraph vision: Challenges of breaking the graph model lock-in](https://content.iospress.com/articles/semantic-web/sw223273). Merging annotated statements into types either requires to faithfully model annotations via cumbersome indirections or loses the source and focus of annotations, making precisely targeted updates impossible.

[TODO] 	example




### Syntax

This proposal introduces a syntactic device to nest graphs, using curly brackets like Notation3 formulas, but with a different semantics. Each such pair graph is preceded by its name, given in square brackets.
Before going into the nitty-gritty of syntax and semantics and discussing questions of identification, multisets, instantiation, the relation to named graphs, etc. lets first introduce a short and rough example. We employ a modified Turtle syntax; a JSON-LD version is TBD.

```
_:id.1 {                  #            an RDF 1.1 named graph
    :s :p :o .            # _:id.1
    :a :b :c .            # _:id.1
    []{ :d :e :f }        # _:id.2     a nested and annotated anonymous singleton graph
    	 :g :h .          # _:id.1
    []{ :i :k :l ;        # _:id.3     recursive nesting
    	 :m :n .          # _:id.3
      []{ :o :p :q }      # _:id.4     the same statement twice
    	   :r :s .        # _:id.3
      []{ :o :p :q }      # _:id.5
    	   :t :u ;        # _:id.3
    	   :v :w . }      # _:id.3
    []{ :x :y :z }        # _:id.6     nested but not annotated graph
}
```

This example shows how curly brackets demarcate graphs.
Each nested graph is automatically assigned a blank node identifier, here explicated in the comment to show how nested graphs get their own identifiers (as will be shown [below](#naming), nested graphs may also be identified by user defined identifiers).
Within a nested graph the standard set semantics of RDF apply, i.e. simple triples have no identifiers by themselves. A triple to be annotated individually needs to be enclosed by its own (in that case singleton) nested graph.

A nested graph can only occur in subject and object positions of statements. As the name implies it can contain other nested graphs.

> [TODO] are circular references to be forbidden?

Attributing a statement requires to put it in a nested graph, i.e. to enclose it by a pair of curly braces.
Attributing a single statement by putting it in its own graph creates a singleton nested graph - nothing special about that.
The same statement (or group of such) may be added multiple times, each in its own nested graph, and those nested graphs are differentiated by their identifier.
It is possible to put a statement in a nested graph without attributing it. The statement `:x :y :z` in the above example is as valid a statement and part of the enclosing named graph just as the unenclosed statement `:s :p :o`. This allows to add the same statement type multiple times, effectively realizing bag semantics.



#### Triple or Graph

The choice of nested graphs as the basic modelling primitive warrants a discussion.
One of the most basic problems that any approach to increase the expressivity of RDF has, is to decide if it should target individual statements or groups of statements. Some proposals see this as orthogonal issues, some insist that named graphs should only be used to group triples, etc. 
This proposal argues that there is no clear cut criterion that can be used to differentiate annotations on single triples from those on sets of multiple triples, i.e. graphs. 

One of the most prominent use cases in RDF, provenance, can involve single triples. OTOH recording for each triple its provenance will probably seem tedious and verbose when in an application triples only come in huge sets per source and ingestion event. 
Many typical use cases in integration focused Semantic Web applications involve handling sets of triples.
Property graphs and Wikidata style modelling OTOH mostly annotate single triples, often attributing primary relations with secondary detail.
Any approach that aims to increase the expressivity of RDF without getting dragged into ever more complex snowflake-shaped n-ary relations will probably target individual triples, not sets thereof.

In summary there is no clear winner in terms of use cases nor even a clear preference of use cases for one or the other modelling primitive. It is therefore also impossible to predict if navigation and querying for a specific topic should aim for syntactic constructs that target singe triples or those that group triples. Given an unfamiliar data source a user would always have to take both singleton- and set-specific modelling approaches into account if annotations on singleton triples were indeed performed differently from those on sets of triples.

Given the cost that entertaining different annotation mechanisms for single and multiple triples incurs we decided to settle on sets of triples, i.e. graphs, as the only mechanism to address (sets of) triples. 
This guarantees that only one idiom has to be used when authoring, navigating and querying data, vastly improving the usability and predictability of these most basic activities. 
These advantages w.r.t. usability in our view outweigh by far any performance penalties that an application might incur that is heavily leaning towards one or the other modelling approach. Such issues may be tackled by optimizations under the hood, out of user's sight.



### Inheritance

Inheritance of annotations on nested graphs in general follows the same principle as inheritance in Cascading Style Sheets (CSS) which are assumed to be well-known: attributes are inherited as long as no deeper nested graph overrides them with its own attributes. 

This general case however can only be applied to annotations that either explicitly target the graph itself or don't specify their target (i.e. do not provide a [fragment identifier](#fragment-identification) - see the following section). Annotations that target specific fragments of a graph - like a subject, predicate or object of a singleton graph or all triples in a graph - are not inherited by deeper nested graphs.

[TODO]  example



### Naming 

In this approach every nested graph has a name, either implicitly as an automatically assigned blank node identifier, or as a user provided IRI. An automatically assigned blank node identifier is in syntax represented by an empty pair of square brackets prepended to the pair of curly brackets that encloses the nested graph. Because of the rendering as an empty pair of square brackets such a nested graph is also called an anonymous nested graph.

Annotating an anonymous nested graph can only happen within the constraints of - usually line-based - serializations, whereas explicit naming allows to refer to the nested graph in any other statement.

An example of an explicitly named nested graph:
```
[:MyFirstGraph]{:s :p :o}
```

This simple primitive can be employed in many different ways:
```
[:MyGraph1]{ :a :b :c } :d :e .     # creation and annotation in one stroke
:f :g :MyGraph1 ;                   # a separate reference to :MyGraph1
   :h :i .
[:SomeGraph2]{
    [:ThisGraph3]{:k :l :m , :n}    # heavy nesting
    :o :p } :q :r .
:MyGraph1 :s :ThisGraph3 ;
          :t :SomeGraph2 .
[:ThatGraph4]{:u :v :w} .           # creation of :ThatGraph4
[]{ :a :b :c }                      # _:g5, a different graph than :MyGraph1
[]{ :a :b :c }                      # _:g6, yet another graph
:ThatGraph4 :y :z .                 # annotating :ThatGraph4 in a separate step
```
Graphs can be named and annotated in the same statement, but they also can be named when created and only later be annotated.
An anonymous nested graph is different from a named nested graph with the same content.

With two anonymous nested graphs that contain the same statement it is, as customary in RDF, an application decision if they are to be leaned or not

A nested graph can only be named at the location where it is defined, as appending a name to a nested graph creates a new instance. Because of that an unannotated nested graph will always be distinguishable from a nested graph that was introduced, named and annotated. 




### Semantics

This proposal aims to provide nested graphs with a solid semantics that is both easy to use and formally well defined.
Barring more specific arrangements - introduced in section [Configurable Semantics](#configurable-semantics) below - all nested statements are asserted and referentially transparent, i.e. nested or not, they are regular RDF statements governed by standard RDF semantics.

Naming every nested graph may be felt as a departure from the set-based intuitions of RDF on the surface, but at the core it is not, as will be discussed [below](#types-and-sets). On the surface however the hope is that this approach enables the reconciliation of integration focused design aspects of RDF (which is concerned with types of statements) and application-driven intuitions of practitioners (which often focus on individual occurrences of such types). Such an outcome would be a notable improvement over the status quo, where all too often "practitioners" feel bossed around by "semanticists" for no good reason, and therefore well worth the effort.


#### A Very Regular Semantics, Asserted and Referentially Transparent

In our approach nested graphs are both asserted and referentially transparent, i.e. statements in nested graphs follow the regular RDF semantics and are interpreted, i.e. part of the domain of discourse. This differentiates our take on nested graphs from other well-known approaches like RDF standard reification, formulas in Notation3, the original proposal for Named Graphs by Carroll et al 2005, and RDF-star.
Those approaches in our opinion try to solve too many problems at once, overloading a meta-modelling mechanism - which itself is sorely lacking from RDF - with very specific semantic tooling that make it unnecessarily hard to use for any mainstream use case. The results of that overloading have been mixed: Notation3 remained a niche application of interest mainly to logicians, named graphs as implemented and used in the wild didn’t follow the semantics as proposed by Carroll at al and the proposed RDF-star semantics is met with a lot of scepticism and doesn't meet the use case requirements. 

We do not intend to diminish or contest the value of such advanced semantic operators, but we think that separating specialist needs like syntactically faithful representation, configurable semantics and modalities from the basic representational construct is in everybody's best interest: it keeps the basic construct easy to use for basic needs like grouping and administrative annotations, and increases the probability that involved semantics, when applied via reserved constructs, do actually reflect the users' intent and are properly understood and followed. 

Following the 80/20 design principle we propose to implement non-standard semantics via a special instrument extending nested graphs expressivity, ascribing them to the nested graph via a syntactic extension. That syntactic instrument will be discussed in section [Configurable Semantics](#configurable-semantics) below. It is based on graph literals implemented as a new datatype in RDF, a proposal first made more than a decade ago.


#### Graph sources

Graphs as defined in RDF are a mathematical abstraction and an RDF Graph is defined as a set of RDF statements, i.e. the statements themselves define a graph. Practical issues like the need to name a graph or refer to it are not defined. There also is no formal notion of a graph that is changing over time. However, the concept of a graph understood as a *source* is informally introduced. The specification of RDF 1.1 Concepts and Abstract Syntax in section 1.5 on [RDF and Change over Time](https://www.w3.org/TR/rdf11-concepts/#change-over-time) says: "We informally use the term *RDF source* to refer to a persistent yet mutable source or container of RDF graphs. An RDF source is a resource that may be said to have a state that can change over time. A snapshot of the state can be expressed as an RDF graph. For example, any web document that has an RDF-bearing representation may be considered an RDF source. Like all resources, RDF sources may be named with IRIs and therefore described in other RDF graphs."

This concept guides our intuition about the relation between a nested graph and its name. A nested graph has a certain amount of identity: it serves a purpose, providing a description composed of one or multiple statements. That description may change over time by adding, updating or removing statements and yet, by being collected within the same nested graph, it has identity as being the description of an entity of some kind.
As hinted at in the specification, a fitting analogy might be a web page with some embedded RDFa data, or a file with RDF data serialized as Turtle, or a SPARQL endpoint returning a set of triples in response to a certain query. All those data sources may change over time, and their identity is constituted by them referring to some entity in the real world via their name and address. 
The name itself however is defined to have no meaning, just like all IRIs are treated in RDF. Of course, in practice IRIs often carry meaning, but as customary in logic in general and in RDF model theory specifically, it is ignored here.

In other words, the name of a nested graph refers to what the graph is about. The triples enclosed by a pair of curly brackets may change without the graph name changing. It is the responsibility of the author to ensure the creation of a new identifier if the topic of the graph changes. One might aim for a design more focused on immutability, where a graph name changes whenever the statements it contains change, but that is beyond the scope of this proposal. 

Consequently, two graphs by different names but containing the same set of triples are two different graphs. However, no two graphs by the same name can exist - irrespective if the triples they contain are the same or not - and the statements they contain will be merged into one graph by that name (the usual considerations w.r.t. [union or merge](https://www.w3.org/TR/rdf11-mt/#shared-blank-nodes-unions-and-merges) of blank nodes apply).


#### Types and Sets

The RDF model theory is based on sets, as is customary in model-theoretic formalizations. Sets also intuitively provide a solid foundation for RDF, as one of its foci is on integration and re-use of data from disparate sources, where the stated fact itself - *what* is being said - is of primary importance and not why it was said, by whom, how many times etc.

However, many scenarios would benefit from a more instance-focused approach.
Applications often disambiguate occurrences of facts based on provenance, temporal or spatial criteria, propositional attitudes etc. 
Demanding data modelling cases would like to annotate a main fact with finer detail or additional context, but without burying the main topic in a meandering n-ary construct. 

Such practices shift the focus from the relation type to its instances, thereby getting in conflict with the set-based formalization of RDF. The nested graph approach tries to harmonize the technical foundation with these advanced needs by sticking to sets as the basic formalization, but understanding and implementing statement instances as subsets. That subsetting construct itself is sugar coated - via the default provision of anonymous identifiers - to make it feel like actual instantiation to the user. 


##### Sub-Type or Instance

It would be possible to treat the annotated statement either as an instance of a statement of that type or as its subtype. Singleton properties in different papers treated the singleton property first as an instance of the relation, then as a subtype, but in a third paper dodged the question and settled for a rather informally defined "having" relation (for detail see Section 4.2.3.3 in my master thesis [PDF](https://gitlab.com/rat10/between-facts-and-knowledge/-/blob/main/Between_Facts_and_Knowledge_1.0.2.pdf)). 
Since nested graphs can be recursively nested it seems appropriate to define the relation as a subtype relation, honouring the fact that a nested graph can itself again contain nested graphs, etc.

> [NOTE] 
>
> Actually there is not so much of a difference between subsetting and instantiation. The distinction is a matter of perspective, of intended usage - a line drawn in the sand. OWL punning for example shows how relative this concept is. We shouldn't be too obsessed with this issue, except that we do of course need to always be clear which perspective we take when we talk about an entity. 

##### Set or Bag

The fact that anonymous identifiers are hidden from users in the surface syntax may lead to the impression that nested graphs have bag semantics, i.e. that they allow to state the same statement multiple times. That might give rise to the impression that this proposal breaks with the set-based semantics of RDF. This concern is unfounded, but the intuition of a bag semantics at the surface is intended.
A user may very well note the same nested graph multiple times, for whatever reason that might be, and that will feel and behave exactly like a bag of multiple identical nested graphs. Even if they contain the exact same statement, they will be displayed as separate entities, e.g.:
```
[:MyGraph1]{ :a :b :c } :d :e .
[]{ :a :b :c }
[]{ :a :b :c }
```
However, since each nested graph it identified by its own identifier - blank node or IRI -, they technically and semantically are different nested graphs, and a graph containing a number of such seemingly identical nested graphs is still a set (although applications may choose to lean identical anonymous nested graphs).


##### Unification of Nested Graphs

There exist of course multiple ways and reasons to reduce the verbosity of this arrangement:

- applications may decide to unify nested graphs containing the same statements if they do not want to keep count of such instances. 
- applications may decide to lean a result set that contains the same statement with different, but in the context of the query irrelevant annotations.
- applications may materialize "views" in which duplicate nested graphs are suppressed, because the view does not take into account the annotations that differentiate them.

All those arrangements generate dimensionally reduced sets, either on the fly for queries, or as an additional view, or permanently by deletions and updates in the data.
Early/eager unification of duplicate nested graphs will reduce complexity in the data, but might loose detail compared to late unification in generated views or query results. It depends again on the needs of applications which path they should choose.
Crucially this proposal allows to postpone that decision as long as suitable, contrary to the standard RDF approach which at least in theory favours eager and early unification.


###### Anonymous Nested Graphs

Nested graphs that have not been explicitly named by the user are implicitly identified by automatically provided blank nodes. This makes them subject to RDF's rules for the handling of blank nodes, especially the choice between union and merge, that only an application can sensibly make. Consequently it is also an application decision if two anonymous nested graphs with the same content get merged into one nested graphs or if they are differentiated by providing them with different (blank node) names.
In the example of the section on [naming](#naming) above it would be the decision of the application if the anonymous nested graph `_:g6` is leaned away or kept around. An OWL reasoner (establishing an application environment itself) will always lean them, in a SPARQL query 'counting semantics' will probably be applied and both instances returned - both approaches are possible and viable. This follows the well-known path of blank node treatment in RDF: leaning is possible, but not required.

This can intuitively be understood as a late binding approach to set based data integration: statements, even if they are of the same type, are kept separate as long as it is not clear that they can safely be merged because what differentiated them at some point may no longer be of importance.
It may well be that applications decide to keep different instances of the same statement around for a long time and unify them only in response to queries, e.g. a query that doesn't ask for specific instances of the same type of triple may be shown only the type, once - maybe amended by a hint to different instances and how they differ. Contrast that with the early binding of RDF, that rather favours early optimization of integration over fine-grained differentiation. 

In RDF the focus on early optimization for the sake of performant and sound integration tends to collide with application specific intuitions, creating tensions and the need for workarounds and out-of-band solutions. The discrepancy between the theoretical focus on leaning e.g. in reasoning and the practical focus on instances e.g. in querying is something that RDF won't be able to get rid of, as it reflects the different needs of integration (favouring types) and application (working  instances) of data. We hope that the Janus-faced treatment of types with nested graphs provides a more intuitive formalization, resulting in sounder practical applications.


###### Explicitly Named Nested Graphs

The arrangement described so far mainly concerns anonymous nested graphs. OTOH it is also possible and probably often favourable, to explicitly name nested graphs, as this allows for easier reference of graph structures across the boundaries of line based serializations. However, explicit naming has to follow a few rules. The following set of explicitly named nested graphs would be illegal, as no two nested graphs by the same name are allowed in one set, no matter if they contain the same set of statements or not:
```
[:MyGraph___1]{ :a :b :c } :d :e .
[:ThisGraph_2]{ :f :g :h } 
[:ThisGraph_2]{ :i :k :l }          # illegal
[:ThatGraph_3]{ :m :n :o } 
[:ThatGraph_3]{ :m :n :o }          # illegal
```
Applications that encounter multiple graphs by the same name, e.g. when merging data from multiple sources, should merge those graphs into one composed of the superset of the statements they contain. However, this is not a strict rule and applications may also choose to rename those graphs and all references to them in the respective sources. A reason for such an approach might be that it is evident from context that the names of those nested graphs were rather arbitrarily chosen and the graphs describe very different entities.
Of course, two graphs by the same name and the same content and without differentiating annotations should just be merged. If however e.g. their provenance is to be recorded, renaming them would probably be more advisable.


##### ForEach, ForAll, "ForItself"

It is not per se evident what an annotation to a graph is meant to refer to precisely and the spectrum of intuitions is wide. The annotation might be meant to refer to:

- the whole nested graph construct itself,
- all triples contained in that graph, individually, like in a `for each` loop,
- every individual term in every triple, as another interpretation of `for each`,
- or sometimes just a specific triple, or term, which a human user might easily be able to recognize by context or by the domain of the attributing relation.

Intuitions will inevitably vary, depending on the use case at hand. Leaving the question unanswered is an imprecision that can be helpfully convenient at times.
Notation3 for example takes that approach with lists, leaving it undefined if an attribution to a list means the list itself or its members.
Our proposal extends that approach by making such vagueness the convenient default - to not get in the way of applications that don't need more expressivity - but provides an additional facility to address an entity with more specificity, see the section on [Fragment Identification](#fragment-identification) below. 


#### Qualification 

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


## Fragment Identification

So far we didn't discuss in depth what exactly we are annotating when we add attributes to a nested graph. There are however important differences to consider.
Annotating a triple or graph as a whole is well suited to describe administrative detail like the statement's source, date of ingestion, reliability, etc.
However, sometimes we want to qualify the statement in certain ways, like providing further detail about its subject or object or the relation type itself.

In many cases application context will help to disambiguate if an annotation is meant to annotate the statement itself or some part of it. Some vocabularies explicitly specify the type of thing they annotate to the effect that an annotation on a statement's source can't be misunderstood for describing the source of the subjects described in that statement.
Still, in some cases we may need to be more precise or we might in general wish for a more expressive, and also more machine-processable formalism.
This is where fragment identifiers for RDF statements come in.

Fragment identifiers are well-known in web architecture as a means to refer to specific parts of a network resource. They are appended to the resource's IRI, introduced by a `#` hash sign.
As a graph is composed of triples and triples are composed of subject, predicate and object, the following set of fragment identifiers is needed:

- #s (subject)
- #p (predicate)
- #o (object)
- #t (triple)
- #g (graph)

For example:
```
[:g1]{ :a :b :c } 
:g1#s :d :e .
```
annotates the subject `:a` alone. A more compact syntax is
```
[]{ :a :b :c }#s :d :e .
```
if readability is not considered an issue. However, annotating multiple fragments would mandate a separation of annotations from the annotated statement:
```
[:g1]{ :a :b :c } 
:g1#s :d :e .
:g1#o :d :f .
```
Identification via fragment identifiers is distributive, i.e. it addresses each node of that type. An annotation of all triples in a nested graph, instead of the nested graph itself, can therefore be invoked via the `#t` triple fragment identifier, like so:
```
[:g2]{ :a :b :c . 
       :d :e :f }
:g2#t :g :h .
```
None of the fragment identifiers discriminates between single and multiple instances. In the example above each of the triples in graph `:g2` gets annotated individually. Likewise a reference to the subject would annotate each subject node, in this example `:a` and `:d`. 
Annotating the graph itself would either just omit the fragment identifier or, to be explicit, use the `#g` fragment identifier.

As a motivating example, consider Alice buying a house when she turns 40:
```
[:g1]{ :Alice :buys :House }
:g1#s :age 40 .
```
Without the fragment identifier it would even for a human reader be impossible to disambiguate if the house is 40 years old when Alice buys it or if she herself is. A few decades from now one might even wonder if the annotation wants to express that the triple itself stems from the early days of the semantic web.
Modelling data in this way also helps to keep the number of entity identifiers low, as they can always be qualified when the need arises. In standard RDF we would have to make some contortions to precisely model what's going on, i.e. either create an identifier for `:Alice40` or, to avoid identifier proliferation, create an n-ary relation like the following:
```
[ rdf:value :Alice ;
  :age 40 ] :buys :House
```
This is quite involved and does require that either users or some helpful background machinery ensure that a query for `:Alice` also retrieves all existentials that have `:Alice` as their `rdf:value` (or, in the aforementioned variant, all of `:Alice`s sub-identifiers like `:Alice40`). In a more elaborate example this style of modelling will quickly become unpractical, whereas annotations nicely ensure that the main fact stays in focus.

> [TODO] 
> 
> The '#' syntax is failing in TriG (which is quite embarrassing TBH). Alternatives like '?' and '/' need escaping too. So either one breaks one's fingers when typing or one has to use a more explicit expression, e.g.
>
>    :g1 seg:subject [ :age 40 ]
>
> Yes, that sucks.

> [NOTE] 
>
> We would like to extend this mechanism to be able to address metadata in web pages, like referring to embedded RDFa via e.g. a `#RDFa` fragment identifier. It has to be seen if this can be made work in practice.
> Also, we wonder if other types of fragments, e.g. algorithmically defined complex objects like Concise Bounded Descriptions (CBD), could be addressed this way.
> One problem is that it's not obvious how the set of s/p/o/t/g fragment identifiers can be extended. Would we support namespaces in the fragment section of nested graph names? Maybe. Otherwise they would need to be hard coded into RDF. Achieving consensus on a set of algorithms would probably not be easy.


### Disambiguating Identification Semantics

Identification is a slippery slope, full of out-of-band conventions and everyday intuitions that suggest precision when in fact ambiguity rules the place. An IRI may be used to address a web resource itself or to denote a thing or topic in the real world that the web resource is about (see [Cool URIs](https://www.w3.org/TR/cooluris/)). Addressing is not unambiguous either: requesting an information resource from an IRI may e.g. return different representations depending on content negotiation mechanisms. Denotation itself is ambiguous: the thing or topic referred to usually has facets of meaning, e.g. <https://paris.com> may be used to refer to the city of Paris, to its historic center, to the greater metropolitan area, or, depending on context, to some other topic like the Paris climate accord, the upcoming Olympics, etc.

RDF provides no easy to use and flexible provisions to express such specific identification semantics. Although in many cases the context in which an IRI is used provides the necessary disambiguation, this might not be possible to process by a machine. In some cases even contextualization will not suffice and an explicit description of identification semantics would be beneficial. 


To help disambiguate intended identification semantics we propose a small vocabulary with two classes referring to the two main kinds of identification semantics, interpretation and artifact.
```
DEF

seg:identifiedAs a rdf:Property ;
    rdfs:label "Interpretation semantics ;
    rdfs:comment "Specifies how an identifier should be interpreted." .

seg:INT a seg:SemanticsAspect ;
    rdfs:label "Interpretation" ;
    rdfs:comment "The identifier is interpreted to refer to an entity in the real world." .

seg:ART a seg:SemanticsAspect ;
    rdfs:label "Artifact" ;
    rdfs:comment "The identifier is used to refer to a web resource, i.e. an artifact." .
```


Note that these annotations can't be used when creating an identifier, e.g. when naming a nested graph. They only serve to disambiguate the intended interpretation when using an IRI as identifier, i.e. when "calling" it in a specific way. 
This proposal has several advantages over other solutions like IRI re-direction, hash identifiers and special sub-IRIs: it doesn't depend on out-of-band means like server configuration, it leaves hash identifiers for other purposes and it doesn't require the creation of a new set of identifiers.

In the following example the IRI <https://www.paris.com> is used to either refer to the website of Paris or to the city itself. The annotation via a fragment identifier disambiguates the intended referent:
```
[]{<https://www.paris.com> :created 1995 .}#s seg:identifiedAs seg:ART .
[]{<https://www.paris.com> :created "3rd century BC" .}#s seg:identifiedAs seg:INT .
```





## Graph Literals

Graph literals have been proposed before, e.g. by [Herman](https://www.w3.org/2009/07/NamedGraph.html) and [Zimmermann](https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html), to encode RDF graphs as literals, typed by a to be defined RDF literal datatype, e.g.:
```
"ex:x a owl:Thing"^^rdf:turtle
``` 
The approach has two important advantages:

- graph literals provide very intuitive usability characteristics, because the literal syntax is easy to understand as a verbatim representation of unasserted statements.
- graph literals don't require a modification of RDF model and syntax, but merely the definition of a new datatype. 

We take up the approach for two purposes. It can be used to:
- document assertions without actually endorsing them
- implement configurable semantics via configurable import

To that end we introduce the Graph Literal class:
```
DEF

seg:GraphLiteral a rdfs:Class ;
    rdfs:comment "A literal whose datatype is a standardized RDF serialization, e.g. RDF/XML,Turtle, TriG or JSON-LD".
```
We will in the following define ways in which the RDF contained in those literals can be introduced into the realm of interpretation. To that end it has to be ensured that query and reasoning engines can access the data contained in graph literals if applicable, i.e. they have to be able to parse RDF literal data types as if they were standard RDF data IFF the property linking to those literals suggests so. 

> [NOTE] 
>
> In any case, blank nodes in graph literals are always scoped to the literals and can’t be shared with outside RDF data. Anything else would be quite involved to implement and also wouldn't make much sense, as the meaning of an existential is defined by its attributes and those are local to the literal. Graphs provide the means to include all attributes that are relevant to define the meaning of an existential. If an existential is still considered important enough to share it with data outside the graph literal, it has to be skolemized - that seems like a reasonable demand.


### Graph Literal Semantics

To define useful semantics for graph literals we distinguish two aspects: an assertion may be asserted or not, and it may be interpreted or not. 
This amounts to four categories:

- Quotation: a quoted assertion is not asserted and it's IRIs are not interpreted. It is really just a literal, referring to itself. However, it is of datatype RDF, which makes it amenable to further processing.
- Reification: an assertion is noted but not asserted. However, the IRIs refer to things in the realm of interpretation, they are not a form of quotation. This is the semantics of RDF standard reification.
- Literalization: an assertion is made, but IRIs are interpreted *verbatim* so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3.
- Interpretation: lastly, an assertion that is asserted and interpreted. This amounts to regular RDF, i.e. no quotation at all, no literal involved.

Again, but in tabular form (the two rightmost columns will make more sense in the course of what is outlined below):

|  semantics       |  INTERPRETED |  ASSERTED  |  abbr. |  syntax         |
|------------------|--------------|------------|--------|-----------------|
|  Quotation       |  no          |  no        |  QUT   |  "..."^^nng:ttl |
|  Reification     |  yes         |  no        |  REI   |  []{"..."}      |
|  Literalization  |  (sort of)   |  yes       |  LIT   |  []"..."        |
|  Interpretation  |  yes         |  yes       |  INT   |  n/a            |


This categorization should cover most use cases that are not targeting specific semantic arrangements like Unique Name Assumption, Closed World Assumption, etc. Of course, there's always a way to advance even deeper into the rabbit hole...


### Unasserted Assertion

Unasserted assertions are a niche but recurring use case that so far isn't properly supported in RDF. Some participants in the RDF-star CG strongly argued in its favour. The intent is to document assertions that for any reason one doesn't want to endorse, e.g. because they are outdated, represent a contested viewpoint, don't pass a given reliability threshold, etc.

The RDF standard reification vocabulary is often used to implement unasserted assertions, but the specified semantics don't support this interpretation and its verbosity is considered a nuisance. A semantically sound and at the same time easy to use and understand mechanism would be a useful addition to RDF's expressive capabilities.

However, the semantics of existing approaches in this area, like RDF standard reification and RDF-star, differ in subtle but important aspects. We present a few different variations on the theme.


#### Quotation

The most straightforward use case of graph literals is documenting statements without endorsing them. 
```
:Bob :proclaimed ":i :LOVE :pineapples'"^^nng:ttl .
```
A graph literal represents a quote, documenting with syntactic fidelity the assertion made (although the example somehow unrealistically assumes that Bob speaks in triples).
In a more specific arrangement we might want to document the revision history of a graph or implement an explainable AI approach. Here we aim to actually assert a statement, but also to document its precise syntactic form before any transformations or entailments. Such transformations are common in RDF processes to improve interoperability, e.g. replacing external vocabulary with inhouse terms that refer to the same meaning, entailing super- or subproperty relations or even just some syntactic normalizations. However, sometimes it is desirable to retain the initial state of an assertion.
To that end we introduce the following property:
```
DEF

seg:statedAs a rdf:Property ;
    rdfs:range seg:GraphLiteral ;
    rdfs:comment "The object describes the original syntactic form of a graph" .
```

The following example shows how this can be used to document some normalization:
```
[]{ :s :p :o } seg:statedAs ":S :p :O"^^nng:ttl
```
In the next example the literal is accompanied by a hash value to improve security:
```
[]{ :s :p :o } seg:statedAs [
    rdf:value ":S :p :O"^^nng:ttl ;
    seg:hash "72511fef12df97439b16ecda1415f98a"^^MD5
]
```
Note that while the graph literal is accompanying an assertion of the same type, itself it is unasserted.


#### Reification - Referentially Transparent Citation

In some cases the syntactic fidelity of straight graph literals can be problematic. We might want to document that Bob made the claim that the moon is a big cheese ball, but we don't know the exact terms he uttered. We don't know if he said `:Moon` or `:moon` and we don't want to give the impression that we do, nor do we want to be dragged into arguments about such detail.
The semantics of RDF standard reification captures this intuition as it doesn't refer to the exact syntactic representation, it is not quotation. Instead it denotes the meaning, like any triple does per the RDF semantics: it refers not to the identifier `:Moon` but to Earth's moon itself. This intuition guides the definition of the following property:
```
DEF

seg:StatementGraph a rdfs:Class ;
    rdfs:subClassOf rdf:Statement, seg:GraphLiteral ;
    rdfs:comment "A Graph Literal describing the meaning of an RDF graph" .

seg:states a rdf:Property ;
    rdfs:range seg:StatementGraph ;
    rdfs:comment "The literal object describes the original meaning of a graph" .
```
To safe us from discussions about what Bob said verbatim, but concentrate on the meaning of what he said, we would reformulate the above assertion as:
```
:Bob seg:states ":Moon :madeOf :Cheese"^^nng:ttl .
```
Again, the graph literal is not asserted (and we have no intention to do so), but we are also not bound or even fixated on its syntactic accuracy. We just get along the fact.

To be free in the choice of properties, the following modelling primitive can be used:
```
:Bob :uttered [
    rdf:value ":Moon :madeOf :Cheese"^^nng:ttl ;
    a seg:StatementGraph .
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

##### Nested Graph Literals - Syntactic Sugar for RDF Standard Reification

We consider this use case important enough to warrant its own dose of syntactic sugar, a combination of braces and quotation marks:
```
:Bob :uttered []{" :Moon :madeOf :Cheese "} .
```
Intuitions, and consequently usability and acceptance in practice, are served by two aspects:

- the nested brackets signal regular RDF, i.e. interpreted, queryable
- the parentheses signal citation, not actual assertion
- a datatype declaration can be omitted as long as we're not dealing with generalized RDF

Compared to RDF standard reification this is not only less verbose, but also more intuitive to use.



### Literalization - Referentially Opaque Assertions

The RDF-star CG report has proposed an approach to quotation semantics in which the quoted RDF-star triple refers to entities in the realm of interpretation, but only via the exact syntactic form used in the RDF-star triple. 
No entailments would be derived from the graph literal.
However, contrary to the approach of RDF-star and also Notation3, the literalized graph is indeed asserted. This semantics could be specified by means of the following vocabulary:
```
DEF

seg:LiteralizedGraph a rdfs:Class ;
    rdfs:comment "A quoted assertion. IRIs are interpreted, but *verbatim*, so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3." .

seg:statesLiterally a rdf:Property ;
	rdfs:range seg:GraphLiteral ;
    rdfs:comment "The object describes the meaning of a graph when provided in this specific syntactic form" .
```
It would be used as:
```
:Bob seg:statesLiterally ":Moon :madeOf :Cheese"^^nng:ttl .
```
or, to be more free in the use of vocabulary:
```
:Bob :muttered [
	rdf:value ":Moon :madeOf :Cheese"^^nng:ttl ;
	a seg:LiteralizedGraph.
] 
```




### Importing Assertions

Graph literals provide a way to reference an RDF graph for purposes beyond mere documentation and quotation. The main idea is to process via graph literals everything in need of specific semantics arrangements different from the standard RDF semantics, and manage their inclusion into the active data via specific properties. This ensures that statements with special semantics are not processed like standard RDF, which could result in unwanted entailments (that could then not be taken back because of the monotonic nature of RDF).


#### Import via Inclusion

Inclusion offers the possibility to parse a graph literal and add its content into a graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements. This works very much like `owl:imports` for ontologies and the respective property is named to allude to that similarity:
```
DEF

seg:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain seg:Graph ;
    rdfs:range seg:GraphLiteral ;
    rdfs:comment "Includes the literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```
Importing a literal is defined on graphs and on individual nodes.

Importing a literal into a graph doesn't create a nested graph but includes the statements from the graph literal into a graph. The including graph may be explicitly named or referenced as the local graph.

The following example includes a graph literal into another graph (local or not):
```
ex:Graph_1 seg:includes ":s :p :o . :u :v :w ."^^nng:ttl .
```
To include a graph literal into the local graph a syntactically more elegant approach is available, using a self-referencing identifier, `<.>` (see [below](#mapping-to-named-graphs)), to refer to the enclosing nested graph:
```
<.> seg:includes ":s :p :o . :u :v :w ."^^nng:ttl .
```
Inclusion means that the graph can be assumed to contain the statements from the included literal. Those statements therefore can not only be queried but also reasoned on, new entailments can be derived, etc. However, new entailments can not be written back into the graph literal. Therefore the only guarantee that this mechanism provides is a reference to an original state.

Inclusion can also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages. We will see such applications when discussing [shapes](#shapes) below.


#### Import via Transclusion

Transclusion in the most basic arrangement only includes by reference, meaning that a transcluded graph is asserted and can be queried, but it is referentially opaque and no entailments can be derived - blocking any kind of change to and inference on the transcluded data, much like the semantics of Notation3 formulas and RDF-star triple terms per the semantics presented in the CG report. 

The respective property is defined as:
```
DEF

seg:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain seg:Graph ;
    rdfs:range seg:GraphLiteral ;
    rdfs:comment "Transcludes the literal via reference. Transcluding a graph literal provides certain immutability guarantees for the transcluded graph." .
```
A usage example would be the following:
```
_:thisGraph seg:transcludes ":s :p :o"^^nng:ttl .
```

However, transclusion also makes it possible to configure the semantics of transcluded graph literals. Mediating access through the transclusion property guarantees that such semantics arrangements are obeyed and no unintended entailments can leak into transcluding graphs. Configurable semantics are discussed in detail only later [below](#configurable-semantics), so a simple example has to suffice here:
```
<.> seg:transcludes [
    rdf:value ":s :p :o"^^nng:ttl ;
    seg:semantics seg:APP
] .
```
An additional annotation with a semantics attribute, in this case `APP`, can loosen the very restrictive base semantics to arrange for use cases driven by e.g. application intuitions like a Closed World Assumption, an Unique Name Assumption, etc.



## Configurable Semantics

The semantics of RDF is designed to reflect the realities of a shared and decentralized information system spanning the whole world: no one ever has a complete grasp on the data, people use different names to refer to the same thing (and sometimes also the same name to refer to different things), no-one is entitled to modify someone else's data, what is not in the data at hand may nonetheless be true, etc. Some of these criteria have names, like the Open World Assumption (OWA) or the No Unique Name Assumption (NUNA). Some, like referential transparency, are so deeply baked into the formalism that they a barely noticed. Some only become visible through the absence of certain constructs like e.g. negation.

Some of these semantic fixings are rather counter-intuitive to application developers accustomed to closed environments e.g. driven by relational database systems, as those systems tend to take a rather opposing stance: in an in-house application the data is expected to be complete, what is not in the database is false, everything has exactly one name, etc.

Environments focusing on the integration of data tend to have a different perspective then applications optimized to put that data to use. This tension between data integration semantics for the open semantic web and application semantics for in-house use of such data has frustrated application developers since the start of the Semantic Web. At the time a popular intuition was that mechanisms should be added to the RDF semantics machinery that allowed to put into effect on demand more restrictive semantics, tailored to the needs of applications. However, such mechanisms have never materialized and one of the reasons might have been the problem of how to describe the boundaries of such a change of semantics regime, even more so after the RDF 1.1 WG failed to standardize a semantics of named graphs.
Nested graphs do offer the chance to rectify this issue as they provide a semantically sound handle to identify graphs of RDF data.


### Semantics Aspects

Establishing the right set of semantic features is of course a task on its own, but some candidates seem pretty obvious:

+ unasserted assertions, suppressing endorsement of contentious statements
+ closed world assumption, suppressing unpredictability
+ unique name assumption, suppressing co-denotation
+ referential opacity, suppressing entailments
+ negation, suppressing unwanted statements

The following vocabulary provides a term to introduce a semantics and offers a few possible applications.

```
DEF

seg:SemanticsAspect a rdf:Class ;
    rdfs:comment "An aspect of a semantics that differs from RDF’s default." .
	
seg:UNA a seg:SemanticsAspect ;
    rdfs:label "Unique Name Assumption" ;
    rdfs:comment "Each entity is denoted by exactly one identifier." 

seg:CWA a seg:SemanticsAspect ;
    rdfs:label "Closed World Assumption" ;
    rdfs:comment "The data is complete." 

seg:HYP a seg:SemanticsAspect ;
    rdfs:label "Hypothetical, unasserted Assertion" ;
    rdfs:comment "A graph documented, but not asserted." 

seg:OPA a seg:SemanticsAspect ;
    rdfs:label "Referential Opacity" ;
    rdfs:comment "All IRIs are interpreted to refer to entities in the real world, but only in the specific syntactic form provided (i.e. no co-denotation with other identifiers referring to the same entities)." .

seg:NEG a seg:SemanticsAspect ;
    rdfs:label "Negated" ;
    rdfs:comment "A graph considered false." 
```


### Semantics Profiles

From such aspects then semantic profiles can be constructed, that allow to conveniently establish environments tailored to specific needs. We could for example imagine that the following set of semantics profiles would support many if not most applications:

- `APP` - application intuitions like they are typically found in RDBMS backed systems
- `CIT` - referential opacity, as in Named Graphs, Carroll et al 2005, to faithfully record graphs, supporting use cases like versioning, explainable AI, warrants
- `TYP` - entailment-optimized semantics as hinted at in https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html

We can also see other, less specific uses of nested graphs concerned with semantics issues like:
- blank node scoping via specific blank node scoping graphs (maybe to be called "bGraphs")
- entailment scoping to e.g. state that within some nested graphs no contradictions are allowed (a SPARQL dataset itself constituting an outermost nested graph)

The following vocabulary combines semantics aspects and [naming semantics](#graph-types) into semantics profiles catered to different application scenarios.

```
DEF

seg:SemanticsProfile  a rdf:Class ;
    rdfs:comment "A combination of semantics aspects into a coherent whole." .

seg:hasAspect a rdf:Property ;
    rdfs:comment "Describes semantics aspects of a semantics profile" .


seg:APP a seg:SemanticsProfile ;
    rdfs:label "Application Profile" ;
    rdfs:comment "A semantics profile capturing typical intuitions of in-house application development" ;
    seg:hasAspect seg:UNA , 
                  seg:CWA ,
                  seg:Address ,      # we discourage overloading of graph names
                  seg:Identifier ,
                  seg:GraphSource .

seg:CIT a seg:SemanticsProfile ;
    rdfs:label "Citation Profile" ;
    rdfs:comment "A semantics profile capturing the semantics of Named Graphs, Carroll et al 2005, with the purpose to faithfully record graph instances with syntactic precision." ;
    seg:hasAspect seg:OPA ,
                  seg:Address ,
                  seg:Identifier ,
                  seg:GraphType .

seg:LOG a seg:SemanticsProfile ;
    rdfs:label "Logic Profile" ;
    rdfs:comment "A profile to enable reasoning over nested graphs" ;
    seg:hasAspect seg:Address ,
                  seg:Content ,
                  seg:GraphType .
```

### Practical Application

We can see two ways how such semantics profiles can be applied to RDF data: either they resort to an [transclusion](#graph-literals) construct based on regular RDF or they apply some syntactic sugar. Both approaches will be investigated below.

The practical problem that any approach on configurable semantics has to solve is how to guarantee that the RDF data so qualified can never be mistaken for regular RDF data. If the data would be introduced as a regular snippet of RDF, accompanied by an additional statement declaring its specific semantics, there could be no guarantee that an RDF processor is aware of that semantics fixing before deriving possibly unwanted entailments or in other ways processing the data in unintended ways.


#### Transclusion enabling Configurable Semantics

The transclusion mechanism introduced [above](#import-via-transclusion) allows to import graph literals with extremely restricted semantics. Adding to the transclusion a semantics instruction allows to tailor the semantics of the transcluded graph to the desired effect. We already gave the following example:
```
<.> seg:transcludes [
    rdf:value ":s :p :o"^^nng:ttl ;
    seg:semantics seg:APP
] .
```
To make this arrangement more usable and also more tight, we could define proper subproperties of `seg:transcludes`, like e.g. `seg:transcludesAPP`:
```
seg:transcludesAPP rdfs:subPropertyOf seg:transcludes ;
                   rdfs:range seg:APP .
```
This allows a streamlined transclusion of RDF data into a graph with very specific semantics.
```
<.> seg:transcludesAPP ":s :p :o"^^nng:ttl .
```
Integrating such transclusions into regular RDF assertions is rather seamless as well, e.g.:
```
:Bob :claims [ seg:transcludesCIT ":s :p :o"^^nng:ttl ].
```

It isn't hard to define tailored semantics solutions from the building blocks provided so far. We might for example start from the following construct, which expresses that the list of Alice's things follows the usual application intuitions (i.e. it is not concerned with syntactic fidelity, it is complete and the unique name assumption applies):
```
:Alice :has [ rdf:value "(:D :E :F)"^^nng:ttl ;
              seg:semantics seg:Interpretation ,
                            seg:UNA ,
                            seg:CWA ]
```
Because that's rather involved we create a shorter description of the desired semantics:  
```
ex:List a seg:SemanticsProfile ;
        seg:semantics seg:Interpretation ,
                      seg:UNA ,
                      seg:CWA .
```
And apply it:
```
:Alice :has [ rdf:value "( :D :E :F)"^^nng:ttl ;
              seg:semantics ex:List ]
```
That's still not very elegant, so let's define a property:
```
ex:transcludesList rdfs:subPropertyOf seg:transcludes ;
                   rdfs:range ex:List .
```
And apply that:
```
:Alice :has [ ex:transcludesList "( :D :E :F )"^^nng:ttl ]
```
That's of course a bit much for one list, but it may pay off in an application context where we know that certain data sources are indeed complete and well kept and therefore it's safe to overrule the integration focused standard semantics of RDF.


#### Syntactic Sugar for Configurable Semantics

> [TODO]  
>
> This syntactic sugar is not tested yet and needs more work. The re-use of prepended square brackets to not declare a name but a semantics may cause more irritation than comfort.

The following syntactic sugar aims to express transclusion with configurable semantics even more succinctly. An RDF graph literal is prepended with an argument specifying the intended semantics, re-using the already familiar square bracket syntax, e.g.:

[APP]":a :b :c , :d" :e :f .

Because of the prepended argument the explicit datatype declaration can be omitted.
Prepending the semantics fixing ensures that it can not be overlooked by a conforming parser. 

The following examples show some possible scenarios, involving both aspects and profiles:
```
[APP]" :a :b :c , :d " :e :f .
:g :h [LOG]" :h :i :k " .
:l :m [HYP,OPA]" :n :o :p " ,
      [NEG,CIT]" :q :r :s " .
```
Note that mixing semantics profiles is not advisable with the profiles suggested above, as properties might contradict each other. In principle however profiles and aspects can be combined in modular fashion. If contradictions occur, the fixings of inner nested graphs overrule those of the graphs enclosing them. Contradictions within the same nested graph can't be resolved automatically and have to be interpreted as logical `OR`.


#### Term Semantics Syntactic Sugar


To make the application of configurable semantics more precise we explore a variant of RDF literals that targets individual terms. 

A popular example to motivate referential opacity is the Superman comic, with the reporter Louis Lane not being aware that her crush Superman is in fact the same person as her slightly dull colleague Clark Kent. This can precisely be modelled with a referentially opaque semantics applied only to the identifier for Superman: 
```
:LouisLane :loves [OPA]":Superman" .
```
Note how the references to Louis Lane and the concept of loving are still referentially transparent, as they should be, and solely the reference to Superman is constrained to refer only to that specific persona of the extra-terrestrial character Kal-El, but never to its alternative persona Clark Kent.

Here the square bracket prefix notation is used not to name the term - there's no need for that - but to indicate a certain semantics. This syntax in combination with the literal guarantees that the reference to Superman is always interpreted with the appropriate semantics. In this special datatype declaration may be omitted.

> [TODO]
>
> This syntactic sugar is not solidly defined yet. It would be nice to have but still needs some work.
> A slightly less daring, but also less succinct variant would be a simple property list combined with a term literal:
>    [seg:semantics seg:Opaque]":Superman"



## Querying

> [TODO] 
>
> a detailed discussion of querying, including 
>
> - display of annotations (as "there is more..." or similar)
> - scoping queries to nested graphs (recursively following their nested graphs)
> - querying (included/transcluded) graph literals
> - displaying results with non-standard semantics, e.g. unasserted, opaque, etc

<!--
Nested graphs are implicitly flattened. A query for `?s ?p ?o` in `_:id.1` above will return `:s :p :o` and `:a :b :c` just as well as `:d :e :f`, `:i :k :l`, `:o :p :q` (once) and `:x :y :z`. It will also return annotations on those nested statements as `_:id.2 :g :h`, `_:id.3 :m :n`, `_:id.4 :r :s`, `_:id.5 :t :u`and `_:id.5 :v :w`. [TODO check that these references still work after we are done with re-writing the examples]


Querying nested graph literals requires some extra arrangements: query engines should support querying these quotes, but must return results in the same syntax: as quoted graph literals. 

In a TSV/CSV query result set a value returned from an unasserted statement has to be rendered as a singleton unasserted term, e.g. `{":a"}`. Note that we can by default omit the naming part `[]`, but it will be added if the query explicitly asks for it. 

> [TODO] To ensure that unasserted values are not accidentally returned, a special `with UNASSERTED` parameter could be provided in the query. However, putting the query result in quotes might be just as effective and less troublesome. The opposite approach, a parameter `without UNASSERTED` that suppresses unasserted results on demand might also be an option. TBD

-->


## Mapping to Standard RDF

A mapping from nested graphs to regular RDF serves to pin down the informal semantics of nested graphs and provide guidance to backwards compatible implementations as well as querying and reasoning strategies.
Mapping nested graphs to standard RDF triples has the advantage that we know precisely what those standard RDF triples mean, and therefore such a mapping can guide intuitions and implementations. It also ensures backward compatibility to existing standards and implementations, albeit not with the same ease of use, of course.
Additionally a mapping to RDF 1.1 named graphs is provided, which will meet intuitions more directly, is syntactically much more straightforward and as a desirable side effect can also help to consolidate the contested state of semantics of named graphs in RDF.


### Mapping to Triples

A mapping to RDF triples is performed in two steps:

- all statements that do not themselves contain nested graphs and all statements in un-annotated nested graphs are copied verbatim to a target RDF graph,
- all statements containing nested graphs, i.e. annotated nested graphs, are mapped to n-ary relations, involving some special vocabulary.

While the first step is trivial, the second step can lead to rather convoluted n-ary relations. We first present a mapping closely aligned to regular RDF, based on a variation to the `rdf:value` property, but then also explore another approach based on the singleton properties proposal. To that end we introduce two new properties, `seg:aspectOf` and `seg:inGraph`. The property `seg:aspectOf` is defined differently, depending on the chosen mapping, and will be introduced in the respective sections below.
The property `seg:inGraph` records the nested graph that the statement occurs in. The graph identifier can be either a blank node or an IRI, faithfully reflecting the name of the nested graph.
```
DEF

seg:inGraph a rdfs:Property ;
    rdfs:comment "The property `seg:inGraph` records the nested graph that the statement occurs in." .
```

#### rdf:value-based Mapping

In this mapping the property `seg:aspectOf` is defined as a subproperty of `rdf:value`, and the modelling is oriented on the way `rdf:value` in standard RDF is designed to work: it doesn't engage with the property, as the singleton properties approach does, but with the object of a statement.
```
DEF

seg:aspectOf a rdfs:Property ;
    rdfs:subPropertyOf rdf:value ;
    rdfs:comment "The property `seg:aspectOf` is defined as a subproperty of `rdf:value`. Its `rdfs:range` is to be interpreted as the primary value of the annotated node." .
```

The nested graph construct
```
[_:ag1]{ [_:ag2]{ :a :b :c } :d :e }
```
is mapped to
```
:a :b :c .
:a :b [ seg:aspectOf :c ;
        seg:inGraph _:ag2 ;
        :d :e ] .             # annotating the triple
_:ag2 seg:inGraph _:ag1.
```
The modelling style is very close to regular RDF as we know it. In principle this mapping could without too much effort be implemented in standard RDF, if the well-known `rdf:value` property (or our more definitely defined `seg:aspectOf` property) was interpreted in a specific way, i.e. if every `rdf:value` relation would be automagically followed and returned as the default/main value to queries and follow-your-nose behaviours, and all other attributes to the originating blank node would be rendered as additional annotations on that main value. 

However, the intuitive semantics is a bit shaky, as an annotation on the object of a relation would by convention not be understood as referring to the whole relation, or even the enclosing graph: while application specific intuitions may interpret it as referring to the graph itself, it seems risky to make such an interpretation mandatory. Other intuitions may be implemented as extensions of this mapping: to annotate each node separately we could replace each term in the statement by a blank node (the property in generalized RDF, or otherwise create a singleton property term) and annotate them accordingly with an `seg:aspectOf` relation to refer to the primary topic of the term and further attributions as desired. However, it is obvious that such a mapping, while possible and actually quite faithfully representing the meaning of an annotated statement, would in practice be quite unbearable.


#### Singleton Properties-based Mapping

In the singleton properties oriented mapping annotations are attributed to a newly defined property.
The property `seg:aspectOf`, here defined as a subproperty of `rdfs:subPropertyOf`, points from the newly created property in the annotated statement to the original property that is getting annotated. The original property should be interpreted as the primary value of an existential represented by the singleton property, `:b_1` in the example below. In generalized RDF `:b_1` would be represented as a blank node, e.g. `_:b1`.
```
DEF

seg:aspectOf a rdfs:Property ;
    rdfs:subPropertyOf rdfs:subPropertyOf ;
    rdfs:comment "The property `seg:aspectOf`, defined as a subproperty of `rdfs:subPropertyOf`, describes the relation type of the statement that is getting annotated. Its `rdfs:range` is to be interpreted as the primary value of the annotated property." .
```

Using this approach, the nested graph construct
```
[_:ag1]{ [_:ag2]{ :a :b :c } :d :e }
```
is mapped to
```
:a :b :c .
:a :b_1 :c .
:b_1 seg:aspectOf :b ;
     seg:inGraph _:ag2 ;
     :d :e .                  # annotating the triple
_:ag2 seg:inGraph _:ag1 . 
```

On first sight, both approaches don't differ too much syntactically and also their triple count is roughly the same. However, in our view the singleton properties based mapping seems to provide a semantically more approachable behaviour than the more bare bones `rdf:value` based approach. It is also easier to extend to fragment identifiers as we will see below.


#### Annotating Singleton and Multiple Triple Graphs 

In the above example for both mappings, `rdf:value` as well as singleton properties, recording graph membership would not strictly be necessary, as the nested graph is not explicitly named and contains only one statement. 
More generally however membership in a nested graph, even if that graph is not explicitly named and not annotated, and/or is a singleton graph, is considered an act of grouping or repeating statements and as such considered an important enough knowledge representation activity as to be recorded on its own.

In the example, the annotation `:d :e` is attached to the singleton property directly. It could also be attached to the graph identifier `_:ag2`. That would be more correct if the annotation is not explicitly targeting the triple, but that might not be what the user intends.

Take the following example:
```
[_:ag1]{ [_:ag2]{ 
    :a :b :c . 
    :u :v :w } :d :e }
```
Here the immediate intuition will in most cases be that the annotation annotates the whole graph, not each triple. Therefore the following mapping will feel more appropriate:
```
:a :b :c .
:a :b_1 :c .
:b_1 seg:aspectOf :b ;
     seg:inGraph _:ag2 .
:u :v :w  .
:u :v_1 :w  .
:v_1 seg:aspectOf :v ;
     seg:inGraph _:ag2 .
_:ag2 :d :e ;                 # annotating the graph
      seg:inGraph _:ag1 . 
```

To help usability we might have to decide which one of those mappings is the default one. 
Because our proposal favours graphs, not singleton statements, we should probably go with the second alternative. The mapping to named graphs suggests so too. Fragment identifiers still provide a way to address individual triples. 

However, a user that created a singleton nested graph might expect that undertaking such effort for annotating a single triple should provide a clear enough indication that the intent is to annotate indeed the triple itself, not the graph. This is a problem that either needs to be very well communicated or to be handled by an extra arrangement that lets annotations on singleton graphs *automagically* refer to the triple instead of the graph, i.e. branch default denotation semantics from graph to triple for singleton graphs.

> [TODO] 
>
>This problem needs some more discussion. Although it can be resolved by means of fragment identifiers, a pragmatic and intuitive default semantics has to be found.



#### Caveat

No approach to a mapping from nested graphs to regular triples in RDF can bridge a fundamental gap: regular RDF can only express types of statement. In a mapping the basic, unannotated fact - no matter how it is derived - will always loose the connection to its annotated variant. This is likewise true for RDF standard reification and RDF-star.
It is not impossible for applications to keep track of annotated and un-annotated triples of the same type, e.g. to implement sound update and delete operations on annotated statements, but any mechanism to that effect will be rather expensive to implement, involved to run and as a result brittle in practice. A mapping to simple RDF triple types necessarily has its limitations and is no replacement for a mechanism like nested graphs.



### Mapping to Named Graphs

RDF 1.1 named graphs would seem like the most natural candidate to map nested graphs to. However this approach comes with two caveats: named graphs as specified in RDF 1.1 have no standard semantics, and their syntax doesn't support nesting. The latter problem is easy to dispel via a mapping, the former however it seems is an issue with many facets and not possible to resolve in a general way.

 The RDF 1.1 Working Group did spend a lot of effort on trying to standardize a semantics of named graphs in RDF but ultimately failed, as it proved impossible to get the various intuitions and implementations of the different stakeholders under one hood - see the [RDF 1.1 WG Note on Dataset Semantics](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/) for more detail. This is a terrain that it seems nobody wants to enter again. To ease backwards compatibility and not step on anybody's toes, this proposal is designed in a a way that it doesn’t *need* to touch the semantics, or rather the lack thereof, of named graphs as specified in RDF 1.1.

Consequently this proposal defines Nested Graphs *inside of* named graphs, with a specific semantics at that, but without making any assumptions about the semantics of an enclosing named graph and dataset. This leaves implementors free to continue to use and overload named graphs in any non-standard, application-specific way they desire. In other words: the status quo of named graphs in RDF remains untouched.

However, as the RDF 1.1 WG hinted at in the above mentioned note, it is very well possible to describe the semantics employed in the use of named graphs  as a default semantics of all named graphs contained in some dataset or even on a per case basis, e.g. per individual named graph. Our proposal adds vocabulary to describe the semantics of named graphs. One way there semantics can be described is as being exactly the same as that of nested graphs, aligning the two mechanisms as to make them virtually indistinguishable.
In that respect this proposal does indeed hope to change the status quo of named graphs in RDF: it claims to prove that a better world, in which RDF 1.1 named graphs have configurable semantics, is not only possible, but even quite practical. Standardizing *one* semantics for named graphs might have been useful, but that chance has passed. Standardizing a way to express the chosen semantics and agreeing on what those choices mean is *good enough* in most scenarios.


The nested graph construct
```
[]{ []{ :a :b :c } :d :e }
```
as standard RDF 1.1 named graphs maps to
```
_:x {  :a :b :c  }
_:y { _:x a seg:NestedGraph ;
          :d :e
}
```
or even just
```
_:x {  :a :b :c  }
_:y { _:x :d :e  }
```
again involving a two-step process, this time 

- mapping nested graphs that contain no other nested graphs to a named graph and 
- mapping annotations on nested graphs into separate named graphs that reference the annotated graph.

In general it shouldn't be necessary to explicitly specify that `_:x` and, for that matter, also `_:y` are nested graphs, as this can can be declared as a default arrangement for a whole dataset. This will be discussed in more detail in the next section. It also shouldn't be necessary to explicitly state the containment relation, i.e.
```
_:x seg:inGraph _:y .
```
This mapping assumes a uniform dataspace in which all named graphs can interact with each other. A more  fragmented intuition, that understands each named graph as its own "data island" could employ the `owl:imports` property to include nested graphs. 
To that end we introduce a new `<.>` operator to allow a named graph to reference itself, mimicking the `<>` operator in SPARQL that addresses the enclosing dataset. 
> [TODO] or is SPARQL using the `<.>` operator and we have to use `<>` ?
```
DEF

<.> a rdfs:Resource ;
    rdfs:comment "A self-reference from inside a named or nested graph to itself" .
```
This results in the following mapping:
```
_:x { :a :b :c  }
_:z { <.> owl:imports _:x .
      _:x :d :e  }
```
From a semantics perspective the resulting graph `_:z` represents the nested graph a bit more faithfully than the two separate graphs in the simpler mapping above. If this increase in fidelity is indeed worth the effort is an open question.

To clarify: `<.> owl:imports _:x .` imports `_:x` into a graph, but doesn't give it a name. In the section on [Literals](#graph-literals) below we will see other ways to import/include statements into a graph.

> [NOTE] 
>
> Membership in a nested graph is understood here to be an annotation in itself. However, that means that in this paradigm there are no un-annotated types anymore (the RDF spec doesn't discuss graph sources in much detail and only gives an informal description; however, this seems to be a necessary consequence of the concept). Types are instead established on demand, through queries and other means of selection and focus, and their type depends on the constraints expressed in such operations. If no other constraints are expressed than on the content of the graph itself, i.e. annotations on the graph are not considered, then a type akin to the RDF notion of a graph type is established. This approach to typing might be characterized as extremely late binding.



#### Named Graph Vocabulary

To make this mapping semantically more tight, we also introduce a vocabulary to provide RDF 1.1 named graphs with a semantics comparable to that of nested graphs. We hope to thus minimize room for misunderstanding and also to advance the introduction of sound semantics for named graphs.
The basic semantics of nested graphs represents what we interpret to be the minimal standard semantics of SPARQL (and in extension RDF 1.1) anyway:

- a graph name identifies a graph, i.e. graph identity is determined by the name, not by the contents of the graph,
- a graph name has no meaning in itself and overloading the graph name with other meaning in addition to its use as an address to retrieve the graph is an out-of-band arrangement (and violates a foundational principle of web architecture: that an IRI should refer to one and only one resource), 
<!--
- as the graph name has no meaning it can only refer to something that the graph is about, 
        TODO -- what? this is contradicting the prior fixing
--> and
- a named graph is not guaranteed to be immutable, but is just a source of RDF data.

> [TODO]  Is there more?

By making these fixing arrangements explicit and in addition providing vocabulary for alternative arrangements we hope to foster sounder semantics and enhanced compatibility among applications of named graph at a wider scale.
If e.g. an application chooses to overload the graph name with more meaning, that meaning should be made explicit by using the vocabulary provided in the next section. 

Also, the issue of ambiguous identification is not only confined to named graphs, but actually befalls any IRI in RDF, i.e. the question if an IRI is meant to address a web resource itself or refer to something that the resource is about. We will discuss this, and a possible approach to its resolve, in a section on [Disambiguating Identification Semantics](#disambiguating-identification-semantics) below.

More vocabulary on related issues like quotation versus interpretation semantics will be defined in the section on [Configurable Semantics](#configurable-semantics) below.


##### Graph Types

```
DEF

@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .

seg:Graph a rdfs:Class ;
    owl:sameAs sd:Graph ;
    rdfs:comment "An RDF graph, defined as a set of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-graph)." .

seg:NestedGraph a rdfs:Class ;
    rdfs:comment "A nested graph, as defined in this proposal." .

seg:NamedGraph a rdfs:Class ;
    owl:sameAs sd:NamedGraph ;
    rdfs:comment "A named graph as specified in [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-named-graph)." .

seg:IdentGraph a rdfs:Class ;
    rdfs:comment "A graph understood as an abstract type, identified by its content, irrespective of any features like name, annotations, etc. This definition is supposed to support reasoning over graphs." .
```


##### Graph Identity

```
DEF

seg:identifiedBy a rdf:Property ;
    rdfs:comment "Establishes what defines the identity of a graph." .

seg:Identifier a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by the IRI under which it can be retrieved, i.e. two graphs with identical content but different names are different graphs. Two graphs with the same name must either be merged, named apart or removed." .

seg:Content a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by its content, i.e. two graphs with the same content but different names can be entailed to be equal (vulgo to be owl:sameAs)." .
```


##### Graph Naming

```
DEF

seg:naming a rdf:Property ;
    rdfs:comment "Establishes the naming semantics." .

seg:Address a rdfs:Class ;
    rdfs:comment "The graph name carries no meaning on its own but serves merely to address the graph as a network retrievable resource." .

seg:Overloaded a rdfs:Class ;
    rdfs:comment "The graph name carries meaning on its own, i.e. it denotes something else than the graph itself, in addition to serving as an `seg:Address`." .

seg:overloading a rdf:Property ;
    rdfs:comment "Describes the kind of meaning that the overloaded graph name conveys. A non-exclusive list of possible values is `seg:DateOfIngestion`, `seg:DateOfCreation`, `seg:DateOfLastUpdate`, `seg:Source`, `seg:Provenance`, `seg:AccessControl`, `seg:Version`, `seg:TopicOfGraph`, `seg:LocationDescribed`, `seg:TimeDescribed`" .
```


##### Graph Mutability

```
DEF

seg:mutability a rdf:Property ;
    rdfs:comment "Establishes if the graph is considered to represent an immutable abstract graph type or a mutable source of RDF data." .

seg:GraphSource a rdfs:Class ;
    rdfs:comment "A mutable source of RDF data, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-source)." .

seg:GraphType a rdfs:Class ;
    rdfs:comment "An immutable graph, its type defined by its content." .
```


##### Graph Definitions

To flesh out the descriptions of the graph types defined above we need one last thing:
```
DEF

seg:Undefined a rdfs:Class ;
    rdfs:comment "An utility class to describe that this property has no value for this class." .
```

Putting the vocabulary just established to good use: 
```
seg:NestedGraph 
    a seg:Graph ;
    seg:identifiedBy seg:Identifier ;
    seg:naming seg:Address ;
    seg:mutability seg:GraphSource .
```

```
sd:NamedGraph 
    a seg:Graph ;
    seg:identifiedBy seg:Undefined ;
    seg:naming seg:Undefined ;
    seg:mutability seg:Undefined .
```

```
seg:IdentGraph 
    a seg:Graph ;
    seg:identifiedBy seg:Content ;
    seg:naming seg:Address ;
    seg:mutability seg:GraphType .
```

```
:MyGraph_1 
    a seg:Graph ;
    seg:identifiedBy seg:Identifier ;
    seg:naming [ rdf:value seg:Overloaded ;
	             seg:overloading seg:TopicOfGraph ] ;
    seg:mutability seg:GraphSource .
```



##### Graph Naming Example

The [RDF 1.1 WG Note](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/#declaring) suggests to use the [SPARQL 1.1 Service Description](http://www.w3.org/TR/sparql11-service-description/) vocabulary to describe graph semantics, giving the following example:
```
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF;
    sd:namedGraph [
        sd:name "http://example.com/ng1";
        sd:entailmentRegime er:RDFS
    ] .
```

In the following we use the `seg:` vocabulary to extend this example towards a mixed environment of named and nested graphs:
```
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        seg:graphType seg:NamedGraph 
    ] ;
    sd:namedGraph [
        sd:name http://example.com/NestedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        seg:graphType seg:NestedGraph 
    ] .
```
Note that specifying a graph to be of type `seg:NamedGraph` effectively amounts to stating that we can't say anything definite about its naming semantics.


Having to explicitly specify the semantics of each graph is cumbersome. The SD vocabulary provides a property to define the default entailment regime for all named graphs in a dataset. We extend the vocabulary analogously by a property to define a default type for all graphs in a dataset:

```
DEF

seg:defaultGraphType a rdf:Property ;
    rdfs:comment "Defines the graph type for all graphs in a dataset."
```

The following example defines all named graphs to be of type `seg:NestedGraph`, but also adds an exception to that rule:
```
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
	seg:defaultGraphType seg:NestedGraph ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
		seg:graphType seg:NamedGraph
    ] .
```

#### Dataset Vocabulary

Last not least a reasonably complete approach to named graph semantics should provide some means to specify if a dataset is to be interpreted as the merge of all of its named (and therein nested) graphs, or if each named graph is to be interpreted separately.

One way to implement this might again be an extension to the [SPARQL 1.1 Service Description](http://www.w3.org/TR/sparql11-service-description/) vocabulary that allows to describe the intended semantics.

> [TODO]  develop a suitable set of vocabulary terms 

The [Dydra](https://dydra.com/home) graph database to the same effect implements a small set of special terms used in the prologue of a query . 
To get all named graphs without needing a graph clause in the query, the prologue uses:
``` 
FROM <urn:dydra:named>
```
or, to include the default graph as well:
``` 
FROM <urn:dydra:all>
```
It also permits to explicitly use what has already been defined as default
``` 
FROM <urn:dydra:default>
```
which in Dydra's case is just the default graph, but other databases take a different approach, merging all named graphs into the default graph. This default behaviour again should be described in a dataset service description by a vocabulary TBD, as hinted above.




### Mapping Fragment Identifiers to Standard RDF

The singleton properties based mapping introduced [above](#singleton-properties-mapping) can be extended to annotate individual terms in a statement by using `rdfs:domain`, `rdfs:range` and a newly introduced `seg:relation` to annotate subject, object and predicate of the relation. Further properties `seg:term`, `seg:triple` and `seg:graph` allow to refer to all terms or all triples in a graph, or to the graph itself explicitly.
```
DEF

seg:domain a rdf:Property ;
    rdfs:subPropertyOf rdfs:domain ;
    rdfs:label "s" ;
    rdfs:comment "Refers to all subjects in a graph, fragment identifier is `#s`" .

seg:range a rdf:Property ;
    rdfs:subPropertyOf rdfs:range ;
    rdfs:label "o" ;
    rdfs:comment "Refers to all objects in a graph, fragment identifier is `#o`" .

seg:relation a rdf:Property ;
    rdfs:label "p" ;
    rdfs:comment "Refers to all properties in a graph, fragment identifier is `#p`" .

seg:term a rdf:Property ;
    rdfs:label "term" ;
    rdfs:comment "Refers to all terms in a graph, fragment identifier is `#term`"" .

seg:triple a rdf:Property ;
    rdfs:label "t" ;
    rdfs:comment "Refers to the all statements in a graph, fragment identifier is `#t`" .

seg:graph a rdf:Property ;
    rdfs:label "g" ;
    rdfs:comment "Refers to the graph itself, fragment identifier is `#g`" .

```
> [TODO] do we also need a reference to nodes, i.e. subjects AND objects?

To give a complete example:
```
:a :b :c .
:a :b_1 :c .
:b_1 seg:aspectOf :b ;  
     seg:inGraph _:g ;  # graph containment itself *is* an annotation
     seg:domain [       # annotating the subject
         :f :g ] ;
     seg:range [        # annotating the object
         :h :i ] ;
     seg:relation [     # annotating the property
         :k :l ] ;
     seg:triple [       # annotating the triple itself
         :o :p ] ;
     seg:graph [        # annotating the nested graph itself
         :q :r ] .
_:g :d :e .             # annotating the nested graph *or* some aspect of it
```

Applying this mapping to the introducing example produces:
```
:Alice :buys :House .
:Alice :buys_1 :House .
:buys_1 seg:aspectOf :buys ;
        seg:domain [ 
            :age 40 ] .
```

Of course we can also apply fragment identifiers to the mapping and arrive at a considerably shorter representation:
```
:a :b :c .
:a :b_1 :c .
:b_1 seg:aspectOf :b ;
     seg:inGraph _:g .
:b_1#s :f :g .          # annotating the subject
:b_1#o :h :i .          # annotating the object
:b_1#p :k :l .          # annotating the property
:b_1#t :o :p .          # annotating the triple
:b_1#g :q :r .          # annotating the nested graph itself
_:g :d :e .             # annotating the nested graph *or* some aspect of it
```
In a more realistic example however the difference isn't that noticeable:
```
:Alice :buys :House .
:Alice :buys_1 :House .
:buys_1 seg:aspectOf :buys .
:buys_1#s :age 40 .
```




## Discussion

This proposal may seem very far reaching, but we claim that all things considered it is a rather minimalistic approach. All proposals that are even more reduced leave too many problems untouched and too many issues in need of tedious explication by further statements or to be handled in out-of-band arrangements. This proposal also tackles the fundamental issues that make sharing of data between different applications so brittle: it strikes a new balance between application-driven instance-oriented intuitions and OTOH integration-driven "existentialist" logic fixings and a focus on statements as abstract, universally true types. It aims to make the fault lines between these two paradigms more readily visible and therefore easier to navigate. The basic, set-based design of RDF remains untouched, but is extended towards more usable modelling primitives, vastly improved expressiveness and a clearer separation of the realms of application and integration, to the advantage of both.

However, a lot is still missing: querying and reasoning have not been discussed enough and other serializations than Turtle like JSON-LD (a must), N-Triples/Quads (presumably unproblematic) or even RDF/XML (probably out of scope) have been completely ignored.
Different mappings to standard RDF have been discussed, but a more thorough investigation seems necessary to either settle on one mapping or provide clear guidance when to use which alternative.
In addition to the technical aspects of mappings also the relation to popular modelling patterns and strategies should be investigated in more detail, e.g. how does the proposed approach relate to n-ary modelling patterns, how does it handle popular use cases like provenance, how would it be applied to established patterns from the ODP repository, etc. Also missing is a more thorough discussion of how shapes can be supported and may benefit from nested graphs. 
Last not least it has to be compared to other approaches in the field like the DnS pattern (i.e. n-ary relations and shortcut links), RDF-star, Oracle's RDFn proposal, etc.






# TODO
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

## Examples

The following set of examples aims to show how the different syntactic constructs on the level of terms, lists and graphs mesh together and because of their structural similarities can feel as a coherent whole.




[TODO]  FROM HERE ON A LOT OF OUTDATED SYNTAX



### nested graphs

a simple triple with annotations
	id:1@{ :a :b :c } 
	id:1#s :d :e .
	id:1#o :f :g .
	id:1#t :h :i .

the same without explicit name
	{ :a :b :c } #s :d :e ;
                    #o :f :g ;
                    #t :h :i .

multiple triples, the whole graph annotated
	{ :a :b :c 
	  :d :e :f } :g :h .

multiple triples, each one annotated
	{ :a :b :c 
	  :d :e :f } #t :g :h .


some terms with specific identification semantics
	:a|M :b :c|A .
	id:1|A :d :e .
but that’s daring. better use proper brackets
	<M| :a> :b <C| :c> .
	<A| id:1> :d :e .
   that also opens the way to term-naming + annotation
	id:2@<:a> :b :c .
	id:2 :f :g .
   which is another way to express
	id:3 @{ :a :b :c }
	id:3#s :f :g .
   or, more succinct
	{ :a :b :c } #s :f :g .



### examples of relation to other prominent approaches
	
	n-ary relations
		quickly get quite involved and hard to use

	RDF reification
		provide an interesting but irritating semantics
		but are syntactically verbose
		
	Notation3 formulas
		provide a nice syntax, but a specialist semantics

	named graphs

	literal graphs

	singleton properties
		in nested graphs the un-annotated super-type is front and center, 
		annotations only become visible on demand. 
		in singProp however the property is rather opaque, 
		and therefore the detail clutters the view on the basic fact.

	RDF-star
		id:1@{ :a :b :c } :d :e .   # nested asserted triple instance
		{ :a :b :c } :d :e .        # anonymous asserted nested triple instance
		<< :a :b :c >> :d :e .      # quoted unasserted triple type
		id:1@<< :a :b :c >> :d :e   # quoted unasserted triple instance 
		{ OE | :a :b :c } :d :e .   # anonymous quoted unasserted nested triple instance


### RDF/pg - Improving Interoperability with Property Graphs


### Mapping an Involved Example to Triples
e.g. the introducing 10-line example

### update operation
and how it doesn't change the relation footprint

### quotation
superman, versioning, credentials, Pat's warrants

### reasoning
AZ's vision of reasoning over graphs as types






## Appendix

### Vocabulary

[TODO] 	the whole vocabulary in one place

### Mapping 

[TODO] 	the whole mapping in one place


## as AND in

> [NOTE] 
>
> We might define syntactic shortcuts for `seg:aspectOf` and `seg:inGraph`, named `as` and `in`, analogous to the `a` shortcut that stands in for `rdf:type` in Turtle, but given that the main purpose of the mapping is to provide clarity about the semantics, but not to be used in practice, this is probably not necessary.



## Shapes

> [TODO]  this is WORK IN PROGRESS
> The main aim is to establish anchor points that allow to impose tighter constraints on shapes and semantics of RDF constructs - nested graphs, lists and even terms, the idea being that establishing *one* such anchor point can solve *many* problems
> However, not everything is well thought out yet:
> - obviously the shortcut syntax isn't finished
> - maybe the mapping to RDF has to use [inclusion/transclusion](#importing-assertions) to be really on the safe side w.r.t. monotonicity, maybe a syntactic mapping to n-ary relations is good enough
> - the mix of shape and semantics needs more investigation
> - are shapes really the best overarching abstraction and does the effect warrant the effort?

Shapes have been proposed in different variants like SHACL and SHEX to improve reliability and predictability of data modelling. 
We extend this approach to nested graphs, aiming at a tighter integration of shapes into RDF data. We then carry that syntactic feature over to lists as well as individual nodes to provide streamlined solutions for some nagging problems of RDF.

To that end we define the following property:
```
seg:hasShape a rdf:Property ;
    rdfs:comment "The subject - either a nested graph, a list or a term - follows the description of the object, a shape definition provided in SHACL or SHEX." .
```

The following example annotates a nested graph with a SHACL shape definition:
```
[]{ :s :p :o } seg:hasShape :MyFirstShape .
:MyFirstShape a sh:NodeShape ;
    [...]
```
The same principle can be applied to lists and terms:
```
[ a rdfs:Collection ;
  rdf:value ( :a :b :c :d ) ;
  seg:hasShape :MyFirstList 
  ]
[ a rdfs:Resource ;
  rdf:value <:a> ;
  seg:hasShape :MyFirstTerm
  ] :b :c .
```
We will introduce some examples of useful shapes for lists and terms in following sections.
[TODO] will we indeed?

However, we first need to tackle an obvious problem: the approach is syntactically rather verbose.


### Syntax
The basic syntactic instrument to overcome the verbosity of the approach is a keyword prepended to a nested graph, list or term. To that end again the square bracket syntax introduced with nested graphs is reused, combined with a query parameter on the name of the construct to indicate the intended shape, e.g.:
```
[:g1?shape=SomeGrafShape]{ :a :b :c }       # nested graph
[:l1?shape=SomeListShape]( :a :b :c :d )    # list
[:t1?shape=SomeTermShape]< :a >             # term
```
[TODO]  this requires to name any graph that has non-standard semantics
            but that is probably not too grave a demand
        or just omit the name, but keep the query parameter?, e.g.:
            `[?shape=SomeGrafShape]{ :a :b :c }`
            ?

Not every shape can be defined on every primitive, e.g. list shapes can only be applied to rounded bracket lists, identification shapes only to terms in pointy brackets, complex shapes only to nested graphs. Shape definitions have to declare to which primitives they can be applied. 

[TODO]  how are the shape naming keywords defined?
            that probably needs some apparatus
            or is it just a (namespaced) IRI ?
            but that wouldn't work well as query parameter
        can there be a directory of sorts, a vocabulary?
        is another special addition to the header needed :-( ?


### Applications

In following sections we will discuss 
- [list shapes](#list-shapes) to better meet developer expectations, 
- [graph shapes](#configurable-semantics-configsemantics) to configure the semantics of data and 
- [term shapes](#disambiguating-identification-semantics) to describe identification semantics in some detail.


[TODO]  one complete example with
        - a valid shape
        - valid namespace declarations
        - etc





## Lists

Lists are not only an indispensable construct in any programming language, they also are one of the most fundamental knowledge representation structures. From this follows that RDF should provide intuitive and easy to use means to support lists. 
To that end RDF does indeed provide two different constructs, collections and containers, but none of them hits the sweet spot of concise syntax and intuitive semantics. Without going into the merits and problems of RDF’s list apparatus in more detail we would like to suggest two extensions to it: a `length` attribute for containers and some syntactic sugar that makes Turtle’s rounded bracket syntax available to them.


### Length Attribute

Adding a length attribute to the container vocabulary enables users to describe how many entries a list is supposed to have. 
```
DEF

seg:length a rdf:Property ;
    rdfs:domain rdfs:Container ;
    rdfs:range xsd:integer ;
    rdfs:comment "Describes the number of entries of an rdf:Collection (rdf:Bag, rdf:Seq, rdf:Alt). Numbering is expected to start from 1 and missing entries may be interpreted as implicit existentials (i.e. blank nodes)." .
```

Applications will have to decide what to make of containers that have less or more entries or whose entries are not consecutively numbered, beginning with `rdf:_1`. They may replace missing entries by blank nodes, like e.g. in the following sequence that misses the second entry. In any case at least they have been warned that something might be amiss.
```
_:x a rdf:Bag ;
    seg:length 3 ;
    rdf:_1 :Alice ;
    rdf:_2 [] ;
    rdf:_3 :Carol .
```
The RDF collection vocabulary was introduced to provide OWL with a means to describe axiomatic lists of some definite length. A well-formed collection does indeed do that, but RDF can give no guarantees about well-formedness. A length attribute for RDF containers achieves the same effect, with much less syntactic verbosity.


### Syntactic Sugar for Containers

RDF collections, despite - or because of - their structural verbosity get all the syntactic sugar in RDF's popular Turtle serialization. That seems unbalanced given that containers are easier to query and more performant (see Daga et al, 2019, Modelling and Querying Lists in RDF - A Pragmatic Study).
We propose to extend the syntactic sugar for RDF collections in Turtle by a prefix that makes the rounded bracket usable for containers and safer for non-axiomatic collections. We define the following list shapes:

- `BAG`, like rdf:Bag
- `SEQ`, like rdf:Seq
- `ALT`, like rdf:Alt
- `OWL`, like RDF collection, but explicitly for OWL axiomatic lists

A length attribute can be appended to the type indicator, delimited via a colon, e.g.:
```
SEQ:3
```
To state that a list of Alice's cars contains exactly three entries, describing the order in which she bought those cars, we write:
```
:Alice :owns [?SEQ:3]( :Sedan :StationWagon :Coupe ) .
```

This is much shorter than the corresponding RDF sequence without syntactic sugar:
```
:Alice :owns [
    a rdf:Seq ; 
    seg:length 3 ;
    rdf:_1 :Sedan ; 
    rdf:_2 :StationWagon ; 
    rdf:_3 :Coupe
]
```
By default list entries follow the standard RDF semantics, i.e. they are interpreted, referentially transparent etc. Other options will be discussed below.
[TODO]  will they?


#### SET Containers

An open question is if for completeness we also need a `SET` container, which could be provided with a length attribute, but would establish that order is not important and duplicates will be purged. However, the difference to regular n-ary relations might be too negligible to justify its introduction, as the difference in semantics between e.g. `:a :b :c , :d .` and `:a :b (SET :c :d) .` is quite marginal.


#### ARRAY Containers

Another candidate for a list type is `ARY`, short for array. This type would be catered to developers looking for a list with strong syntactic guarantees, e.g. the list being well-formed (or otherwise throwing a syntax error), numbered beginning with 0, providing explicit numbering to record empty slots, ordered, of definite length, with bag semantics. 


### List Shapes

[TODO]  too much handwaving

Developers often demand lists with guarantees w.r.t. completeness, closedness etc. Those can be provided via the same mechanisms that we envision to manage semantics of nested graphs: more rigid structures can be provided through quoted graphs and graph literals, and closed world and unique name assumptions may be declared explicitly. 

Shape languages like SHACL and SHEX provide the means to define these and other list types and add user-defined criteria like further restrictions on the value types (e.g. the first value has to be a literal), on the kind of ordering, etc. However, they can’t change the property type which has to be `rdfs:member`.

The list typing syntax makes it easy to deploy such user-defined list shapes, e.g.:
```
:LS_1 rdf:type :Shape ;
    rdfs:comment "my first list shape" ;
    shape:definitions [...] .
[?shape=:LS_1]( :a :b :c :d ) :y :z .
```

[TODO]  an example of how to define a proper list shape


#### Lists as Objects - Nameable, Annotatable

Lists in RDF already are instances, provided with identity, and can be named and referenced like nested graphs, e.g.:
```
:Alice :has [
    a rdf:Seq ;
    rdf:_1 :X ;
    rdf:_2 :Y .
    rdfs:label :AliceList ;    # nothing wrong with giving the list a name
]
```
Distributive ForEach semantics that refer to each entry in a list can be achieved through fragment identifiers, e.g.:
```
[?SEQ](:a :b :c )#term :d :e .
```
entails 
```
:a :d :e .
:b :d :e .
:c :d :e .
```	
or, to give a slightly more involved example:
```
:Alice :has [:AliceList?SEQ:2](:X :Y)#term :d :e .
```
(and the same as regular RDF:
```
:Alice :has [
    rdfs:label :AliceList ;
    a rdf:Seq ;
    seg:length 2 ;
    rdf:_1 :X ;
    rdf:_2 :Y .
]
:MyList#term :d :e .
```	
) entails:
```	
:X :d :e .
:Y :d :e .
```
 
 It has of course to be ensured that annotations are only applied to members of the list, not to other attributes like length and name.



<!--- 
		more details and discussions about lists in my mail                              
		"summarizing a semanticweb@w3.org thread on lists from Aug/Sep 2022" 		
-->

