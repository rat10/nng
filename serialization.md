# Serialization
```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

```


The serialization of Nested Named Graphs is defined as an extension to TriG. Its datatype is `application/nng`.


The [nested graph syntax](serialization.md)
```turtle
:Y { 
    :X { :a :b :c } 
         :d :e 
}
```
maps to standard RDF 1.1 named graphs 
```turtle
:X { :a :b :c  }
:Y { :Y nng:transcludes :X .
     :X :d :e .
}
```



- graph annotation
-- anonymous
   []{:a :b :c} :x :y .
   [:x :y]{:a :b :c}       # property list
-- named
   :g1 {:a :b :c} 
       :x :y .             # defining and annotating a graph in one sweep
   :f :m :n .
   :g1 :u :w .             # annotating the graph independent from its definition

[TODO] do we still support property lists?
       or do we reserve the [] syntax for either
       - blank node names
       or
       - semantics declarations, eg
         [nng:APP]{ s p o }


- graph literals
[ nng:quotes ":a :b :c"^^nng:GraphLiteral ] a :Nuisance .
:X nng:quotes ":a :b :c"^^nng:GraphLiteral a :Necessity .
THIS nng:quotes ":a :b :c"^^nng:GraphLiteral  
                          # 'THIS' referring to the local graph



#### this

We introduce a new `THIS` operator to allow a named graph to reference itself, mimicking the `<>` operator in SPARQL that addresses the enclosing dataset. 
```turtle
# VOCABULARY

THIS a rdfs:Resource ;
    rdfs:comment "A self-reference from inside a (nested) graph to itself" .
```
This (no pun intended) provides a bit of convenience when transcluding graphs, especially when they are named by blank nodes:
```turtle
:G { :a :b :c  }
[] { THIS nng:transcludes :G .
     :G :d :e  }
```



> [NOTE] 
>
> Membership in a nested graph is understood here to be an annotation in itself. However, that means that in this paradigm there are no un-annotated types anymore (the RDF spec doesn't discuss graph sources in much detail and only gives an informal description; however, this seems to be a necessary consequence of the concept). Types are instead established on demand, through queries and other means of selection and focus, and their type depends on the constraints expressed in such operations. If no other constraints are expressed than on the content of the graph itself, i.e. if annotations on the graph are not considered, then a type akin to the RDF notion of a graph type is established. This approach to typing might be characterized as extremely late binding.