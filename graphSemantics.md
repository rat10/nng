```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        
unedited copy from the first long proposal

```

# Named Graphs Semantics

RDF 1.1 named graphs would seem like the most natural candidate to map nested graphs to. However this approach comes with two caveats: named graphs as specified in RDF 1.1 have no standard semantics, and their syntax doesn't support nesting. The latter problem is easy to dispel via a mapping, the former however it seems is an issue with many facets and not possible to resolve in a general way.

 The RDF 1.1 Working Group did spend a lot of effort on trying to standardize a semantics of named graphs in RDF but ultimately failed, as it proved impossible to get the various intuitions and implementations of the different stakeholders under one hood - see the [RDF 1.1 WG Note on Dataset Semantics](https://www.w3.org/TR/2014/NOTE-rdf11-datasets-20140225/) for more detail. This is a terrain that it seems nobody wants to enter again. To ease backwards compatibility and not step on anybody's toes, this proposal is designed in a a way that it doesn’t *need* to touch the semantics, or rather the lack thereof, of named graphs as specified in RDF 1.1.

Consequently this proposal defines Nested Graphs *inside of* named graphs, with a specific semantics at that, but without making any assumptions about the semantics of an enclosing named graph and even the whole dataset. This leaves implementors free to continue to use and overload named graphs in any non-standard, application-specific way they desire - the status quo of named graphs in RDF remains untouched.

However, as the RDF 1.1 WG hinted at in the above mentioned note, it is very well possible to describe the semantics employed in the use of named graphs as a default semantics of all named graphs contained in some dataset or even on a per case basis, e.g. per individual named graph. Our proposal adds vocabulary to describe the semantics of named graphs. One way these semantics can be described is as being exactly the same as that of nested graphs, aligning the two mechanisms as to make them virtually indistinguishable.
In that respect this proposal does indeed hope to change the status quo of named graphs in RDF: it claims to prove that a better world, in which RDF 1.1 named graphs have configurable semantics, is not only possible, but even quite practical. Standardizing *one* semantics for named graphs might have been useful, but that chance has passed. Standardizing a way to express the chosen semantics and agreeing on what those choices mean is *good enough* in most scenarios.


The nested graph construct
```
[]{ []{ :a :b :c } :d :e }
```
as standard RDF 1.1 named graphs maps to
```
_:x {  :a :b :c  }
_:y { _:x a nng:NestedGraph ;
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
_:x nng:nestedIn _:y .
```
This mapping assumes a uniform dataspace in which all named graphs can interact with each other. A more  fragmented intuition, that understands each named graph as its own "data island" could employ the `owl:imports` property to include nested graphs. 
To that end we introduce a new `THIS` operator to allow a named graph to reference itself, mimicking the `<>` operator in SPARQL that addresses the enclosing dataset. 
```turtle
# DEFINITION

THIS a rdfs:Resource ;
    rdfs:comment "A self-reference from inside a named or nested graph to itself" .
```
This results in the following mapping:
```
_:x { :a :b :c  }
_:z { THIS owl:imports _:x .
      _:x :d :e  }
```
From a semantics perspective the resulting graph `_:z` represents the nested graph a bit more faithfully than the two separate graphs in the simpler mapping above. If this increase in fidelity is indeed worth the effort is an open question.

To clarify: `THIS owl:imports _:x .` imports `_:x` into a graph, but doesn't give it a name. In the section on [Literals](#graph-literals) below we will see other ways to import/include statements into a graph.

> [NOTE] 
>
> Membership in a nested graph is understood here to be an annotation in itself. However, that means that in this paradigm there are no un-annotated types anymore (the RDF spec doesn't discuss graph sources in much detail and only gives an informal description; however, this seems to be a necessary consequence of the concept). Types are instead established on demand, through queries and other means of selection and focus, and their type depends on the constraints expressed in such operations. If no other constraints are expressed than on the content of the graph itself, i.e. annotations on the graph are not considered, then a type akin to the RDF notion of a graph type is established. This approach to typing might be characterized as extremely late binding.



## Vocabulary

To make this mapping semantically more tight, we also introduce a vocabulary to provide RDF 1.1 named graphs with a semantics comparable to that of nested graphs. We hope to thus minimize room for misunderstanding and also to advance the introduction of sound semantics for named graphs.
The basic semantics of nested graphs represents what we interpret to be the minimal standard semantics of SPARQL (and in extension RDF 1.1) anyway:

- a graph name identifies a graph, i.e. graph identity is determined by the name, not by the contents of the graph,
- a graph name has no meaning in itself and overloading the graph name with other meaning in addition to its use as an address to retrieve the graph is an out-of-band arrangement (and violates a foundational principle of web architecture: that an IRI should refer to one and only one resource), and
- a named graph is not an abstract type, it is not guaranteed to be immutable but just a source of RDF data.


By making these fixing arrangements explicit and in addition providing vocabulary for alternative arrangements we hope to foster sounder semantics and enhanced compatibility among applications of named graph at a wider scale.
If e.g. an application chooses to overload the graph name with more meaning, that meaning should be made explicit by using the vocabulary provided in the next section. 

Also, the issue of ambiguous identification is not only confined to named graphs, but actually befalls any IRI in RDF, i.e. the question if an IRI is meant to address a web resource itself or refer to something that the resource is about. We will discuss this, and a possible approach to its resolve, in a section on [Disambiguating Identification Semantics](#disambiguating-identification-semantics) below.

More vocabulary on related issues like quotation versus interpretation semantics will be defined in the section on [Configurable Semantics](#configurable-semantics) below.


### Graph Types

```turtle
# DEFINITION

@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .

nng:Graph a rdfs:Class ;
    owl:sameAs sd:Graph ;
    rdfs:comment "An RDF graph, defined as a set of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-graph)." .

nng:NestedGraph a rdfs:Class ;
    rdfs:comment "A nested graph, as defined in this proposal." .

nng:NamedGraph a rdfs:Class ;
    owl:sameAs sd:NamedGraph ;
    rdfs:comment "A named graph as specified in [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-named-graph)." .

nng:IdentGraph a rdfs:Class ;
    rdfs:comment "A graph understood as an abstract type, identified by its content, irrespective of any features like name, annotations, etc. This definition is supposed to support reasoning over graphs." .
```


### Graph Identity

```turtle
# DEFINITION

nng:identifiedBy a rdf:Property ;
    rdfs:comment "Establishes what defines the identity of a graph." .

nng:Identifier a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by the IRI under which it can be retrieved, i.e. two graphs with identical content but different names are different graphs. Two graphs with the same name must either be merged, named apart or removed." .

nng:Content a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by its content, i.e. two graphs with the same content but different names can be entailed to be equal (vulgo to be owl:sameAs)." .
```


### Graph Naming

```turtle
# DEFINITION

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
# DEFINITION

nng:mutability a rdf:Property ;
    rdfs:comment "Establishes if the graph is considered to represent an immutable abstract graph type or a mutable source of RDF data." .

nng:GraphSource a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;
    rdfs:comment "An RDF graph source, defined as a "persistent yet mutable" source of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#change-over-time)." .

nng:GraphType a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;       # TODO or rather owl:equivalentClass ?
    rdfs:comment "An immutable graph, its type defined by its content." .
```


### Graph Definitions

To flesh out the descriptions of the graph types defined above we need one last thing:
```turtle
# DEFINITION

nng:Undefined a rdfs:Class ;
    rdfs:comment "An utility class to describe that this property has no value for this class." .
```

Putting the vocabulary just established to good use: 
```
nng:NestedGraph 
    a nng:Graph ;
    nng:identifiedBy nng:Identifier ;
    nng:naming nng:Address ;
    nng:mutability nng:GraphSource .
```

```
sd:NamedGraph 
    a nng:Graph ;
    nng:identifiedBy nng:Undefined ;
    nng:naming nng:Undefined ;
    nng:mutability nng:Undefined .
```

```
nng:IdentGraph 
    a nng:Graph ;
    nng:identifiedBy nng:Content ;
    nng:naming nng:Address ;
    nng:mutability nng:GraphType .
```

```
:MyGraph_1 
    a nng:Graph ;
    nng:identifiedBy nng:Identifier ;
    nng:naming [ rdf:value nng:Overloaded ;
	             nng:overloading nng:TopicOfGraph ] ;
    nng:mutability nng:GraphSource .
```



### Graph Naming Example

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

In the following we use the `nng:` vocabulary to extend this example towards a mixed environment of named and nested graphs:
```
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
# DEFINITION

nng:defaultGraphType a rdf:Property ;
    rdfs:comment "Defines the graph type for all graphs in a dataset."
```

The following example defines all named graphs to be of type `nng:NestedGraph`, but also adds an exception to that rule:
```
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


