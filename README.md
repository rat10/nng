# Nested Named Graphs (NNG)

## Overview

Nested Named Graphs (NNG) is a proposal to the RDF 1.2 Working Group [0]. It provides a simple facility to enable annotations on RDF in RDF. 

The proposal doesn't require any changes or additions to the abstract syntax of RDF [1] and can be deployed in quad stores that support RDF 1.1 datasets [2]. It is realized as a combination of syntactic sugar added to the popular TriG syntax [3] and a vocabulary to ensure sound semantics [4]. Mappings to triple-based approaches are provided. The proposal can be tested in a publicly accessible prototype implementation with SPARQL [5] support.

After an initial version of this proposal has been presented to the RDF 1.2 Wg (see below in the "attic" section), a few concerns and requests have been voiced: more examples, shorter examples, formalization, shorter presentation, etc. Some of these requests obviously contradict each other, some are hard to meet at this point. This small site tries to provide both a short introduction in this section and more detailed discussions in separate sections (see links below).

Please be aware that annotations in RDF are a pretty complex topic and the RDF-star proposal, although apparently simple, fails to address those complexities in meaningful ways. However, a standard that aims to take shortcuts without properly thinking through the consequences will not do anyone a favour. A useful annotation mechanism has to be simple at the core, the way to develop it however obviously isn't. The NNG proposal addresses a lot of concerns that RDF-star glosses over, but which shouldn't be ignored. So please take the necessary time to consider this proposal. 


## Concept

Nested Named Graphs aim to integrate into existing applications without getting in the way of less involved use cases:
- Nesting of graphs allows for the addition of unforeseen aspects without a need to modify existing structures and queries.
- An annotated nested graph is actually a supertype of the graph into which its annotations transform it (as becomes apparent in the mapping to standard RDF). This guarantees that annotations don't cloud the view on the principal relation.
- Annotations are applied to the statements they annotate. Their semantics are not prone to subtle and counter-intuitive changes because of the requirement to introduce intermediary nodes.
- Annotated statements represent tokens, which is the intuitive referent of use cases like administration and contextualization.
- Optional fragment identifiers allow to identify with great precision the target of an annotation: a term on subject- or object position, the relation itself or the statement as a whole. However their use is not mandatory, defaulting to a loosely bound "cavalier" approach semantics.
- Nested Named Graphs impose no artificial differentiation between singleton and multiple statements: a graph containing only one statement is a graph all the same.
- They provide a means to solidly specify their semantics while remaining backwards compatible to any application of named graphs in the wild.
- Special needs like unasserted assertions and quotation semantics are implemented via an extra mechanism, aiding a separation of concerns.

The design of Nested Named Graphs aims for the least surprise. Annotated or not, they are always:
- asserted (like RDF 1.1 named graphs, but contrary to other approaches like Notation3, Named Graphs by Carroll et al 2005, RDF standard reification and RDF-star triple terms)
- referentially transparent (like RDF 1.1 named graphs and RDF standard reification, but contrary to other approaches like Notation3, Named Graphs by Carroll et al 2005 and RDF-star triple terms)
- tokens, as they are always named, either explicitly by the user or implicitly via blank nodes (like RDF standard reification and Named Graphs by Carroll et al 2005 and RDF 1.1 named graphs, but contrary to other approaches like Notation3 and RDF-star triple terms)



