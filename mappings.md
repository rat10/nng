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

nng:nestedIn a rdfs:Property ;
    rdfs:domain nng:GraphSource ;
    rdfs:range nng:GraphSource ;
    rdfs:comment "The property `nng:nestedIn` records the named graph (nested or not) that the attributed graph is nested in." .

nng:principal a rdfs:Property ;
    rdfs:subPropertyOf rdf:type , 
                       rdf:value ;
    rdfs:comment "The property `nng:principal` records the principal value of a term, differentiating it from all other annotations that provide secondary detail." .
```

For each approach we also explore how annotations on individual nodes may be mapped.


[TODO] maybe one property `nng:in` would be sufficient to describe both `nng:containedIn` and `nng:nestedIn` relations. figuring that out will however require a bit of testing in queries


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
_:ag2 :d :e ;                  # annotating the triple
    nng:nestedIn _:ag1 . 
```


Annotating individual nodes requires the use of `rdfs:range`, `rdfs:domain` and `nng:relation` properties:
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
     rdfs:domain [ :s :t ] ;
     nng:relation [ :v :w ] ;
     rdfs:range [ :x :y ] ;
     nng:containedIn _:ag2 .
_:ag2 :d :e ;                  # annotating the triple
    nng:nestedIn _:ag1 . 
```



As N-Triples:
```N-Triples
[TODO]


``` 

<!--
been there, done that... 
an older version of fragment identification with singleton properties


### Mapping Fragment Identifiers to Standard RDF

The singleton properties based mapping introduced [above](#singleton-properties-mapping) can be extended to annotate individual terms in a statement by using `rdfs:domain`, `rdfs:range` and a newly introduced `nng:relation` to annotate subject, object and predicate of the relation. Further properties `nng:term`, `nng:triple` and `nng:graph` allow to refer to all terms or all triples in a graph, or to the graph itself explicitly.
```turtle
# VOCABULARY

nng:domain a rdf:Property ;
    rdfs:subPropertyOf rdfs:domain ;
    rdfs:label "s" ;
    rdfs:comment "Refers to all subjects in a graph, fragment identifier is `#s`" .

nng:range a rdf:Property ;
    rdfs:subPropertyOf rdfs:range ;
    rdfs:label "o" ;
    rdfs:comment "Refers to all objects in a graph, fragment identifier is `#o`" .

nng:relation a rdf:Property ;
    rdfs:label "p" ;
    rdfs:comment "Refers to all properties in a graph, fragment identifier is `#p`" .

nng:term a rdf:Property ;
    rdfs:label "term" ;
    rdfs:comment "Refers to all terms in a graph, fragment identifier is `#term`"" .

nng:triple a rdf:Property ;
    rdfs:label "t" ;
    rdfs:comment "Refers to the all statements in a graph, fragment identifier is `#t`" .

nng:graph a rdf:Property ;
    rdfs:label "g" ;
    rdfs:comment "Refers to the graph itself, fragment identifier is `#g`" .

```
> [TODO] do we also need a reference to nodes, i.e. subjects AND objects?

To give a complete example:
```
:a :b :c .
:a :b_1 :c .
:b_1 nng:principal :b ;  
     nng:containedIn _:g ;  # graph containment itself *is* an annotation
     nng:domain [       # annotating the subject
         :f :g ] ;
     nng:range [        # annotating the object
         :h :i ] ;
     nng:relation [     # annotating the property
         :k :l ] ;
     nng:triple [       # annotating the triple itself
         :o :p ] ;
     nng:graph [        # annotating the nested graph itself
         :q :r ] .
_:g :d :e .             # annotating the nested graph *or* some aspect of it
```

Applying this mapping to the introducing example produces:
```
:Alice :buys :House .
:Alice :buys_1 :House .
:buys_1 nng:principal :buys ;
        nng:domain [ 
            :age 40 ] .
