# Shapes

# this is WORK IN PROGRESS

> [TODO]  
> The main aim is to establish anchor points that allow to impose tighter constraints on shapes and semantics of RDF constructs - nested graphs, lists and even terms, the idea being that establishing *one* such anchor point can solve *many* problems
> However, not everything is well thought out yet:
> - obviously the shortcut syntax isn't finished
> - maybe the mapping to RDF has to use [inclusion/transclusion](#importing-assertions) to be really on the safe side w.r.t. monotonicity, maybe a syntactic mapping to n-ary relations is good enough
> - the mix of shape and semantics needs more investigation
> - are shapes really the best overarching abstraction and does the effect warrant the effort?

Shapes have been proposed in different variants like SHACL and SHEX to improve reliability and predictability of data modelling. 
We extend this approach to nested graphs, aiming at a tighter integration of shapes into RDF data. We then carry that syntactic feature over to lists as well as individual nodes to provide streamlined solutions for some nagging problems of RDF.

To that end we define the following property:
```
nng:hasShape a rdf:Property ;
    rdfs:comment "The subject - either a nested graph, a list or a term - follows the description of the object, a shape definition provided in SHACL or SHEX." .
```

The following example annotates a nested graph with a SHACL shape definition:
```
[]{ :s :p :o } nng:hasShape :MyFirstShape .
:MyFirstShape a sh:NodeShape ;
    [...]
```
The same principle can be applied to lists and terms:
```
[ a rdfs:Collection ;
  rdf:value ( :a :b :c :d ) ;
  nng:hasShape :MyFirstList 
  ]
[ a rdfs:Resource ;
  rdf:value <:a> ;
  nng:hasShape :MyFirstTerm
  ] :b :c .
```
We will introduce some examples of useful shapes for lists and terms in following sections.
[TODO] will we indeed?

However, we first need to tackle an obvious problem: the approach is syntactically rather verbose.


## Syntax
The basic syntactic instrument to overcome the verbosity of the approach is a keyword prepended to a nested graph, list or term. To that end again the square bracket syntax introduced with nested graphs is reused, combined with a query parameter on the name of the construct to indicate the intended shape, e.g.:
```
[:g1?shape=SomeGrafShape]{ :a :b :c }       # nested graph
[:l1?shape=SomeListShape]( :a :b :c :d )    # list
[:t1?shape=SomeTermShape]< :a >             # term
```
[TODO]  this requires to name any graph that has non-standard semantics
            but that is probably not too grave a demand
        or just omit the name, but keep the query parameter?, e.g.:
            `[?shape=SomeGrafShape]{ :a :b :c }`
            ?

Not every shape can be defined on every primitive, e.g. list shapes can only be applied to rounded bracket lists, identification shapes only to terms in pointy brackets, complex shapes only to nested graphs. Shape definitions have to declare to which primitives they can be applied. 

[TODO]  how are the shape naming keywords defined?
            that probably needs some apparatus
            or is it just a (namespaced) IRI ?
            but that wouldn't work well as query parameter
        can there be a directory of sorts, a vocabulary?
        is another special addition to the header needed :-( ?


## Applications

In following sections we will discuss 
- [list shapes](#list-shapes) to better meet developer expectations, 
- [graph shapes](#configurable-semantics-configsemantics) to configure the semantics of data and 
- [term shapes](#disambiguating-identification-semantics) to describe identification semantics in some detail.


[TODO]  one complete example with
        - a valid shape
        - valid namespace declarations
        - etc
