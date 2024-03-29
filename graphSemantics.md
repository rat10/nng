# Named Graph Semantics

<!-- 
sound graph naming semantics are provided by
  - the transclusion relation 
  - the fragment identifiers
  because they all have as domain a graph source
  this is a semantics fixing per usage
    that doesn't interfere with any other usage


add a distinction between 
    - classes + properties that we need and
    - what is added here only for "completeness" 
        (to cover everything the RDF 1.1 Dataset note mentions)

add
    Assertion 
        so NestedGraph is the superclass of 
            Assertion
            Report
            Record
            Quote
    maybe move it to citationSemantics.md
    maybe add ´"asserts"

-->


Nested Named Graphs are designed as an extension to RDF 1.1 named graphs. However this approach comes with two caveats: named graphs as specified in RDF 1.1 have no standard semantics, and their syntax doesn't support nesting. The latter problem is easy to dispel via a mapping - [transclusion](transclusion.md) and some [syntactic sugar](serialization.md) -, the former however it seems is an issue with many facets and not possible to resolve in a general way.

 The RDF 1.1 Working Group did spend a lot of effort on trying to standardize a semantics of named graphs in RDF but ultimately failed, as it proved impossible to get the various intuitions and implementations of the different stakeholders under one hood - see the [RDF 1.1 WG Note on Dataset Semantics](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/) for more detail. This is contaminated terrain, but we assert that the risks are manageable if we don't fall into the same trap as the RDF 1.1 WG and demand too much. To ease backwards compatibility and not step on anybody's toes, the Nested Named Graphs proposal is designed in a a way that it doesn’t *need* to touch the semantics, or rather the lack thereof, of named graphs as specified in RDF 1.1.

This proposal favors a specific semantics and provides several different ways to introduce it, but it doesn't make any assumptions about the semantics of an enclosing named graph or even the whole dataset. This leaves implementors free to continue to use named graphs in any application-specific way they desire - the status quo of named graphs in RDF remains untouched.

The vocabulary defined below allows to specify graph naming semantics via SPARQL service descriptions. In addition to that this proposal also provides ways to disambiguate graph naming semantics per property via the [transclusion mechanism](transclusion.md) and individually per reference via [identification semantics](identification.md).


## Two Ways to Define Graph Semantics

There are different ways to provide a semantics to graphs, and they can be divided in two different approaches.  

Per Graph Object:
- defining a semantics for individual named graphs or a default semantics for all named graphs in a dataset via SPARQL service descriptions
- encoding graph names that follow a certain semantics with a .well-known URI scheme.

Per Graph Usage:
- defining a graph naming semantics for the domain and/or range of properties
- annotating a statement that refers to a graph to clarify with which semantics the reference is used

The first approach - per graph - can be targeted on specific graphs, but that might be cumbersome in practice.

As the RDF 1.1 WG hinted at in the above mentioned note, it is possible to describe the semantics employed in the use of named graphs as a default semantics of all named graphs contained in some dataset or on a per case basis, e.g. per individual named graph. Our proposal provides such a vocabulary to describe the semantics of named graphs. One way these semantics can be described is as being exactly the same as that of nested graphs, aligning the two mechanisms as to make them virtually indistinguishable.

In that respect this proposal does indeed hope to change the status quo of named graphs in RDF: it claims to prove that a better world, in which RDF 1.1 named graphs have configurable semantics, is not only possible, but even quite practical. Standardizing *one* semantics for named graphs might have been an illusionary goal all along, given the many variants of graph semantics in the wild. However, standardizing a way to express such semantics is most probably *good enough* in any scenarios.

The second approach - per usage - has no effect on the graph itself - it doesn't make any general assertion - but defines how the graph name is used in a given statement. This is a very targeted approach if the usage maps to only very specific properties, like nesting and fragment identifiers in NNG, and it is also very effective as those properties needed to be defined only once. 