```

Of course we can also apply fragment identifiers to the mapping and arrive at a considerably shorter representation:
```
:a :b :c .
:a :b_1 :c .
:b_1 nng:principal :b ;
     nng:containedIn _:g .
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
:buys_1 nng:principal :buys .
:buys_1#s :age 40 .
```



-->



## Fluent with principal value 

<!-- 

Other intuitions may be implemented as extensions of this mapping: to annotate each node separately we could replace each term in the statement by a blank node (the property in generalized RDF, or otherwise create a singleton property term) and annotate them accordingly with an `nng:principal` relation to refer to the primary topic of the term and further attributions as desired. However, it is obvious that such a mapping, while possible and actually quite faithfully representing the meaning of an annotated statement, would in practice be quite unbearable.
-->
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
_:ag2 :d :e ;                  # annotating the triple
    nng:nestedIn _:ag1 . 
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
_:ag2 :d :e ;                  # annotating the triple
    nng:nestedIn _:ag1 . 
```

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
_:ag2 :d :e ;                   # annotating the triple
    nng:nestedIn _:ag1.
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
_:ag2 :d :e ;                   # annotating the triple
    nng:nestedIn _:ag1.
```


As N-Triples:
```N-Triples
[TODO]


``` 




## Discussion

In general we think that implementation details like triple count shouldn't be given too much importance. We instead put more focus on usability and naturally capturing the intuitions of users. Another criterion not to be overlooked is natural support for entailments that we are accustomed to in standard RDFS and OWL. The singleton properties based approach seems to provide a good balance between ease of use, compactness and expressivity and would provide a reasonable way to represent nested graphs when no quad store is available. However, if the goal of the mapping is to ground nested graphs in the RDF semantics and provide maximal expressivity, then the fluents based approach clearly wins. It is however also the most verbose approach and w.r.t. usability might be characterized as a kind of 'expert' mode. The n-ary relation based approach has its virtues if expressive needs are modest, e.g. if only provenance annotations are to be supported, and it keeps the basic relation mostly intact - it also doesn't mess with the property, which probably is familiar to the user because it stems from a shared vocabulary. 

We would argue that a fluents based approach should be considered the baseline mapping, whereas singleton property- and n-ary relation based approaches provide different kinds of optimizations.

### Caveat

No approach to a mapping from nested graphs to regular triples in RDF can bridge a fundamental gap: regular RDF can only express types of statement. In a mapping the basic, unannotated fact - no matter how it is derived - will always loose the connection to its annotated variant. This is true for approaches like RDF standard reification and RDF-star as well.
It is not impossible for applications to keep track of annotated and un-annotated triples of the same type, e.g. to implement sound update and delete operations on annotated statements, but any mechanism to that effect will be rather expensive to implement, involved to run and as a result brittle in practice. A mapping to simple RDF triple types necessarily has its limitations and is no replacement for a mechanism like nested graphs.


> Note: One may ask why containment relations need to be mapped if the containing graph is neither explicitly named nor annotated. More generally however membership in a graph is considered an act of composing statements into groups and as such an important enough knowledge representation activity on its own as to be faithfully recorded.




<!-- 

# PRIOR WORK

#### Annotating Singleton and Multiple Triple Graphs 


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
:b_1 nng:principal :b ;
     nng:containedIn _:ag2 .
:u :v :w  .
:u :v_1 :w  .
:v_1 nng:principal :v ;
     nng:containedIn _:ag2 .
_:ag2 :d :e ;                 # annotating the graph
      nng:nestedIn _:ag1 . 
```

To help usability we might have to decide which one of those mappings is the default one. 
Because our proposal favours graphs, not singleton statements, we should probably go with the second alternative. The mapping to named graphs suggests so too. Fragment identifiers still provide a way to address individual triples. 

However, a user that created a singleton nested graph might expect that undertaking such effort for annotating a single triple should provide a clear enough indication that the intent is to annotate indeed the triple itself, not the graph. This is a problem that either needs to be very well communicated or to be handled by an extra arrangement that lets annotations on singleton graphs *automagically* refer to the triple instead of the graph, i.e. branch default denotation semantics from graph to triple for singleton graphs.

> [TODO] 
>
>This problem needs some more discussion. Although it can be resolved by means of fragment identifiers, a pragmatic and intuitive default semantics has to be found.


-->

