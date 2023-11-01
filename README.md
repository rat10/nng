# SEG - Semantic Graphs


## Overview
SEG (Semantic Graphs) is a proposal to the RDF 1.2 Working Group (WG) [0]. It provides a simple facility to enable annotations on RDF in RDF. 

The proposal doesn't require any changes or additions to the abstract syntax of RDF [1]. It aims for implementation in quad stores that support RDF 1.1 datasets [2]. It is realized by a combination of syntactic sugar added to the popular TriG syntax [3] and a vocabulary to ensure sound semantics [4]. It is accompanied by a prototype implementation with SPARQL [5] support.


## Syntax
The main component of the proposal is [TriGGS](https://github.com/rat10/seg/blob/main/TriGGS%20serialization.md), a syntactic extension to TriG, that adds the ability to nest (named) graphs inside other named graphs. A complementary syntactic extension to JSON-LD is TBD. Mappings to N-Triples and N-Quads are provided. A mapping to RDF/XML is not planned.


## Semantics
A small vocabulary, named [SEG](https://github.com/rat10/seg/blob/main/SEG%20vocabulary.md), provides the means to solidly define the semantics of nested graphs and map the constructs from the nested syntax to plain TriG and N-Quads (and also Turtle and N-Triples if necessary).


## Use Cases
[7] TBD

## Parsing
TBD

## Querying
A thorough investigation of querying, snytax as well as result formats is still TBD


## Prototype
A prototype implementation in the Dydra graphstore [6], including an appropriate extension to SPARQL, provides a public [notebook](https://observablehq.com/@datagenous/se-graph-workbook) that can be used to explore, test and play around with the proposal.


## The story so far
The proposal was presented to the RDF 1.2 WG by means of 
- a [long text](https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72) from mid-October 23 presenting a first draft of the proposal in a bit too much detail
- a [short text](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0041.html) from mid-October 23 presenting an introduction to the proposal
- a [short presentation](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0109.html) from late-October 23 introducing the proposal by example.
  
Discussions in the WG led to slight modifications that resulted in a proposal that is completely conformant to the existing RDF 1.1 model and abstract syntax, at the expense of a bit of semantic rigidity.



## References
[0] [RDF 1.2 Working Group](https://www.w3.org/groups/wg/rdf-star/)  
[1] [RDF 1.1 Concepts and Abstract Syntax](https://www.w3.org/TR/rdf11-concepts/)  
[2] [RDF 1.1: On Semantics of RDF Datasets](https://www.w3.org/TR/2014/NOTE-rdf11-datasets/)  
[3] [TriG](https://www.w3.org/TR/2014/REC-trig/)  
[4] [RDF 1.1 Semantics](https://www.w3.org/TR/rdf11-mt/)  
[5] [SPARQL 1.1](https://www.w3.org/TR/2013/REC-sparql11-overview/)  
[6] [Dydra graphstore](https://dydra.com/home)  
[7] [Use Cases](https://github.com/w3c/rdf-ucr/wiki)  
