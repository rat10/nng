# Nesting Graphs via Transclusion

<!-- TODO what does it MEAN to transclude -->

Transclusion is the mechanism driving graph nesting. It imports the statements from a graph into the including graph. In that way it is very similar to `owl:imports`.

Transclusion is transitive: if the transcluded graph contains further transclusion directives, those are executed (i.e. transcluded) as well. A `TriG` example without extra syntactic support illustrates its application:

```turtle
:NG_2 nng:transcludes :NG_1 .
:NG_1 { :a :b :c }
:NG_2 { :d :e :f }
```

The location of the transclusion statement *does* matter. In the preceding example the transclusion directive is not visible, and therefore not executed, when inspecting :NG_2 in isolation.  
In the following example :NG_2 always transcludes :NG_1:

```turtle

:NG_1 { :a :b :c }
:NG_2 { 
    :d :e :f . 
    :NG_2 nng:transcludes :NG_1 . 
}
```


## Syntactic Sugar

Explicitly stating a transclusion via an `nng:transcludes` relation is not necessary when the [NNG syntax](serialization.md) is used, like in the following example:

```turtle
:NG_2 { 
    :d :e :f . 
    :NG_1 { :a :b :c }
}
```


## Inheritance of Annotations

Transclusion doesn't mean that annotations are inherited, neither on terms, triples or graphs. The one exception is the `nng:tree` [fragment identifier](fragments.md): annotations using `nng:tree` annotate the graph and all transcluded graphs.

## Circular Transclusion

Transclusion relations are not allowed to create circular references. That can't happen in the NNG syntax, but when using explicit nesting statements.


## Transclusion vs Inclusion vs owl:imports

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


## Vocabulary

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