## Syntax
The main component of the proposal is a [syntactic extension](serialization.md) to TriG that adds the ability to nest named graphs inside each other. The following short example may give a first impression of its various virtues:
```turtle
prefix :    <http://ex.org/>
prefix nng: <http://nng.io/>
:G1 {
    :G2 {
        :Alice :buys :Car .
        :G2 nng:domain [ :age 20 ] ;           # Alice, not the car, is 20 years old
            nng:relation [ :payment :Cash ] ;  
            nng:range nng:Interpretation ,     # Alice buys a car, not a website
                       [ :color :black ].  
    } :source :Denis ;                         # an annotation on the graph
      :purpose :JoyRiding .                    # sloppy, but not too ambiguous
    :G3 {    
        [] {                                   # graphs may be named by blank nodes 
            :Alice :buys :Car .                # probably a different car buying event
            THIS nng:domain [ :age 28 ] .      # self reference
        } :source :Eve .    
    } :todo :AddDetail .                       # add detail
}                                              # then remove this level of nesting
                                               # without changing the data topology
```
The same as N-Quads:
```turtle
<http://ex.org/G1>    <http://nng.io/transcludes> <http://ex.org/G2>                                <http://ex.org/G1> .
<http://ex.org/Alice> <http://ex.org/buys>        <http://ex.org/Car>                               <http://ex.org/G2> .
<http://ex.org/G2>    <http://nng.io/subject>     _:o-37                                            <http://ex.org/G2> .
_:o-37                <http://ex.org/age>         "20"^^<http://www.w3.org/2001/XMLSchema#integer>  <http://ex.org/G2> .
<http://ex.org/G2>    <http://nng.io/predicate>   _:o-38                                            <http://ex.org/G2> .
_:o-38                <http://ex.org/payment>     <http://ex.org/Cash>                              <http://ex.org/G2> .
<http://ex.org/G2>    <http://nng.io/object>      <http://nng.io/Interpretation>                    <http://ex.org/G2> .
<http://ex.org/G2>    <http://nng.io/object>      _:o-39                                            <http://ex.org/G2> .
_:o-39                <http://ex.org/color>       <http://ex.org/black>                             <http://ex.org/G2> .
<http://ex.org/G2>    <http://ex.org/source>      <http://ex.org/Denis>                             <http://ex.org/G1> .
<http://ex.org/G2>    <http://ex.org/purpose>     <http://ex.org/JoyRiding>                         <http://ex.org/G1> .
<http://ex.org/G1>    <http://nng.io/transcludes> <http://ex.org/G3>                                <http://ex.org/G1> .
<http://ex.org/G3>    <http://nng.io/transcludes> _:b41                                             <http://ex.org/G3> .
_:b41                 <http://nng.io/subject>     _:o-42                                            _:b41 .
<http://ex.org/Alice> <http://ex.org/buys>        <http://ex.org/Car>                               _:b41 .
_:o-42                <http://ex.org/age>         "28"^^<http://www.w3.org/2001/XMLSchema#integer>  _:b41 .
_:b41                 <http://ex.org/source>      <http://ex.org/Eve>                               <http://ex.org/G3> .
<http://ex.org/G3>    <http://ex.org/todo>        <http://ex.org/AddDetail>                         <http://ex.org/G1> .
```



For a more extensive set of simple examples check out the [Introduction by Example](introexample.md)

A complementary syntactic extension to JSON-LD remains TBD. 

[Mappings](mappings.md) to triple-based formats like Turtle and N-Triples are provided (or worked on). A mapping to RDF/XML so far isn't planned, but might be based on RDF/XML's syntactic sugar for RDF standard reification.

See also an example of a [BNF](sources/trig-nng.bnf) for the NNG syntax - not exactly but close to the version actually deployed in the prototype notebook (see below).


## Fragments and Identification Semantics

The introducing example makes use of a [fragment identification](fragments.md) vocabulary to annotate individual terms on a statement. This can be helpful e.g. to faithfully represent Labeled Property Graphs in RDF as it allows to clearly separate e.g. provenance annotations on the whole graph from qualifications of the relation type. 

Fragment identification also comes in handy when [identification semantics](identification.md) need to be disambiguated, e.g. to clarify if an IRI is used to refer to a web resource or to the entity that web resource describes. Another possible application is the disambiguation of [graph naming semantics](graphSemantics.md) when using the graph name in a statement, e.g. an annotation to the graph.


## Configurable Semantics