Both approaches don't exclude each other. The second one is implemented in the NNG vocabulary and hopefully is sufficient in practice. For the first approach a vocabulary is provided as well, so every use case should be covered.


## Nested Graph Semantics

The basic semantics of nested graphs represents what we interpret to be the minimal standard semantics of SPARQL (and in extension of RDF 1.1) anyway:

- a graph name identifies a graph, i.e. graph identity is determined by the name, not by the contents of the graph,
- a graph name has no meaning in itself and overloading the graph name with other meaning in addition to its use as an address to retrieve the graph is an out-of-band arrangement (and violates a foundational principle of web architecture: that an IRI should refer to one and only one resource), and
- a named graph is not an abstract type, but just a source of RDF data. In particular it is a mutable resource.

By making these fixing arrangements explicit and in addition providing vocabulary for alternative arrangements we hope to foster sounder semantics and enhanced compatibility among applications of named graphs at a wider scale.
If e.g. an application chooses to overload the graph name with more meaning, that meaning may be made explicit using the vocabulary provided in the next section. 



## Graph Semantics Vocabulary

The following vocabulary provides ways to describe the semantics of graphs. We hope that it not only provides the necessary means to integrate Nested Named Graphs into RDF 1.1 datasets, but also helps to advance sound semantics for RDF 1.1 named graphs themselves.

We first define vocabularies to describe *identity*, *naming* and *mutability* of graphs. Then we finally define some *graph types*, namely named and nested graphs, using these vocabularies.

Note that a vocabulary to tackle the related issue of quotation versus interpretation semantics is defined in the section on [Citation Semantics](citationSemantics.md).   
Another related vocabulary to resolve ambiguity in identification is discussed in the section on [Identification Semantics](identification.md). The issue of ambiguous identification does not only concern named graphs, but any IRI in RDF, i.e. the question if an IRI is meant to refer to a network retrievable resource itself or to something that that resource is about.


### Graph Identity

```turtle
# VOCABULARY

nng:identifiedBy a rdf:Property ;
    rdfs:comment "Establishes what defines the identity of a graph." .

nng:Identifier a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by the IRI under which it can be retrieved, i.e. two graphs with identical content but different names are different graphs. Two graphs with the same name must either be merged, named apart or removed." .

nng:Content a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by its content, i.e. two graphs with the same content but different names can be entailed to be equal (vulgo to be owl:sameAs)." .
```


### Graph Naming

```turtle
# VOCABULARY

nng:naming a rdf:Property ;
    rdfs:comment "Establishes the naming semantics." .

nng:Address a rdfs:Class ;
    rdfs:comment "The graph name carries no meaning on its own but serves merely to address the graph as a network retrievable resource." .

nng:Overloaded a rdfs:Class ;
    rdfs:comment "The graph name carries meaning on its own, i.e. it denotes something else than the graph itself, in addition to serving as an `nng:Address`." .

nng:overloading a rdf:Property ;
    rdfs:comment "Describes the kind of meaning that the overloaded graph name conveys. A non-exclusive list of possible values is `nng:DateOfIngestion`, `nng:DateOfCreation`, `nng:DateOfLastUpdate`, `nng:Source`, `nng:Provenance`, `nng:AccessControl`, `nng:Version`, `nng:TopicOfGraph`, `nng:LocationDescribed`, `nng:TimeDescribed`" .
```


### Graph Mutability

```turtle
# VOCABULARY

nng:mutability a rdf:Property ;
    rdfs:comment "Establishes if the graph is considered to represent an immutable abstract graph type or a mutable source of RDF data." .

nng:GraphSource a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;
    rdfs:comment "An RDF graph source, defined as a "persistent yet mutable" source of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#change-over-time)." .

nng:GraphType a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;
    rdfs:comment "An immutable graph, its type defined by its content." .
```

### Graph Definitions

