# Introduction


RDF is a knowledge representation formalism optimized for simplicity. Its design favours ease of use and straightforward scalability. However, this simplicity comes at a cost: RDF struggles with complex information needs.
The simplicity of the basic triple  makes it quite cumbersome to model information that is rich on facets, detail and context. 
Navigating such involved constructs often requires to first get familiar with their specific modelling choices and style.
Even if the data itself is straightforward, it might lack detail and context when re-used in other applications.
Such use cases - complex information modelling needs like e.g. in fact checking or the cultural heritage domain, and complexity that stems from integrating disparate sources in new, unforeseen applications - struggle with the limited expressivity that RDF provides and have to resort to complicated modelling techniques like involved ontology design patterns and out-of-band means like the only loosely defined named graph mechanism.

This is not to say that RDF doesn’t work well. Indeed it does surprisingly well, on a big scale, with a lot of noteworthy achievements and successes - despite _and_ because of its simplicity. Consequently this simplicity should not be jeopardized. 
However, RDF could well use some tooling to manage complex situations that consistently frustrate users and lead to involved and incompatible workarounds, reducing its attractiveness as knowledge representation formalism and hindering data integration and exchange.

This proposal introduces a set of tools to extend RDF's expressivity in a variety of ways and directions. However, the proposed extensions stay in the background as long as possible. They don’t require to be used, but aim to just be in reach when the need for disambiguation and increased expressivity arises. This restraint is essential not just to ensure backwards compatibility, but also to guarantee that simple tasks remain simple, and the extra tooling to manage complexity doesn’t get in the way of straightforward use cases.

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

The Nested Named Graphs (NNG) proposal tries to learn the right lessons from this rich history. It tackles the problem space in steps, the basic building block being a syntactic device to address (sets of) triples. That base serves as the anchor point for more involved constructs to tackle more specific problems. This proposal hopes to employ useful abstractions that group the most important and frequent tasks into a set of different syntactic devices. It aims to keep orthogonal issues separate and thereby reduce the danger of overwhelming the user with too many choices and subtle differentiations.



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
:MyFirstGraph {:s :p :o}
```

This simple primitive can be employed in many different ways:
```
:MyGraph1 { :a :b :c } :d :e .     # creation and annotation in one stroke
:f :g :MyGraph1 ;                   # a separate reference to :MyGraph1
   :h :i .
:SomeGraph2 {
    :ThisGraph3 {:k :l :m , :n}    # heavy nesting
    :o :p } :q :r .
:MyGraph1 :s :ThisGraph3 ;
          :t :SomeGraph2 .
:ThatGraph4 {:u :v :w} .           # creation of :ThatGraph4
[]{ :a :b :c }                      # _:g5, a different graph than :MyGraph1
[]{ :a :b :c }                      # _:g6, yet another graph
:ThatGraph4 :y :z .                 # annotating :ThatGraph4 in a separate step
```
Graphs can be named and annotated in the same statement, but they also can be named when created and only later be annotated.
An anonymous nested graph is different from a named nested graph with the same content.

With two anonymous nested graphs that contain the same statement it is, as customary in RDF, an application decision if they are to be leaned or not

A nested graph can only be named at the location where it is defined, as appending a name to a nested graph creates a new instance. Because of that an unannotated nested graph will always be distinguishable from a nested graph that was introduced, named and annotated. 





## Discussion

This proposal may seem very far reaching, but we claim that all things considered it is a rather minimalistic approach. All proposals that are even more reduced leave too many problems untouched and too many issues in need of tedious explication by further statements or to be handled in out-of-band arrangements. This proposal also tackles the fundamental issues that make sharing of data between different applications so brittle: it strikes a new balance between application-driven and instance-oriented intuitions and OTOH integration-driven "existentialist" logic fixings and a focus on statements as abstract, universally true types. It aims to make the fault lines between these two paradigms more readily visible and therefore easier to navigate. The basic, set-based design of RDF remains untouched, but is extended towards more usable modelling primitives, vastly improved expressiveness and a clearer separation of the realms of application and integration, to the advantage of both.

However, a lot is still missing: querying and reasoning have not been discussed enough and other serializations than Turtle like JSON-LD (a must), N-Triples/Quads (presumably unproblematic) or even RDF/XML (probably out of scope) have been completely ignored.
Different mappings to standard RDF have been discussed, but a more thorough investigation seems necessary to either settle on one mapping or provide clear guidance when to use which alternative.
In addition to the technical aspects of mappings also the relation to popular modelling patterns and strategies should be investigated in more detail, e.g. how does the proposed approach relate to n-ary modelling patterns, how does it handle popular use cases like provenance, how would it be applied to established patterns from the ODP repository, etc. Also missing is a more thorough discussion of how shapes can be supported and may benefit from nested graphs. 
Last not least it has to be compared to other approaches in the field like the DnS pattern (i.e. n-ary relations and shortcut links), RDF-star, Oracle's RDFn proposal, etc.

