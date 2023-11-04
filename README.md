# Semantic Graphs (SG)



## Overview
Semantic Graphs (SG) is a proposal to the RDF 1.2 Working Group [0]. It provides a simple facility to enable annotations on RDF in RDF. 

The proposal doesn't require any changes or additions to the abstract syntax of RDF [1]. It aims for implementation in quad stores that support RDF 1.1 datasets [2]. It is realized by a combination of syntactic sugar added to the popular TriG syntax [3] and a vocabulary to ensure sound semantics [4]. It is accompanied by a prototype implementation with SPARQL [5] support.



## Design Considerations
Metamodelling in RDF - annotating, contextualizing, reifying simple statements to better deal with complex knowledge representation needs - has been the focus of work as long as RDF itself exists. For an extensive treatment of the topic check the 300+ pages "Between Facts and Knowledge - Issues of Representation on the Semantic Web" [[PDF]](Between.pdf).
One thing we learned from this huge corpus of works is that that one magic trick to resolve all the problems around complex modelling tasks in RDF most probably doesn't exist: it has to be a combination of techniques. Consequently, we need to get creative and we need to break some rules:

- *simplicity first* (inversion of control): maintain the focus on the simple statement. Keep annotations within easy reach, but don't let the complexity they encode cloud the overall view. Otherwise the cost in terms of usability will eclipse the increase in expressivity.
- *there is no free lunch*: added expressivity comes at a cost. However, the often heard argument "but you can do that with n-ary relations" is missing the point, because anything can be represented as n-ary relations. The representation might just get unusably complex. Some extension to RDF's tooling will be necessary if the modelling of complex information is to become easier.
- *late binding*: knowledge representation is a world full of rabbit holes. Provide means to solve problems when they become a problem, but not earlier. Most ambiguities are harmless most of the time. Also don't try to standardize on something too specific when the needs are diverging (as the RDF 1.1 WG had to learn the hard way with named graphs). In that case just provide ways to describe and communicate the different approaches.
- *named graphs* are almost a topic of there own. The argument that they can't be used because they have no standardized semantics and different implementations use them in different ways has to be countered with the simple fact that we don't need them to all have the same semantics - it's enough if they describe their semantics in a standardized way. Some argue that graphs are a grouping device and can't be used for singleton graphs, but we disagree: proper indexing solves that problem on the technical level, and on the practical level we see not one aspect that is exclusively concerned with only single or only multiple statements. Then there's also the "but we use graphs for X, so it can't be used for Y" argument. This is only true as long as they are understood as a flat and one-dimensional structure, but that doesn't need to be the case.
- *separation of concerns*: don't try to solve all problems with only one mechanism. Many orthogonal needs concerning topics of knowledge representation, reasoning, implementation, etc have to be met. Trying to stuff everything in one device will only lead to more need for disambiguating triples, and more confusion. Instead an 80/20 approach is needed that caters for mainstream use cases first, but doesn't forget to serve outliers with proper extensions.
- *monotonicity* and qualification: the Open World design of RDF requires that no statement can call another statement false. This has long been considered as making it very risky, if not impossible, to annotate statements directly. Any indirections however will inevitably lead to subtle implications that make it very hard to pin down exactly the meaning of an annotation. We go the opposite route and claim that any annotation just adds more detail and is fair game as long as it doesn't call the annotated statement outright false - the former is indeed the whole point of describing the world in RDF, whereas the latter is still forbidden.
- *don't break user's intuitions*: this one is not new, but it can't be repeated often enough. Semantics is an elusive beast, exceptionally prone to misunderstandings and contextual shape-shifting. If a formalism doesn't manage to capture the most prevalent intuitions intuitively, it is almost guaranteed to be mis-used in practice. This has happened many times - see RDF standard reification, the Named Graph semantics by Carroll et al 2005, RDF-stars completely ignored TEP-mechanism - and it takes a lot of self-scrutiny to get right.



## Syntax
The main component of the proposal is a [syntactic extension](serialization.md) to TriG that adds the ability to nest named graphs inside each other. 

A complementary syntactic extension to JSON-LD is TBD. [Mappings](mappings.md) to triple- and quad based formats like Turtle, N-Triples and N-Quads are provided (or worked on). A mapping to RDF/XML so far isn't planned as RDF/XML doesn't even support named graphs. However it could be realized analogously to the approach taken with the Turtle mapping.

See also an example of a [BNF](trig-sg.bnf) for the SG syntax - not exactly but close to the version actually deployed in the prototype notebook (see below).



## Semantics
A small [vocabulary](vocabulary.md) provides the means to solidly define the semantics of named graphs - nested or not. 

Non-standard semantics can be implemented via an additional mechanism that transcludes graph literal according to externally specified semantics. Syntax sugar is provided for the popular use cases of like un-asserted assertions and referentially opaque quotation, but the mechanism itself is extensible as desired and an example vocabulary is provided.



## Querying
TBD
syntax
result formats
[querying](querying.md)



## Use Cases
The RDF 1.2 WG is still consolidating use cases [7]. On an abstract level the SG approach has concentrated on meeting the following demands:

- there should be no syntactic differentiation between annotating triples and graphs
- adding annotations shouldn't require changes to existing structures, neither data nor queries 
- the link between a statement and its annotation has to be as direct as possible, as otherwise subtle ambiguities may creep in and require expensive post-hoc clarifications and administration
- the wide spectrum of popular intuitions concerning annotation and contextualization should be met equally well, administrative concerns just as well as qualification of (too) simple facts and as desires to bring some structure and compositional coherence to large and unwieldy graphs
- while the semantics of RDF is based on a set-theoretic abstraction of types of statements, practical applications work with concrete tokens. This gap has to be bridged in a way that feels natural to users but doesn't break the set-based semantics foundations
- specific needs w.r.t. semantics like lexically precise quotation should be possible, but as an extra and without making normal use cases more complicated
- probably more.

The [examples](examples.md) illustrate how Semantic Graphs meet those demands. 



## Prototype
A prototype implementation in the Dydra graph store [6], including an appropriate extension to SPARQL, provides a public [notebook](https://observablehq.com/@datagenous/se-graph-workbook) that can be used to explore, test and play around with the proposal.



## Attic
The Semantic/Nested Graphs proposal was presented to the RDF 1.2 WG by means of 
- a [long text](https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72) from mid-October 23, covering a first draft of the proposal in a bit too much detail
- a [short text](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0041.html) from mid-October 23, providing a shorter introduction to the proposal
- a [short presentation](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0109.html) from late-October 23, introducing the proposal by example.
  
Discussions in the WG led to slight modifications that resulted in the proposal documented here, which is completely conformant to the existing RDF 1.1 model and abstract syntax, at the expense of a bit of semantic rigidity.



## References
[0] [RDF 1.2 Working Group](https://www.w3.org/groups/wg/rdf-star/)  
[1] [RDF 1.1 Concepts and Abstract Syntax](https://www.w3.org/TR/rdf11-concepts/)  
[2] [RDF 1.1: On Semantics of RDF Datasets](https://www.w3.org/TR/2014/NOTE-rdf11-datasets/)  
[3] [TriG](https://www.w3.org/TR/2014/REC-trig/)  
[4] [RDF 1.1 Semantics](https://www.w3.org/TR/rdf11-mt/)  
[5] [SPARQL 1.1](https://www.w3.org/TR/2013/REC-sparql11-overview/)  
[6] [Dydra graph store](https://dydra.com/home)  
[7] [Use Cases](https://github.com/w3c/rdf-ucr/wiki)  
