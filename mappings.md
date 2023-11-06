# Mappings


## Triples

### Principal Value (rdf:value or rdf:type)

#### Turtle
#### N-Triples

### Singleton Property
#### Turtle
#### N-Triples

## Quads

### TriG

### N-Quads

### JSON-LD


# PRIOR WORK

## Mapping to Standard RDF

A mapping from nested graphs to regular RDF serves to pin down the informal semantics of nested graphs and provide guidance to backwards compatible implementations as well as querying and reasoning strategies.
Mapping nested graphs to standard RDF triples has the advantage that we know precisely what those standard RDF triples mean, and therefore such a mapping can guide intuitions and implementations. It also ensures backward compatibility to existing standards and implementations, albeit not with the same ease of use, of course.
Additionally a mapping to RDF 1.1 named graphs is provided, which will meet intuitions more directly, is syntactically much more straightforward and as a desirable side effect can also help to consolidate the contested state of semantics of named graphs in RDF.


### Mapping to Triples

A mapping to RDF triples is performed in two steps:

- all statements that do not themselves contain nested graphs and all statements in un-annotated nested graphs are copied verbatim to a target RDF graph,
- all statements containing nested graphs, i.e. annotated nested graphs, are mapped to n-ary relations, involving some special vocabulary.

While the first step is trivial, the second step can lead to rather convoluted n-ary relations. We first present a mapping closely aligned to regular RDF, based on a variation to the `rdf:value` property, but then also explore another approach based on the singleton properties proposal. To that end we introduce two new properties, `sg:aspectOf` and `sg:inGraph`. The property `sg:aspectOf` is defined differently, depending on the chosen mapping, and will be introduced in the respective sections below.
The property `sg:inGraph` records the nested graph that the statement occurs in. The graph identifier can be either a blank node or an IRI, faithfully reflecting the name of the nested graph.
```
DEF

sg:inGraph a rdfs:Property ;
    rdfs:comment "The property `sg:inGraph` records the nested graph that the statement occurs in." .
```

#### rdf:value-based Mapping

In this mapping the property `sg:aspectOf` is defined as a subproperty of `rdf:value`, and the modelling is oriented on the way `rdf:value` in standard RDF is designed to work: it doesn't engage with the property, as the singleton properties approach does, but with the object of a statement.
```
DEF

sg:aspectOf a rdfs:Property ;
    rdfs:subPropertyOf rdf:value ;
    rdfs:comment "The property `sg:aspectOf` is defined as a subproperty of `rdf:value`. Its `rdfs:range` is to be interpreted as the primary value of the annotated node." .
```

The nested graph construct
```
[_:ag1]{ [_:ag2]{ :a :b :c } :d :e }
```
is mapped to
```
:a :b :c .
:a :b [ sg:aspectOf :c ;
        sg:inGraph _:ag2 ;
        :d :e ] .             # annotating the triple
_:ag2 sg:inGraph _:ag1.
```
The modelling style is very close to regular RDF as we know it. In principle this mapping could without too much effort be implemented in standard RDF, if the well-known `rdf:value` property (or our more definitely defined `sg:aspectOf` property) was interpreted in a specific way, i.e. if every `rdf:value` relation would be automagically followed and returned as the default/main value to queries and follow-your-nose behaviours, and all other attributes to the originating blank node would be rendered as additional annotations on that main value. 

However, the intuitive semantics is a bit shaky, as an annotation on the object of a relation would by convention not be understood as referring to the whole relation, or even the enclosing graph: while application specific intuitions may interpret it as referring to the graph itself, it seems risky to make such an interpretation mandatory. Other intuitions may be implemented as extensions of this mapping: to annotate each node separately we could replace each term in the statement by a blank node (the property in generalized RDF, or otherwise create a singleton property term) and annotate them accordingly with an `sg:aspectOf` relation to refer to the primary topic of the term and further attributions as desired. However, it is obvious that such a mapping, while possible and actually quite faithfully representing the meaning of an annotated statement, would in practice be quite unbearable.


#### Singleton Properties-based Mapping

In the singleton properties oriented mapping annotations are attributed to a newly defined property.
The property `sg:aspectOf`, here defined as a subproperty of `rdfs:subPropertyOf`, points from the newly created property in the annotated statement to the original property that is getting annotated. The original property should be interpreted as the primary value of an existential represented by the singleton property, `:b_1` in the example below. In generalized RDF `:b_1` would be represented as a blank node, e.g. `_:b1`.
```
DEF

sg:aspectOf a rdfs:Property ;
    rdfs:subPropertyOf rdfs:subPropertyOf ;
    rdfs:comment "The property `sg:aspectOf`, defined as a subproperty of `rdfs:subPropertyOf`, describes the relation type of the statement that is getting annotated. Its `rdfs:range` is to be interpreted as the primary value of the annotated property." .
```

