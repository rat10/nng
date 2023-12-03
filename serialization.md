# NNG - a Serialization for Nested Named Graphs based on TriG

The serialization of Nested Named Graphs, NNG, is defined as an extension of [TriG](https://www.w3.org/TR/trig/). Its datatype is `application/nng`. It provides the following functionality on top of TriG:
- it supports the nesting of named graphs
- it adds three kinds of graph literals to support common variants of citation
- it provides a slot to support configurable semantics
- it offers a self-reference operator named `THIS` to easy the work with nested graphs
While graph literals are a proposed new datatype, everything else is just syntactic sugar and can be expressed in standard TriG via a few more triples.


## Nesting Named Graph

A nested named graph 
```turtle
:Y { 
   :X { :a :b :c } 
        :d :e 
}
```
maps to standard RDF 1.1 named graphs by applying the `nng:transcludes` property - e.g. in TriG:
```turtle
:X { :a :b :c  }
:Y { :Y nng:transcludes :X .
     :X :d :e .
}
```
See [Nesting Graphs via Transclusion](transclusion.md) for more detail about the underlying mechanism.

Nested graphs are named like standard RDF 1.1 named graphs, either explicitly or by a blank node. The square brackets syntax doesn't support full property lists, but a succinct subset. It can encode either a semantics annotation to specify a semantics, like e.g.
```turtle
[nng:APP] { :s :p :o }
```
or it can encode a name and a semantics:
```turtle
[ :X nng:APP] { :x :y :z }
```
Mapped to standard TriG this would be expressed as

```turtle
<> nng:transcludes _:nng1 ,
                   :X .
_:nng1 nng:semantics nng:APP .
:X nng:semantics nng:APP .
_:nng1 { :s :p :o }
:X     { :x :y :z }
```
Note that specifying a semantics on a regular named graph is not advisable without support by out-of-band arrangements. Only graph literals, discussed below, support this mechanism with the necessary predictability with RDF proper.


A nested named graph may be nested without any further annotations, with annotations directly attached or with annotations as extra statements, e.g.:
```turtle
:Y { 
   :X { :a :b :c } 
        :d :e .
   :Z { :u :v :w }
   :X :p :q .
}
```
Mapped to TriG:
```turtle
:X { :a :b :c }
:Y { 
   :Y nng:transcludes :X , 
                      :Z .
   :X :d :e ;
      :p :q .
}
:Z { :u :v :w }
```



## Citation

NNG provides an [RDF graph literal](graphLiterals.md) datatype and supports three kinds of citations with specific variants of syntactic sugar. The bare datatype is encoded as a literal with datatype declaration, e.g. 
```turtle
":a :b :c"^^nng:GraphLiteral
```
Three different kinds of [citation semantics](citationSemantics.md) are supported: records, reports and quotes. Prepending a name to a graph literal allows to omit the datatype declaration and makes the graph literal a quote (differentiating the two is necessary to support other semantics discussed in the next section). Adding curly braces inside or outside the quote signs modifies the semantics of the quote as described in the section linked above.
```turtle
[] ":a :b :c"     # Quote
[] {":a :b :c"}   # Record
[] "{:a :b :c}"   # Report
```
This notation is syntactic sugar for the following expanded form which is valid in NNG as well as in Trig:
```turtle
[ nng:quotes ":a :b :c"^^nng:GraphLiteral ]
[ nng:records ":a :b :c"^^nng:GraphLiteral ]
[ nng:reports ":a :b :c"^^nng:GraphLiteral ]
```



## Configurable Semantics Graph Literals

The different forms of quotation could as well be encoded, for anonymous graph, as follows:
```turtle
[nng:Quote] ":a :b :c"   
[nng:Record] ":a :b :c"
[nng:Report] ":a :b :c"
```
or, for named graphs: 
```turtle
[:X nng:Quote] ":a :b :c"   
[:X nng:Record] ":a :b :c"
[:X nng:Report] ":a :b :c"
```
From this follows a more general form, that allows to specify and apply any kind of semantics one may find useful:
```turtle
[ex:MySemantics] ":s :p :o"
```
The section on [Configurable Semantics](configSemantics.md) sketches some use cases and an example vocabulary to that effect. [Notation3](https://w3c.github.io/N3/spec/) provides an arguably more mature approach that should be easy to match to this mechanism.



## THIS

NNG introduces a new `THIS` operator to allow a named graph to reference itself.
```turtle
# VOCABULARY

THIS a rdfs:Resource ;
    rdfs:comment "A self-reference from inside a (nested) graph to itself" .
```
This provides a bit of convenience when transcluding graphs, especially when they are named by blank nodes:
```turtle
:G { :a :b :c  }
[] { THIS nng:transcludes :G .
     :G :d :e  }
```
It may also be used to include annotations on a nested graph in the nested graph itself, e.g.:
```turtle
[]{ 
   :s :p :o .
   THIS :source :X .
}
```
However, some care is needed when using THIS together with fragment identifiers. In the following example the annotation per definition applies to the subjects of each statement in the graph, i.e. also to THIS, leading to a rather nonsensical annotation:

```turtle
[]{ 
   :Alice :buys :Car .
   THIS nng:domain [ :age 20 ] .
}
```
