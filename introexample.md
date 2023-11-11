```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        
unfinished

```

# Introduction by Example

The following examples aim to provide a quick introduction into the user facing mechanics of Nested Named Graphs.


## The Basic Syntax

A nested graph, named by a blank node:
```turtle
[]{:Alice :buys :Car}
```
A nested graph with an explicitly given name:
```turtle
:X {:Alice :buys :Car}
```
Two (different) nested graphs, named by (different) blank nodes:
```turtle
[]{:Alice :buys :Car}
[]{:Alice :buys :Car}
```
Some nested nested graphs:
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
:Y {:Alice :buys :Car} :says :Denis
```
is just syntactic sugar for this:
```turtle
:Y {:Alice :buys :Car}
:Y :says :Denis .
```
Some proposals have done this to achieve the same goal:
```turtle
:Alice :buys :Car                   # :Z
:Z :says :Denis . 
```


## A simplistic application of a nested graph
A bit like property graphs:
```turtle
[]{:Alice :buys :Car} 
    :age 20 ;                               # who is 20 years old ?
    :color :black ;                         # who is black ?
    :paymentMethod :Cash ;                  # seems clear
    :purpose :JoyRiding ;                   # dito
    :model :Coupe ;                         # dito
    :source :Denis .                        # dito ... or did Denis sell the car
```


## Targeting fragments, verbosely
```turtle
:X {:Alice :buys :Car} .
:X seg:subject [
    :age 20
]
:X seg:predicate [
    :paymentMethod :Cash ;
    :purpose :JoyRiding                     # ambivalence, could also be object property
]
:X seg:object [
    :color :black ;
    :model :Coupe
]
:X seg:triple [
    ex:void ex:void                         # forEach, not needed here
]
:X seg:graph [
    :source :Denis
]
```


## A mapping to RDF a la singleton properties
```turtle
:Alice :buys_1 :Car .
:buys_1 
    rdfs:subPropertyOf :buys ;
    :paymentMethod :Cash ;
    :purpose :JoyRiding ;
    :nestedIn :X ;
    rdfs:domain [
        :age 20
    ];
    rdfs:range [
        :color :black ;
        :model :Coupe
    ];
    rdfx:triple [
        :source :Denis
    ]
```
Two other mappings - with rdf:value and lots of blank nodes, and with named graphs - are provided in the extra page on [mappings](mappings.md)


## A compact version of the nested graph
```turtle
:X {
    :Alice :buys :Car .
    :X?s :age 20 .
    :X?p :paymentMethod :Cash ;
         :purpose :JoyRiding  .
    :X?o :color :black ;
         :model :Coupe .
#   :X?g :source :Denis
} :source :Denis .                          # doesn't provide an explicit ?g fragment identifier
```


## The same as RDF-star 
```turtle
:Alice_1 :buys_1 :Car_1 .
:Alice_1 rdf:type :Alice ;
    :age 20 .
<< :Alice_1 :buys :Car_1 >> :source Denis .
<< :Alice_1 rdf:type :Alice >> :source Denis .
<< :Alice_1 :age 20 >> :source Denis .
:buys_1 rdfs:subPropertyOf :buys ;
    :paymentMethod :Cash ;
    :purpose :JoyRiding .
<< :buys_1 rdfs:subPropertyOf :buys  >> :source Denis .
<< :buys_1 :paymentMethod :Cash >> :source Denis .
<< :buys_1 :purpose :JoyRiding  >> :source Denis .
:Car_1 rdf:type :Car ;
    :color :Black ;
    :model :Coupe .
<< :Car_1 rdf:type :Car >> :source Denis .
<< :Car_1 :color :Black >> :source Denis .
<< :Car_1 :model :Coupe >> :source Denis .
```
Imagine what happens with a second level of nesting or even the TEP mechanism.


## Embedded in Named Graphs as we know them
```turtle
:NG_1 :source :Laptop ;                     # application specific graph annotations
      :status :Unredacted ;
      :visibility :Private .

:NG_1 {
    :Z {
        :Y {
            :X {
                :Alice :buys :Car .
                :X?s :age 20 .
                :X?p :paymentMethod :Cash ;
                     :purpose :JoyRiding  .
                :X?o :color :black ;
                     :model :Coupe .
            } :source :Denis . 
        }
    } :FirstCarEvent ;
      :source :GreenDiary ;                 # imagine 2nd level nesting with RDF-star =:-|
      :date :10_12_08 .
}
```
Imagine adding more levels of nesting for different accounts of Alice buying her first car,
eg her parents helping fund it,
the insurance company having yet a different view, etc. Nothing breaks, it's just more layers of nesting getting added.


## A second AliceBuysCar triple
```turtle
:Y {
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :paymentMethod :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe .
    } :source :Denis .
    :W {
        :V {
            :Alice :buys :Car .
            :V?s :age 28 .
        } :source :Eve .
    } :todo :AddDetail .                    # add detail
}                                           # then remove this level of nesting
                                            # without changing the data topology
```


## Literals as un-asserted opaque types
```turtle
:Y {
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :paymentMethod :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe .
    } :source :Denis ;
      :asLiteral " :X {:Alice :buys :Car
                  :X?s :age 20 .
                  :X?p :paymentMethod :Cash ;
                  :purpose :JoyRiding  .
                  :X?o :color :black ;
                  :model :Coupe ."^^rdfx:graph .
      }
}
```
## Literals as un-asserted transparent types
(what RDF standard reification is popularly misused to represent)
```turtle
:Bob :says {" :Moon :madeOf :Cheese . "}
# { ... } indicate transparency
# " ... " indicate un-assertedness
```

```turtle
:Bob :says [ seg:transcludesCitation ":Moon :madeOf :Cheese"^^rdfx:graph ]

```

## Resilience to updates

```turtle
:Y {
    :Alice :buys :House .                   # <--- !
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :paymentMethod :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe ;
             :maker :Pininfarina .           # <--- !!
    }
} :source :Denis .

# --->

:Y {
    :W {
        :Alice :buys :House . 
        :W?s :age :40 .                     # <--- !!!
    }
    :X {
        :Alice :buys :Car .
        :X?s :age 20 .
        :X?p :paymentMethod :Cash ;
             :purpose :JoyRiding  .
        :X?o :color :black ;
             :model :Coupe ;
             :maker :Pininfarina .
    } :source :Denis .
}

```


## DnS shortcut relations

```turtle
:T {
    :Alice :travelsTo :ISWC23 .
    :T?p rdfs:seeAlso :U , :P.
}
:U {
    :Schedule :startsAt :Hamburg ;
                    :byMeans :Plane ;
                    :date "05.11.2023" ;
                    :gate ...
    :Purpose :see :P .
} a :Travel .
:P {
    :Purpose :present :Paper ;
             :topic :MetaVisualization ;
             ...
}

```