RDF standard reification is often used to document "unasserted assertions", that is statements that are to be documented but not endorsed (although that interpretation of the reification vocabulary is not supported by the RDF specification). The RDF-star CG report favors a related form of citation, but with stricter semantics. The NNG proposal supports both use cases with specific syntactic sugar, see the section on [citation semantics](citationSemantics.md).

The underlying mechanism of configurable inclusion of [graph literals](graphLiterals.md) can be used for much more elaborate [configurable semantics](configSemantics.md) use cases, e.g. to support closed world semantics on selected parts of the data.


## Querying
The discussion of matters related to [querying](querying.md) is not finished yet. Simple querying tasks are pretty straightforward. Querying for statements with non-standard semantics is straightforward as well.   
For some of the more complicated questions w.r.t graph nesting and query traversal of nested graphs see an [example walk through](queryingPaths.md) and the accompanying [shell script](tests/queryingPaths.sh).   
However, for querying of nested graphs to become as easy as authoring them the traversal of chains of nested graphs has to become easier than it is now. SPARQLs lack of support for queries across graphs is a problem here. The [example walk through](queryingPaths.md) provides a solution, but it's not easy enough yet. We are currently investigating what to do about that.


## Public Notebook
A prototype implementation in the Dydra graph store [6], including an appropriate extension to SPARQL, provides a public [notebook](https://observablehq.com/@datagenous/nested-named-graphs) that can be used to explore, test and play around with the proposal.   
Be aware however of a few caveats. The notebook is not multi-user enabled: if two users play with it at the same time, they may overwrite each others sample data. Also it doesn't yet support all syntactic sugar; especially support of syntactic sugar for graph literals is still sketchy. And last not least it is not helpful w.r.t. syntax errors: it won't point out to you where you forgot a punctuation mark.


## Details

The finer details of this proposal are discussed in separate sections:

- [nesting graphs](transclusion.md)  
  the basic mechanism to nest graphs
- [surface syntax](serialization.md)  
  syntactic sugar to nest and annotate graphs
- [introduction by example](introexample.md)  
  a walkthrough illustrating core features
- [more examples](examples.md)  
  WG use cases and other applications


- [fragment identification](fragments.md)  
  addressing and annotating individual nodes in a statement
- [identification semantics](identification.md)  
  applying fragment identification to solve the semantic web identity crisis
- [graph semantics](graphSemantics.md)  
  a semantics for (not only nested) named graphs that doesn't break existing usage


- [mappings to basic triples](mappings.md)  
  a lossless translation from NNG to standard triples
- [querying](querying.md)  
  a still rudimentary discussion and some examples


- [graph literals](graphLiterals.md)  
  a basic building block to enable configurable semantics
- [citation semantics](citationSemantics.md)  
  semantic/syntactic sugar for common use case like quoting and unasserted assertions
- [configurable semantics](configSemantics.md)  
  N3 formulas, closed world, unique name... you name it!



## Semantics

Two different approaches to the semantics of Nested Named Graphs are possible. One may either define the semantics via a mapping to triples or via the provision of means to describe the semantics of named graphs.

Mappings to triples can go three ways: they can follow the singleton properties approach [8], providing a still quite usable surface syntax, or a fluents based approach [9] which has more favorable entailment properties but tends to alienate non-expert users (whereas user studies have found that expert users do indeed like its straightforwardness) and finally they can also go the way of n-ary relations [11]. These mappings all stay close to standard RDF and are discussed [in detail](mappings.md) in an extra section.

Defining Nested Named Graphs as an extension of named graphs is syntactically straightforward, but has two downsides. It requires support of quads in an RDF store which, while certainly quite common, is neither the norm nor can it be considered ubiquitous. A second problem is the undefined state of named graph semantics, which the RDF 1.1 WG failed to resolve. Our proposal does not impose a more definite semantics on everybody, but provides a means to specify a clearer semantics on demand. To that end we provide a small [vocabulary](graphSemantics.md) to solidly define the semantics of named graphs - nested or not -, as a default arrangement per dataset or per graph individually via the SPARQL dataset description vocabulary. No change whatsoever to already deployed named graphs is required. 

Instead, using the proposed nesting mechanism implicitly fixes the semantics. However, this fixing does only apply to the context of nesting, just like addressing a graph in a WHERE clause unambiguously makes the name address the graph without any further consequences on the naming semantics of named graphs in general (e.g. when using the graph name outside a WHERE clause). 
Our proposal defines the semantics of nested graphs in a way reflecting users intuitions, bridging the gap between the abstract definitions in RDF and actual practice:
- the graph name denotes the pair of the name and the graph it names
- the graph is understood as a graph source as defined informally in the RDF 1.1 Concepts and Abstract Syntax [1], a mutable representation of a set of triples (or, phrasing it more correctly: the name may over time refer to different sets retrievable from the address the name encodes)
- the triples in that graph are interpreted, they are referentially transparent just like any other snippet of RDF (i.e., entailments are possible and warmly welcomed).
Note that a similar approach was already proposed by Hayes in 2011 [10] and in our opinion it not only makes sense but is a necessary step forward towards an RDF semantics that actually captures the intuitions and makes sense to non-logicians. It is in our proposal designed as *an additional layer*, that *doesn't change* the semantics of RDF *but extends* it towards actual practice.

<!-- 
TODO check the RDF 1.1 dataset note for which of the variants proposed there matches our intuitions the best. probably the one reflecting SPARQL semantics
-->


### The Architecture and Politics of Semantics

We would like to be quite clear about our approach to semantics: the proposed semantics doesn't change anything for anybody in practice, it just reflects realities that nobody can escape anyway. It rejects however all approaches to prolong the mismatch between the abstract set-based type semantics of RDF and its predominantly token-based reality. In that respect NNG take a strong stance opposite to the semantics proposed by the RDF-star CG or any other approaches that insist on understanding named graphs as opaque types - approaches that in our opinion make the logically safe formalistic tail wag with the very practical semantic web dog. 

We've spoken to many SemWeb'ers - rather pedestrian users and implementors as well as well-respected academics - that couldn't care less about the model-theoretic semantics of RDF anyway, but see RDF's virtues mainly as an interchange syntax supplemented by a rough consensus about meaning via shared vocabularies. That it the base for which this approach designs the semantics of Nested Named Graphs. Ignoring those people's stance will only make the already bad standing of formal semantics on the semantic web even worse. We do however claim that their intuitions can be matched and incorporated into the semantics foundations of RDF without breaking anything, by adding an additional layer of interpretation as a means to separate concerns.

Note that this proposal does not dismiss the more abstract logic-oriented applications like reasoning over graph entailments. To that end it provides a separate mechanism tailored to use-cases that need to describe and reason about graph *types*: [graph literals](graphLiterals.md).
Graph literals do not only provide a sound means to describe and reason about graphs as abstract types, they also provide the basic primitive to implement non-standard semantics via an additional *inclusion* mechanism. Syntactic sugar is provided for popular use cases like un-asserted assertions and referentially opaque quotation, but the mechanism itself is extensible as desired and an example vocabulary to support such extensions is provided.



## Design Considerations

<!-- 

it's got to be    b/c 
  tokens          qualification + administration
  asserted        otherwise too many indirections
  graphs          otherwise many use cases too tedious
  explicit ids    for graph structure in annotations   
  transparent     otherwise no harmony
  nesting         resilience against updates, n dimensions
 
-->
Metamodelling in RDF - annotating, contextualizing, reifying simple statements to better deal with complex knowledge representation needs - has been the focus of work as long as RDF itself exists. For an extensive treatment of the topic check the 300+ pages "Between Facts and Knowledge - Issues of Representation on the Semantic Web" ([PDF](sources/Between.pdf)).
One thing we learned from this huge corpus of works is that the one magic trick to resolve all the problems around complex modelling tasks in RDF most probably doesn't exist: the needs and expectations w.r.t. meta-modelling in RDF are so diverse that probably only a clever combination of techniques can meet them all reasonably well. Consequently we need to get creative, and we need to break some rules:

- *simplicity first* : maintain the focus on the simple statement. Keep annotations within easy reach, but don't let the complexity they encode cloud the overall view. Otherwise the cost in terms of usability will eclipse the increase in expressivity. One may consider this a kind of 'inversion of control'.
- *there is no free lunch*: added expressivity comes at a cost. However, the often heard argument "but you can do that with n-ary relations" is missing the point, because anything can be represented as n-ary relations; the representation might just get unusably complex. Some extension to RDF's tooling will be necessary if the modelling of complex information is to become easier.
- *late binding*: knowledge representation is a world full of rabbit holes. Provide means to solve problems when they become a problem, but not earlier. Most ambiguities are harmless most of the time. Also don't try to standardize on something too specific when the needs are diverging (as the RDF 1.1 WG had to learn the hard way with named graphs). In that case just provide ways to describe and communicate the different approaches.
- *named graphs* are almost a topic of there own. The argument that they can't be used because they have no standardized semantics and different implementations use them in different ways has to be countered with the simple fact that we don't need them to all have the same semantics - it's enough if they describe their semantics in a standardized way. Some argue that graphs are a grouping device and can't be used for singleton graphs, but we disagree: proper indexing solves that problem on the technical level, and on the practical level we see not one aspect that is exclusively concerned with only single or only multiple statements. Then there's also the "but we use graphs for X, so it can't be used for Y" argument. This is only true as long as they are understood as a flat and one-dimensional structure, but that doesn't need to be the case as our nesting approach shows.
- *separation of concerns*: don't try to solve all problems with only one mechanism. Many orthogonal needs concerning topics of knowledge representation, reasoning, implementation, etc have to be met. Trying to stuff everything in one device will only lead to more need for disambiguating triples, and more confusion. Instead an 80/20 approach is needed that caters for mainstream use cases first, but doesn't forget to serve outliers with proper extensions.
- *monotonicity* and qualification: the Open World design of RDF requires that no statement can modify the truth value of another statement. This has long been considered as making it very risky, if not impossible, to annotate statements directly. Any indirections however will inevitably lead to subtle implications that make it very hard to pin down exactly the meaning of an annotation. We go the opposite route and claim that any annotation just adds more detail and is fair game as long as it doesn't outright call the annotated statement false - the former is indeed the whole point of describing the world in RDF, whereas the latter is still forbidden. 
<!-- TODO link to ramblings/monotonicity.md ? -->
- *don't break user's intuitions*: this one is not new, but it can't be repeated often enough. Semantics is an elusive beast, exceptionally prone to misunderstandings and contextual shape-shifting. If a formalism doesn't manage to capture the most prevalent intuitions intuitively, it is almost guaranteed to be mis-used in practice. This has happened many times - see RDF standard reification, the Named Graph semantics by Carroll et al 2005, RDF-stars completely ignored TEP-mechanism - and it takes a lot of self-scrutiny to get right.

<!--
from telco.trig

- TOKENS 
  administration
  qualification

- ASSERTED 
  otherwise the connection to the annotated statement is too brittle

- GRAPHS 
  grouping (even just for the sake of it) is an important KR pattern
  and it is easier to represent singletons with a grouping device 
      than the other way round

- IDENTIFIERS 
  essential for tokens, otherwise one more triple (see RDF-star :occurrenceOf) 

- REFERENTIAL TRANSPARENCY 
  mainstream 

- NESTING
  resilience to change
  multiple dimensions
      (instead of "but we use named graphs for X, so can't use it for anything else")

- THE 20 in 80/20
  literals for types, referential opacity, un-asserted assertions etc 
  separation of concerns
-->


## Use Cases
The RDF 1.2 WG is still consolidating use cases [7]. On an abstract level the NNG approach has concentrated on meeting the following demands:

- there should be no syntactic differentiation between annotating triples and graphs
- adding annotations shouldn't require changes to existing structures, neither data nor queries 
- the link between a statement and its annotation has to be as direct as possible, as otherwise subtle ambiguities may creep in and require expensive post-hoc clarifications and administration
- the wide spectrum of popular intuitions concerning annotation and contextualization should be met equally well, administrative concerns just as well as qualification of (too) simple facts and as desires to bring some structure and compositional coherence to large and unwieldy graphs
- while the semantics of RDF is based on a set-theoretic abstraction of types of statements, practical applications work with concrete tokens. This gap has to be bridged in a way that feels natural to users but doesn't break the set-based semantics foundations
- specific needs w.r.t. semantics like lexically precise quotation should be possible, but as an extra and without making normal use cases more complicated
- probably more.

The [examples](examples.md) illustrate how Nested Named Graphs meet those demands. 




## Attic
The Semantic/Nested Named Graphs proposal was presented to the RDF 1.2 WG by means of 
- a [long text](https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72) from mid-October 23, covering a first draft of the proposal in a bit too much detail
- a [short text](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0041.html) from mid-October 23, providing a shorter introduction to the proposal
- a [short presentation](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0109.html) from late-October 23, introducing the proposal by example.
  
Discussions in the WG led to some modifications that resulted in this version here, which is completely conformant to the existing RDF 1.1 model and abstract syntax, at the expense of a bit of semantic rigidity. Some aspects like the inclusion/transclusion mechanism have undergone some changes too, so consult those older texts with caution. 


## References
[0] [RDF 1.2 Working Group](https://www.w3.org/groups/wg/rdf-star/)  
[1] [RDF 1.1 Concepts and Abstract Syntax](https://www.w3.org/TR/rdf11-concepts/)  
[2] [RDF 1.1: On Semantics of RDF Datasets](https://www.w3.org/TR/2014/NOTE-rdf11-datasets/)  
[3] [TriG](https://www.w3.org/TR/2014/REC-trig/)  
[4] [RDF 1.1 Semantics](https://www.w3.org/TR/rdf11-mt/)  
[5] [SPARQL 1.1](https://www.w3.org/TR/2013/REC-sparql11-overview/)  
[6] [Dydra graph store](https://dydra.com/home)  
[7] [RDF 1.2 WG Use Cases](https://github.com/w3c/rdf-ucr/wiki)  
[8] [Singleton Properties](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4350149/)
[9] [NdFluents](https://link.springer.com/chapter/10.1007/978-3-319-58068-5_39)
[10] [Pat Hayes' mail to the RDF 1.1 WG](https://lists.w3.org/Archives/Public/public-rdf-wg/2011Feb/0060.html) (many thanks to Niklas for unearthing this!) 
[11] [W3C Note Defining N-ary Relations on the Semantic Web](https://www.w3.org/TR/swbp-n-aryRelations/)




<!--
TODO - MAYOR ISSUES

    mappings.md   
        check the logical problem
        better promote the SP mapping
    querying.md 
        is still in a rather sorry state
    formalizations
        transclusion
        inclusion
        principal relation
        inherited annotations via nng:tree fragment identifier
        propagation of annotations


  PROPAGATION OF ANNOTATIONS
    how does annotating outside a nested graph propagate?
      putting annotations in an outer graph 
            or even the default graph
          would limit the load on reifying annotations
      can we use that?
        no, this is a question of visibility
        annotations located in the default graph are not necessarily 
          visible inside a named graph
          that depends on the query



TODO  where to put this note ?
> [NOTE] 
>
> Membership in a nested graph is understood here to be an annotation in itself. However, that means that in this paradigm there are no un-annotated types anymore (the RDF spec doesn't discuss graph sources in much detail and only gives an informal description; however, this seems to be a necessary consequence of the concept). Types are instead established on demand, through queries and other means of selection and focus, and their type depends on the constraints expressed in such operations. If no other constraints are expressed than on the content of the graph itself, i.e. if annotations on the graph are not considered, then a type akin to the RDF notion of a graph type is established. This approach to typing might be characterized as extremely late binding.



-->
