# Nesting Graphs via Transclusion


Transclusion is the mechanism driving graph nesting. It imports a graph into another graph. Transclusion is transitive: if the transcluded graph contains further transclusion directives, those are executed (i.e. transcluded) as well. A `TriG` example without extra syntactic support illustrates its application:

```turtle
:NG_2 nng:transcludes :NG_1 .
:NG_1 { :a :b :c }
:NG_2 { :d :e :f }
```

The location of the transclusion statement does matter. In the preceding example the transclusion directive is not visible, and therefore not executed, when inspecting :NG_2 in isolation.  
<!-- 
[TODO] discuss this with james
-->
In the following example :NG_2 always includes :NG_1:

```turtle

:NG_1 { :a :b :c }
:NG_2 { 
    :d :e :f . 
    :NG_2 nng:transcludes :NG_1 . 
}
```


### Syntactic Sugar

Explicitly stating a transclusion via an `nng:transcludes` relation is not necessary when the [NNG syntax](serialization.md) is used, like in the following example:

```turtle
:NG_2 { 
    :d :e :f . 
    :NG_1 { :a :b :c }
}
```


## Inheritance of Annotations

Annotations are inherited if they target the whole graph. 
That is the case if they use:

- either no [fragment identifier](fragments.md) at all
- or the `nng:graph` fragment identifier.

Annotations on individual nodes - subject, predicate, object or triples - in a nested graph are not inherited by graphs nested as such nodes.


### Transclusion vs Inclusion vs owl:imports

The differences to the [inclusion](graphLiterals.md) mechanism is that 
- inclusion is defined on graph literals, whereas transclusion is defined on graph sources, and
- inclusion is not transitive, but transclusion is.

There is little, if any, difference to `owl:imports`, but it seems prudent to define a new property for a task so central to this proposal.

<!--
https://www.w3.org/TR/2012/REC-owl2-primer-20121211/#Ontology_Management

It is also common in OWL to reuse general information that is stored in one ontology in other ontologies. Instead of requiring the copying of this information, OWL allows the import of the contents of entire ontologies in other ontologies, using import statements, as follows:

Turtle Syntax
<http://example.com/owl/families> owl:imports
	<http://example.org/otherOntologies/families.owl> .
-->


### Vocabulary

The `nng:transcludes` property is defined as:
```turtle
# VOCABULARY

nng:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:NamedGraph ;
    rdfs:range nng:NestedGraph ;
    rdfs:comment "Includes a graph source into another graph source. Transclusion is transitive: if the transcluded source contains further transclusion directives, those are executed as well." .
```
Note that the nesting graph is of type `nng:NamedGraph`, meaning that its semantics are not specified. This is meant to ensure backwards compatibility with RDF 1.1 named graphs.


