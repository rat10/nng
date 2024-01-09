# transclusion.md

```turtle
nng:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:NamedGraph ;
    rdfs:range nng:NestedGraph ;
    rdfs:comment "Includes a graph source into another graph source. Transclusion is transitive: if the transcluded source contains further transclusion directives, those are executed as well." .
```


# graphLiterals.md

```turtle
nng:GraphLiteral a rdfs:Class ;
    rdfs:comment "An RDF literal whose datatype is either explicitly given, e.g. NNG, Turtle, TriG or JSON-LD or which matches the enclosing RDF document,".
```

## inclusion

```turtle
nng:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:NestedGraph ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```


# citationSemantics.md

```turtle
nng:Record a rdfs:Class ;
    rdfs:comment "Interpreted, but without co-denotation - asserted token, referentially opaque" .

nng:records a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Record ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with record semantics: asserted and referentially opaque" .

nng:Report a rdfs:Class ;
    rdfs:comment "Reported speech, akin to the use of RDF standard reification in the wild - unasserted type, referentially transparent." .

nng:reports a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Report ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with report semantics: un-asserted and referentially transparent" .

nng:Quote a rdfs:Class ;
    rdfs:comment "Like verbatim quoted speech, but not endorsed - unasserted type, referentially opaque" .

nng:quotes a rdfs:Property ;
    rdfs:subPropertyOf nng:includes ;
    rdfs:domain nng:Quote ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "Includes a graph literal with quotation semantics: un-asserted and referentially opaque" .

nng:statedAs a rdf:Property ;
    rdfs:range nng:GraphLiteral ;
    rdfs:comment "The object describes the original syntactic form of a graph" .
```


# fragments.md

```turtle
nng:domain a rdf:Property;
    rdfs:subPropertyOf rdfs:domain ;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to the subject of a statement, or all subjects of all statements in a graph source" .

nng:relation a rdf:Property;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to the predicate of a statement, or all predicates of all statements in a graph source" .

nng:range a rdf:Property;
    rdfs:subPropertyOf rdfs:range ;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to the object of a statement, or all objects of all statements in a graph source" .

nng:triple a rdf:Property;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to all statements in a graph source" .

nng:graph a rdf:Property;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to a graph source" .

nng:tree a rdf:Property;
    rdfs:domain nng:NestedGraph ;
    rdfs:range rdfs:Class ;
    rdfs:comment "Refers to a graph source and all graph sources nested inside, recursively" .
```


# identification

```turtle
nng:identifiedAs a rdf:Property ;
    rdfs:label "Interpretation semantics ;
    rdfs:comment "Specifies how an identifier should be interpreted." .

nng:Interpretation a nng:SemanticsAspect ;
    rdfs:label "Interpretation" ;
    rdfs:comment "The identifier is interpreted to refer to an entity in the real world." .

nng:Artifact a nng:SemanticsAspect ;
    rdfs:label "Artifact" ;
    rdfs:comment "The identifier is used to refer to a resource retrievable over the internet, i.e. an artifact." .
```


# mapping

```turtle
nng:containedIn a rdfs:Property ;
    rdfs:range nng:NestedGraph ;
    rdfs:comment "The property `nng:containedIn` records the named graph (nested or not) that the statement occurs in." .

nng:principal a rdfs:Property ;
    rdfs:subPropertyOf rdf:type , 
                       rdf:value ;
    rdfs:comment "The property `nng:principal` records the principal value of a term, differentiating it from all other annotations that provide secondary detail." .
```


# graphSemantics

## graph identity

```turtle
nng:identifiedBy a rdf:Property ;
    rdfs:comment "Establishes what defines the identity of a graph." .

nng:Identifier a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by the IRI under which it can be retrieved, i.e. two graphs with identical content but different names are different graphs. Two graphs with the same name must either be merged, named apart or removed." .

nng:Content a rdfs:Class ;
    rdfs:comment "The identity of a graph is established by its content, i.e. two graphs with the same content but different names can be entailed to be equal (vulgo to be owl:sameAs)." .
```

## graph naming