Using this approach, the nested graph construct
```
[_:ag1]{ [_:ag2]{ :a :b :c } :d :e }
```
is mapped to
```
:a :b :c .
:a :b_1 :c .
:b_1 sg:aspectOf :b ;
     sg:inGraph _:ag2 ;
     :d :e .                  # annotating the triple
_:ag2 sg:inGraph _:ag1 . 
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
:b_1 sg:aspectOf :b ;
     sg:inGraph _:ag2 .
:u :v :w  .
:u :v_1 :w  .
:v_1 sg:aspectOf :v ;
     sg:inGraph _:ag2 .
_:ag2 :d :e ;                 # annotating the graph
      sg:inGraph _:ag1 . 
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
_:y { _:x a sg:NestedGraph ;
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
_:x sg:inGraph _:y .
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

sg:Graph a rdfs:Class ;
    owl:sameAs sd:Graph ;
    rdfs:comment "An RDF graph, defined as a set of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-graph)." .

sg:NestedGraph a rdfs:Class ;
    rdfs:comment "A nested graph, as defined in this proposal." .

sg:NamedGraph a rdfs:Class ;
    owl:sameAs sd:NamedGraph ;
    rdfs:comment "A named graph as specified in [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-named-graph)." .

sg:IdentGraph a rdfs:Class ;
    rdfs:comment "A graph understood as an abstract type, identified by its content, irrespective of any features like name, annotations, etc. This definition is supposed to support reasoning over graphs." .
```


##### Graph Identity

```
DEF

sg:identifiedBy a rdf:Property ;
    rdfs:comment "Establishes what defines the identity of a graph." .

sg:Identifier a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by the IRI under which it can be retrieved, i.e. two graphs with identical content but different names are different graphs. Two graphs with the same name must either be merged, named apart or removed." .

sg:Content a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by its content, i.e. two graphs with the same content but different names can be entailed to be equal (vulgo to be owl:sameAs)." .
```


##### Graph Naming

```
DEF

sg:naming a rdf:Property ;
    rdfs:comment "Establishes the naming semantics." .

sg:Address a rdfs:Class ;
    rdfs:comment "The graph name carries no meaning on its own but serves merely to address the graph as a network retrievable resource." .

sg:Overloaded a rdfs:Class ;
    rdfs:comment "The graph name carries meaning on its own, i.e. it denotes something else than the graph itself, in addition to serving as an `sg:Address`." .

sg:overloading a rdf:Property ;
    rdfs:comment "Describes the kind of meaning that the overloaded graph name conveys. A non-exclusive list of possible values is `sg:DateOfIngestion`, `sg:DateOfCreation`, `sg:DateOfLastUpdate`, `sg:Source`, `sg:Provenance`, `sg:AccessControl`, `sg:Version`, `sg:TopicOfGraph`, `sg:LocationDescribed`, `sg:TimeDescribed`" .
```


##### Graph Mutability

```
DEF

sg:mutability a rdf:Property ;
    rdfs:comment "Establishes if the graph is considered to represent an immutable abstract graph type or a mutable source of RDF data." .

sg:GraphSource a rdfs:Class ;
    rdfs:comment "A mutable source of RDF data, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#dfn-rdf-source)." .

sg:GraphType a rdfs:Class ;
    rdfs:comment "An immutable graph, its type defined by its content." .
```


##### Graph Definitions

To flesh out the descriptions of the graph types defined above we need one last thing:
```
DEF

sg:Undefined a rdfs:Class ;
    rdfs:comment "An utility class to describe that this property has no value for this class." .
```

Putting the vocabulary just established to good use: 
```
sg:NestedGraph 
    a sg:Graph ;
    sg:identifiedBy sg:Identifier ;
    sg:naming sg:Address ;
    sg:mutability sg:GraphSource .
```

```
sd:NamedGraph 
    a sg:Graph ;
    sg:identifiedBy sg:Undefined ;
    sg:naming sg:Undefined ;
    sg:mutability sg:Undefined .
```

```
sg:IdentGraph 
    a sg:Graph ;
    sg:identifiedBy sg:Content ;
    sg:naming sg:Address ;
    sg:mutability sg:GraphType .
```

