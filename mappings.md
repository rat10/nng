# Mappings

A mapping from Nested Named Graphs to regular RDF provides backwards compatibility to triple-based serializations and stores, albeit not with the same ease of use. 
Mapping nested graphs to standard RDF triples also serves to pin down their semantics and enable sound reasoning. We know precisely what those standard RDF triples mean, and therefore such a mapping can guide intuitions and implementations.

We present three concrete mappings of NNG to standard triples, one based on the [Singleton Properties](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4350149/) approach, one based on [Fluents](https://link.springer.com/chapter/10.1007/978-3-319-58068-5_39) and one based on how [n-ary relations](https://www.w3.org/TR/swbp-n-aryRelations/) are modelled in RDF.

All mappings need to describe:
- the containment of a statement in a graph,
- the nesting of a graph in another graph, and
- the principal value of a node representing an annotated term.

To that end we define the following properties:
```turtle
# VOCABULARY

nng:containedIn a rdfs:Property ;
    rdfs:range nng:GraphSource ;
    rdfs:comment "The property `nng:containedIn` records the named graph (nested or not) that the statement occurs in." .

nng:principal a rdfs:Property ;
    rdfs:subPropertyOf rdf:type , 
                       rdf:value ;
    rdfs:comment "The property `nng:principal` records the principal value of a term, differentiating it from all other annotations that provide secondary detail." .
```

<!--
nng:nestedIn a rdfs:Property ;
    rdfs:domain nng:GraphSource ;
    rdfs:range nng:GraphSource ;
    rdfs:comment "The property `nng:nestedIn` records the named graph (nested or not) that the attributed graph is nested in." .
-->



> [NOTE] 
>
> Following the example of `a` in Turtle we might define the shortcuts `in` and `as` to provide some syntactic sugar for `nng:containedIn` and `nng:transcludes`

For each approach we also explore how annotations on individual nodes may be mapped. To that end we need to define some more properties:
```turtle
# VOCABULARY

nng:domain a rdf:Property ;
    rdfs:subPropertyOf rdfs:domain ;
    rdfs:comment "Refers to the subject of a statement." .

nng:relation a rdf:Property ;
    rdfs:comment "Refers to the property of a statement." .

nng:range a rdf:Property ;
    rdfs:subPropertyOf rdfs:range ;
    rdfs:comment "Refers to the object of a statement." .
```



## Singleton Property

In the singleton properties oriented mapping annotations are attributed to a newly defined property.
The property `nng:principal`, which in this approach could also be defined as a subproperty of `rdfs:subPropertyOf`, points from the newly created property in the annotated statement to the original property that is getting annotated. The original property should be interpreted as the primary value of an existential represented by the singleton property, `:b_1` in the example below. In generalized RDF `:b_1` would be represented as a blank node, e.g. `_:b1`.

Using this approach, the nested graph construct
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    } :d :e 
}
```
is mapped to
```turtle
:a :b :c .
:a :b_1 :c .
:b_1 nng:principal :b ;
     nng:containedIn _:ag2 .
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```


Annotating individual nodes requires the use of `nng:domain`, `nng:relation` and `nng:range` properties:
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    }   :d :e ;
        nng:subject [ :s :t ] ;
        nng:predicate [ :v :w ] ;
        nng:object [ :x :y ] .
}
```
gets mapped to
```turtle
:a :b :c .
:a :b_1 :c .
:b_1 nng:principal :b ;
     nng:domain [ :s :t ] ;
     nng:relation [ :v :w ] ;
     nng:range [ :x :y ] ;
     nng:containedIn _:ag2 .
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```
[TODO] subject predicate object annotations need to be reified too


As N-Triples:
```N-Triples
[TODO]


```



## Fluent with principal value 

In a fluents-based approach each annotated node is replaced by a blank node which itself is annotated with the principal (to be annotated) value and those annotations.

