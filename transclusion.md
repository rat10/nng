# Nesting Graphs via Transclusion

```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        
check again when the fever is gone

```

Transclusion is the mechanism driving graph nesting. It imports a graph source into another graph source. Transclusion is transitive: if the transcluded source contains further transclusion directives, those are executed as well. A `TriG` example without extra syntactic support illustrates its application:

```turtle
:NG_2 nng:transcludes :NG_1 .
:NG_1 { :a :b :c }
:NG_2 { :d :e :f }
```

The location of the transclusion statement doesn't matter. The following snippet is equivalent to the one above:

```turtle

:NG_1 { :a :b :c }
:NG_2 { 
    :d :e :f . 
    :NG_2 nng:transcludes :NG_1 . 
}
```

Applications may choose to collect transclusion instructions in the default graph or an extra named graph for optimization purposes. 

Explicitly stating a transclusion via an `nng:transcludes` relation is not necessary when the [NNG syntax](serialization.md) is used, like in the following example:

```turtle
:NG_2 { 
    :d :e :f . 
    :NG_1 { :a :b :c }
}
```

The `nng:transcludes` property is defined as:
```turtle
# VOCABULARY

nng:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain nng:GraphSource ;
    rdfs:range nng:GraphSource ;
    rdfs:comment "Includes a graph source into another graph source. Transclusion is transitive: if the transcluded source contains further transclusion directives, those are executed as well." .
```

The differences to the [inclusion](graphLiterals.md) mechanism is that 
- inclusion is defined on graph literals, whereas transclusion is defined on graph sources, and
- inclusion is not transitive, but transclusion is.

There is little difference to `owl:imports`, but it seems prudent to define a new property for a task so central to this proposal.