To flesh out the descriptions of the graph types we need one last thing:
```turtle
# VOCABULARY

nng:Undefined a rdfs:Class ;
    rdfs:comment "An utility class to describe that this property has no value for this class." .
```

### Graph Types

Now, finally, we are able to describe the desired graph types:

```turtle
# VOCABULARY

@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .

nng:Graph a rdfs:Class ;
    owl:sameAs sd:Graph ;
    rdfs:comment "An RDF graph, defined as a set of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-graph)." .

nng:NamedGraph a rdfs:Class ;
    owl:sameAs sd:NamedGraph ;
    rdf:type nng:Graph ;
    nng:identifiedBy nng:Undefined ;
    nng:naming nng:Undefined ;
    nng:mutability nng:Undefined ;
    rdfs:comment "A named graph as specified in [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-named-graph)." .

nng:NestedGraph a rdfs:Class ;
    rdfs:subClassOf nng:NamedGraph ;
    rdf:type nng:Graph ;
    nng:identifiedBy nng:Identifier ;
    nng:naming nng:Address ;
    nng:mutability nng:GraphSource ;
    rdfs:comment "A nested named graph, as defined in this proposal." .

nng:IdentGraph a rdfs:Class ;
    rdf:type nng:Graph ;
    nng:identifiedBy nng:Content ;
    nng:naming nng:Address ;
    nng:mutability nng:GraphType ;
    rdfs:comment "A graph understood as an abstract type, identified by its content, irrespective of any features like name, annotations, etc. This definition is supposed to support reasoning over graphs." .
```



## Graph Naming Example

The [RDF 1.1 WG Note](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/#declaring) suggests to use the [SPARQL 1.1 Service Description](http://www.w3.org/TR/sparql11-service-description/) vocabulary to describe graph semantics, giving the following example:
```turtle
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF;
    sd:namedGraph [
        sd:name "http://example.com/ng1";
        sd:entailmentRegime er:RDFS
    ] .
```

In the following we use the `nng:` vocabulary to extend this example towards a mixed environment of named and nested graphs:
```turtle
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        nng:graphType nng:NamedGraph 
    ] ;
    sd:namedGraph [
        sd:name http://example.com/NestedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        nng:graphType nng:NestedGraph 
    ] .
```
Note that specifying a graph to be of type `nng:NamedGraph` effectively amounts to stating that we can't say anything definite about its naming semantics.


Having to explicitly specify the semantics of each graph is cumbersome. The SD vocabulary provides a property to define the default entailment regime for all named graphs in a dataset. We extend the vocabulary analogously by a property to define a default type for all graphs in a dataset:

```turtle
# VOCABULARY

nng:defaultGraphType a rdf:Property ;
    rdfs:comment "Defines the graph type for all graphs in a dataset."
```

The following example defines all named graphs to be of type `nng:NestedGraph`, but also adds an exception to that rule:
```turtle
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
	nng:defaultGraphType nng:NestedGraph ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
		nng:graphType nng:NamedGraph
    ] .
```

## Dataset Vocabulary

Last not least a reasonably complete approach to named graph semantics should provide some means to specify if a dataset is to be interpreted as the merge of all of its named (and therein nested) graphs, or if each named graph is to be interpreted separately.

One way to implement this might again be an extension to the [SPARQL 1.1 Service Description](http://www.w3.org/TR/sparql11-service-description/) vocabulary that allows to describe the intended semantics.
To that end the [NNG prototype implementation](https://observablehq.com/@datagenous/nested-named-graphs) does support keywords `ALL`, `NAMED` and `DEFAULT` in the `FROM` clause of a query.
<!-- 
> [TODO] If the prototype doesn't support them, try <urn:dydra:default>, <urn:dydra:named> and <urn:dydra:all> instead.

TODO keywords: check that the prototype actually supports these keywords

TODO keywords: can [sd:UnionDefaultGraph](https://www.w3.org/TR/sparql11-service-description/#sd-uniondefaultgraph) help?
-->