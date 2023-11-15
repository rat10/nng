# Introduction by Example

The following examples aim to provide a quick introduction into the user facing mechanics of Nested Named Graphs.


## The Basic Syntax

A nested graph, named by a blank node:
```turtle
[] {:Alice :buys :Car}
```
A nested graph with an explicitly given name:
```turtle
:X {:Alice :buys :Car}
```
Two (different) nested graphs, named by (different) blank nodes:
```turtle
[] {:Alice :buys :Car}
[] {:Alice :buys :Car}
```
Some nested nested graphs, all with different names (they are tokens, not types):
```turtle
:NG_1 {
    []{
        :Alice :buys :Car .
        []{:Alice :buys :Car}
        :Y {:Alice :buys :Car}
    }
}
```

## Every triple in every nested graph is asserted and referentially transparent

The semantics of nested named graphs is that of middle of the road RDF. This:
```turtle
:Y {:Alice :buys :Car} :says :Denis .
```
is just syntactic sugar for this:
```turtle
:Y {:Alice :buys :Car}
:Y :says :Denis .
```
  
  
Some proposals have hacked the Turtle syntax to achieve the same goal:
```turtle
:Alice :buys :Car                   # :Z
:Z :says :Denis . 
```
Others provide statement identifiers additionally to graph identifiers.


## Nesting via Transclusion
[TODO]



## A simplistic application of a nested graph
A bit like property graphs:
```turtle
[]{:Alice :buys :Car} 
    :age 20 ;                               # who is 20 years old ?
    :color :black ;                         # who is black ?
    :payment :Cash ;                        # seems clear
    :purpose :JoyRiding ;                   # ditto
    :model :Coupe ;                         # ditto
    :source :Denis .                        # ditto ... or did Denis sell the car?
```


## Targeting fragments, verbosely
```turtle
:X {:Alice :buys :Car} .
:X nng:subject [
    :age 20
]
:X nng:predicate [
    :payment :Cash ;
    :purpose :JoyRiding                     # ambivalence, could also be object property
]
:X nng:object [
    :color :black ;
    :model :Coupe
]
:X nng:triple [
    ex:void ex:void                         # forEach semantics, not needed here
]
:X nng:graph [
    :source :Denis
]
```


## A mapping to RDF a la singleton properties
```turtle
:Alice :buys_1 :Car .
:buys_1 
    rdfs:subPropertyOf :buys ;
    :payment :Cash ;
    :purpose :JoyRiding ;
    :nestedIn :X ;
    rdfs:domain [
        :age 20
    ];
    rdfs:range [
        :color :black ;
        :model :Coupe
    ];
    nng:triple [
        :source :Denis
    ]
```
Two other mappings - fluents and n-ary relations - are provided in the section on [mappings](mappings.md)


## A compact and less pedantic version
Explicit, but tedious disambiguation doesn't need to become the new religion. The target of `:payment`, `:purpose` and `:source` is in most cases clear enough to make explicit disambiguation unnecessary.

```turtle
:X {
    :Alice :buys :Car .
} 
    nng:subject [ :age 20 ] ;
    nng:object [ :color :black ;
                 :model :Coupe ] ;
    :payment :Cash ;
    :purpose :JoyRiding ;
    :source :Denis .
```






<!--
```turtle
:Y {
    :Alice :buys :House .                  # <--- !
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :payment :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe ;
             :maker :Pininfarina .         # <--- !!
    }
} :source :Denis .

# updated to

:Y {
    :W {
        :Alice :buys :House . 
        :W?s :age :40 .                    # <--- !!!
    }
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :payment :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe ;
             :maker :Pininfarina .
    } :source :Denis .
}

```
-->

<!--
## Records - literals as asserted opaque types

TODO

## Quotes - literals as un-asserted opaque types

TODO

-->