```
:MyGraph_1 
    a sg:Graph ;
    sg:identifiedBy sg:Identifier ;
    sg:naming [ rdf:value sg:Overloaded ;
	             sg:overloading sg:TopicOfGraph ] ;
    sg:mutability sg:GraphSource .
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

In the following we use the `sg:` vocabulary to extend this example towards a mixed environment of named and nested graphs:
```
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        sg:graphType sg:NamedGraph 
    ] ;
    sd:namedGraph [
        sd:name http://example.com/NestedGraph1 ;
        sd:entailmentRegime er:RDFS ;
        sg:graphType sg:NestedGraph 
    ] .
```
Note that specifying a graph to be of type `sg:NamedGraph` effectively amounts to stating that we can't say anything definite about its naming semantics.


Having to explicitly specify the semantics of each graph is cumbersome. The SD vocabulary provides a property to define the default entailment regime for all named graphs in a dataset. We extend the vocabulary analogously by a property to define a default type for all graphs in a dataset:

```
DEF

sg:defaultGraphType a rdf:Property ;
    rdfs:comment "Defines the graph type for all graphs in a dataset."
```

The following example defines all named graphs to be of type `sg:NestedGraph`, but also adds an exception to that rule:
```
@prefix er: <http://www.w3.org/ns/entailment> .
@prefix sd: <http://www.w3.org/ns/sparql-service-description#> .
[]  a sd:Dataset;
    sd:defaultEntailmentRegime er:RDF ;
	sg:defaultGraphType sg:NestedGraph ;
    sd:namedGraph [
        sd:name http://example.com/NamedGraph1 ;
        sd:entailmentRegime er:RDFS ;
		sg:graphType sg:NamedGraph
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

The singleton properties based mapping introduced [above](#singleton-properties-mapping) can be extended to annotate individual terms in a statement by using `rdfs:domain`, `rdfs:range` and a newly introduced `sg:relation` to annotate subject, object and predicate of the relation. Further properties `sg:term`, `sg:triple` and `sg:graph` allow to refer to all terms or all triples in a graph, or to the graph itself explicitly.
```
DEF

sg:domain a rdf:Property ;
    rdfs:subPropertyOf rdfs:domain ;
    rdfs:label "s" ;
    rdfs:comment "Refers to all subjects in a graph, fragment identifier is `#s`" .

sg:range a rdf:Property ;
    rdfs:subPropertyOf rdfs:range ;
    rdfs:label "o" ;
    rdfs:comment "Refers to all objects in a graph, fragment identifier is `#o`" .

sg:relation a rdf:Property ;
    rdfs:label "p" ;
    rdfs:comment "Refers to all properties in a graph, fragment identifier is `#p`" .

sg:term a rdf:Property ;
    rdfs:label "term" ;
    rdfs:comment "Refers to all terms in a graph, fragment identifier is `#term`"" .

sg:triple a rdf:Property ;
    rdfs:label "t" ;
    rdfs:comment "Refers to the all statements in a graph, fragment identifier is `#t`" .

sg:graph a rdf:Property ;
    rdfs:label "g" ;
    rdfs:comment "Refers to the graph itself, fragment identifier is `#g`" .

```
> [TODO] do we also need a reference to nodes, i.e. subjects AND objects?

To give a complete example:
```
:a :b :c .
:a :b_1 :c .
:b_1 sg:aspectOf :b ;  
     sg:inGraph _:g ;  # graph containment itself *is* an annotation
     sg:domain [       # annotating the subject
         :f :g ] ;
     sg:range [        # annotating the object
         :h :i ] ;
     sg:relation [     # annotating the property
         :k :l ] ;
     sg:triple [       # annotating the triple itself
         :o :p ] ;
     sg:graph [        # annotating the nested graph itself
         :q :r ] .
_:g :d :e .             # annotating the nested graph *or* some aspect of it
```

Applying this mapping to the introducing example produces:
```
:Alice :buys :House .
:Alice :buys_1 :House .
:buys_1 sg:aspectOf :buys ;
        sg:domain [ 
            :age 40 ] .
```

Of course we can also apply fragment identifiers to the mapping and arrive at a considerably shorter representation:
```
:a :b :c .
:a :b_1 :c .
:b_1 sg:aspectOf :b ;
     sg:inGraph _:g .
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
:buys_1 sg:aspectOf :buys .
:buys_1#s :age 40 .
```