The nested graph construct
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    } :d :e 
}
```
is like in the singleton properties approach mapped to
```turtle
:a :b :c .
:a :b_1 :c .
:b_1 nng:principal :b ;
     nng:containedIn _:ag2 .
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```

Differences become apparent when individual nodes are annotated:
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    }   :d :e ;
        nng:subject [ :s :t ] ;
        nng:predicate [ :v :w ] ;
        nng:object [ :x :y ] .
}
```
The fluents mapping doesn't require special properties: the same principle applies to any node. The predicate gates annotated with graph containment, but annotations on relation type and the whole triple are separate:
```turtle
:a :b :c .
_:a1 :b_1 _:c1 .
_:a1 nng:principal :a ;
     :s :t .
_:c1 nng:principal :c ;
     :x :y .
:b_1 nng:principal :b ;
     :v :w ;
     nng:containedIn _:ag2 .
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```
[TODO] subject predicate object annotations need to be reified too

As N-Triples:
```N-Triples
[TODO]


``` 




## N-ary Relation

A third approach is oriented on the way `rdf:value` is designed to work: it doesn't engage with the property, as the singleton properties approach does, but with the object of a statement.

Here the nested graph construct
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    } :d :e 
}
```
is mapped to
```turtle
:a :b :c .
:a :b [ nng:principal :c ;
        nng:containedIn _:ag2 ] . 
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```




This modelling style is very close to regular RDF as we know it. In principle this mapping could be supported in RDF by a follow-your-nose behaviour that automagically follows any `nng:principal` relation, returns its value instead of the blank node from which it originates, and adds all other attributes to the originating blank node as additional annotations. 
However, the intuitive semantics is a bit shaky, as an annotation on the object of a relation would by convention not be understood as referring to the whole relation, or even the enclosing graph: while application specific intuitions may interpret it as referring to the graph itself, it seems risky to make such an interpretation mandatory. This problem could again be solved by defining additional vocabulary to refer to individual nodes in the statement, as above.

Annotating individual nodes re-uses the `nng:subject` and `nng:predicate` properties:
```turtle
[_:ag1]{ 
    [_:ag2]{ 
        :a :b :c 
    }   :d :e ;
        nng:subject [ :s :t ] ;
        nng:predicate [ :v :w ] ;
        nng:object [ :x :y ] .
}
```
gets mapped to
```turtle
:a :b :c .
:a :b [ nng:principal :c ;
        nng:containedIn _:ag2 ;
        nng:subject [ :s :t ] ;
        nng:predicate [ :v :w ] 
]. 
_:ag2 :d_1 :e ;
:d_1 nng:principal :d ;
     nng:containedIn _:ag1 .
_:ag1 nng:transcludes _:ag2 . 
```
[TODO] subject predicate object annotations need to be reified too


As N-Triples:
```N-Triples
[TODO]


``` 




## Discussion

In general we think that implementation details like triple count shouldn't be given too much importance. We instead put more focus on usability in authoring and querying and naturally capturing the intuitions of users. Another criterion not to be overlooked is natural support for entailments that we are accustomed to in standard RDFS and OWL. The singleton properties based approach seems to provide a good balance between ease of use, compactness and expressivity and would provide a reasonable way to represent nested graphs when no quad store is available. However, if the goal of the mapping is to ground nested graphs in the RDF semantics and provide maximal expressivity, then the fluents based approach clearly wins. It is however also the most verbose approach and w.r.t. usability might be characterized as a kind of 'expert' mode. The n-ary relation based approach has its virtues if expressive needs are modest, e.g. if only provenance annotations are to be supported, and it keeps the basic relation mostly intact - it also doesn't mess with the property, which probably is familiar to the user because it stems from a shared vocabulary. 

We would argue that a fluents based approach should be considered the baseline mapping, whereas singleton property- and n-ary relation based approaches provide different kinds of optimizations.

### Caveat

No approach to a mapping from nested graphs to regular triples in RDF can bridge a fundamental gap: regular RDF can only express types of statement. In a mapping the basic, unannotated fact - no matter how it is derived - will always loose the connection to its annotated variant. This is true for approaches like RDF standard reification and RDF-star as well.
It is not impossible for applications to keep track of annotated and un-annotated triples of the same type, e.g. to implement sound update and delete operations on annotated statements, but any mechanism to that effect will be rather expensive to implement, involved to run and as a result brittle in practice. A mapping to simple RDF triple types necessarily has its limitations and is no replacement for a mechanism like nested graphs.


> Note: One may ask why containment relations need to be mapped if the containing graph is neither explicitly named nor annotated. More generally however membership in a graph is considered an act of composing statements into groups and as such an important enough knowledge representation activity on its own as to be faithfully recorded.