```turtle
nng:naming a rdf:Property ;
    rdfs:comment "Establishes the naming semantics." .

nng:Address a rdfs:Class ;
    rdfs:comment "The graph name carries no meaning on its own but serves merely to address the graph as a network retrievable resource." .

nng:Overloaded a rdfs:Class ;
    rdfs:comment "The graph name carries meaning on its own, i.e. it denotes something else than the graph itself, in addition to serving as an `nng:Address`." .

nng:overloading a rdf:Property ;
    rdfs:comment "Describes the kind of meaning that the overloaded graph name conveys. A non-exclusive list of possible values is `nng:DateOfIngestion`, `nng:DateOfCreation`, `nng:DateOfLastUpdate`, `nng:Source`, `nng:Provenance`, `nng:AccessControl`, `nng:Version`, `nng:TopicOfGraph`, `nng:LocationDescribed`, `nng:TimeDescribed`" .
```


## graph mutability

```turtle
nng:mutability a rdf:Property ;
    rdfs:comment "Establishes if the graph is considered to represent an immutable abstract graph type or a mutable source of RDF data." .

nng:GraphSource a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;
    rdfs:comment "An RDF graph source, defined as a "persistent yet mutable" source of RDF triples, see [RDF 1.1](https://www.w3.org/TR/rdf11-concepts/#change-over-time)." .

nng:GraphType a rdfs:Class ;
    rdfs:subClassOf nng:Graph ;
    rdfs:comment "An immutable graph, its type defined by its content." .
```

## graph definitions

```turtle
nng:Undefined a rdfs:Class ;
    rdfs:comment "An utility class to describe that this property has no value for this class." .
```

## graph types

```turtle
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

## extension to sd vocab

```turtle
nng:defaultGraphType a rdf:Property ;
    rdfs:comment "Defines the graph type for all graphs in a dataset."
```


# configSemantics

```turtle
nng:SemanticsAspect a rdf:Class ;
    rdfs:comment "An aspect of a semantics that differs from RDF’s default." .
	
nng:UNA a nng:SemanticsAspect ;
    rdfs:label "Unique Name Assumption" ;
    rdfs:comment "Each entity is denoted by exactly one identifier." 

nng:CWA a nng:SemanticsAspect ;
    rdfs:label "Closed World Assumption" ;
    rdfs:comment "The data is complete." 

nng:HYP a nng:SemanticsAspect ;
    rdfs:label "Hypothetical, unasserted Assertion" ;
    rdfs:comment "A graph documented, but not asserted." 

nng:OPA a nng:SemanticsAspect ;
    rdfs:label "Referential Opacity" ;
    rdfs:comment "All IRIs are interpreted to refer to entities in the real world, but only in the specific syntactic form provided (i.e. no co-denotation with other identifiers referring to the same entities)." .

nng:NEG a nng:SemanticsAspect ;
    rdfs:label "Negated" ;
    rdfs:comment "A graph considered false." 
```


## profiles

```turtle
nng:SemanticsProfile  a rdf:Class ;
    rdfs:comment "A combination of semantics aspects into a coherent whole." .

nng:hasAspect a rdf:Property ;
    rdfs:comment "Describes semantics aspects of a semantics profile" .


nng:APP a nng:SemanticsProfile ;
    rdfs:label "Application Profile" ;
    rdfs:comment "A semantics profile capturing typical intuitions of in-house application development" ;
    nng:hasAspect nng:UNA , 
                  nng:CWA ,
                  nng:Address ,      # we discourage overloading of graph names
                  nng:Identifier ,
                  nng:GraphSource .

nng:CIT a nng:SemanticsProfile ;
    rdfs:label "Citation Profile" ;
    rdfs:comment "A semantics profile capturing the semantics of Named Graphs, Carroll et al 2005, with the purpose to faithfully record graph instances with syntactic precision." ;
    nng:hasAspect nng:OPA ,
                  nng:Address ,
                  nng:Identifier ,
                  nng:GraphType .

nng:LOG a nng:SemanticsProfile ;
    rdfs:label "Logic Profile" ;
    rdfs:comment "A profile to enable reasoning over nested graphs" ;
    nng:hasAspect nng:Address ,
                  nng:Content ,
                  nng:GraphType .
```


# serialization

```turtle
THIS a rdfs:Resource ;
    rdfs:comment "A self-reference from inside a (nested) graph to itself" .
```
