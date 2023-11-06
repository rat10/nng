# Lists

Lists are not only an indispensable construct in any programming language, they also are one of the most fundamental knowledge representation structures. From this follows that RDF should provide intuitive and easy to use means to support lists. 
To that end RDF does indeed provide two different constructs, collections and containers, but none of them hits the sweet spot of concise syntax and intuitive semantics. Without going into the merits and problems of RDF’s list apparatus in more detail we would like to suggest two extensions to it: a `length` attribute for containers and some syntactic sugar that makes Turtle’s rounded bracket syntax available to them.


## Length Attribute

Adding a length attribute to the container vocabulary enables users to describe how many entries a list is supposed to have. 
```
DEF

seg:length a rdf:Property ;
    rdfs:domain rdfs:Container ;
    rdfs:range xsd:integer ;
    rdfs:comment "Describes the number of entries of an rdf:Collection (rdf:Bag, rdf:Seq, rdf:Alt). Numbering is expected to start from 1 and missing entries may be interpreted as implicit existentials (i.e. blank nodes)." .
```

Applications will have to decide what to make of containers that have less or more entries or whose entries are not consecutively numbered, beginning with `rdf:_1`. They may replace missing entries by blank nodes, like e.g. in the following sequence that misses the second entry. In any case at least they have been warned that something might be amiss.
```
_:x a rdf:Bag ;
    seg:length 3 ;
    rdf:_1 :Alice ;
    rdf:_2 [] ;
    rdf:_3 :Carol .
```
The RDF collection vocabulary was introduced to provide OWL with a means to describe axiomatic lists of some definite length. A well-formed collection does indeed do that, but RDF can give no guarantees about well-formedness. A length attribute for RDF containers achieves the same effect, with much less syntactic verbosity.


## Syntactic Sugar for Containers

RDF collections, despite - or because of - their structural verbosity get all the syntactic sugar in RDF's popular Turtle serialization. That seems unbalanced given that containers are easier to query and more performant (see Daga et al, 2019, Modelling and Querying Lists in RDF - A Pragmatic Study).
We propose to extend the syntactic sugar for RDF collections in Turtle by a prefix that makes the rounded bracket usable for containers and safer for non-axiomatic collections. We define the following list shapes:

- `BAG`, like rdf:Bag
- `SEQ`, like rdf:Seq
- `ALT`, like rdf:Alt
- `OWL`, like RDF collection, but explicitly for OWL axiomatic lists

A length attribute can be appended to the type indicator, delimited via a colon, e.g.:
```
SEQ:3
```
To state that a list of Alice's cars contains exactly three entries, describing the order in which she bought those cars, we write:
```
:Alice :owns [?SEQ:3]( :Sedan :StationWagon :Coupe ) .
```

This is much shorter than the corresponding RDF sequence without syntactic sugar:
```
:Alice :owns [
    a rdf:Seq ; 
    seg:length 3 ;
    rdf:_1 :Sedan ; 
    rdf:_2 :StationWagon ; 
    rdf:_3 :Coupe
]
```
By default list entries follow the standard RDF semantics, i.e. they are interpreted, referentially transparent etc. Other options will be discussed below.
[TODO]  will they?


### SET Containers

An open question is if for completeness we also need a `SET` container, which could be provided with a length attribute, but would establish that order is not important and duplicates will be purged. However, the difference to regular n-ary relations might be too negligible to justify its introduction, as the difference in semantics between e.g. `:a :b :c , :d .` and `:a :b (SET :c :d) .` is quite marginal.


### ARRAY Containers

Another candidate for a list type is `ARY`, short for array. This type would be catered to developers looking for a list with strong syntactic guarantees, e.g. the list being well-formed (or otherwise throwing a syntax error), numbered beginning with 0, providing explicit numbering to record empty slots, ordered, of definite length, with bag semantics. 


## List Shapes

[TODO]  too much handwaving

Developers often demand lists with guarantees w.r.t. completeness, closedness etc. Those can be provided via the same mechanisms that we envision to manage semantics of nested graphs: more rigid structures can be provided through quoted graphs and graph literals, and closed world and unique name assumptions may be declared explicitly. 

Shape languages like SHACL and SHEX provide the means to define these and other list types and add user-defined criteria like further restrictions on the value types (e.g. the first value has to be a literal), on the kind of ordering, etc. However, they can’t change the property type which has to be `rdfs:member`.

The list typing syntax makes it easy to deploy such user-defined list shapes, e.g.:
```
:LS_1 rdf:type :Shape ;
    rdfs:comment "my first list shape" ;
    shape:definitions [...] .
[?shape=:LS_1]( :a :b :c :d ) :y :z .
```

[TODO]  an example of how to define a proper list shape


### Lists as Objects - Nameable, Annotatable

Lists in RDF already are instances, provided with identity, and can be named and referenced like nested graphs, e.g.:
```
:Alice :has [
    a rdf:Seq ;
    rdf:_1 :X ;
    rdf:_2 :Y .
    rdfs:label :AliceList ;    # nothing wrong with giving the list a name
]
```
Distributive ForEach semantics that refer to each entry in a list can be achieved through fragment identifiers, e.g.:
```
[?SEQ](:a :b :c )#term :d :e .
```
entails 
```
:a :d :e .
:b :d :e .
:c :d :e .
```	
or, to give a slightly more involved example:
```
:Alice :has [:AliceList?SEQ:2](:X :Y)#term :d :e .
```
(and the same as regular RDF:
```
:Alice :has [
    rdfs:label :AliceList ;
    a rdf:Seq ;
    seg:length 2 ;
    rdf:_1 :X ;
    rdf:_2 :Y .
]
:MyList#term :d :e .
```	
) entails:
```	
:X :d :e .
:Y :d :e .
```
 
 It has of course to be ensured that annotations are only applied to members of the list, not to other attributes like length and name.



<!--- 
		more details and discussions about lists in my mail                              
		"summarizing a semanticweb@w3.org thread on lists from Aug/Sep 2022" 		
-->

<!-- 
       () lists
            BAG
            SEQ
            ALT
            ARY
            SET

        and other shapes
-->