# Configurable Semantics


```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

convert to Nested Named Graphs
semantics per property
term semantics per annotation
namespaced semantics identifiers?

```



The semantics of RDF is designed to reflect the realities of a shared and decentralized information system spanning the whole world: no one ever has a complete grasp on the data, people use different names to refer to the same thing, no-one is entitled to change the truth value of someone else's data, what is not in the data at hand may nonetheless be true, etc. Some of these criteria have names, like the Open World Assumption (OWA) or the No Unique Name Assumption (NUNA). Some, like referential transparency, are baked so deeply into the formalism that they a barely noticed. Some only become visible through the absence of certain constructs like e.g. negation.

Some of these semantic fixings are rather counter-intuitive to application developers accustomed to closed environments e.g. driven by relational database systems, as those systems tend to take a rather opposing stance: in an in-house application the data is expected to be complete, what is not in the database is false, everything has exactly one name, etc.
This tension between data *integration* semantics for the open semantic web and *application* semantics for in-house use of such data has frustrated application developers since the start of the Semantic Web. At the time a popular intuition was that mechanisms should be added to the RDF semantics machinery that allowed to put into effect on demand more restrictive semantics, tailored to the needs of applications. However, such mechanisms have never materialized and one of the reasons might have been the problem of how to describe the boundaries of such a change of semantics regime, even more so after the RDF 1.1 WG failed to standardize a semantics of named graphs.
Graph literals offer a chance to rectify this issue as they soundly discriminate between abstract graphs as literal types and their application via [inclusion](graphLiterals.md).

We present here a vocabulary to implement configurable semantics via the inclusion of graph literals. This is rather a proof of concept than a definite proposal, and predominantly meant to illustrate the potential of this approach.



## Semantics Aspects

Establishing the right set of semantic features is a task on its own, but some candidates seem pretty obvious:
+ unasserted assertions, suppressing endorsement of contentious statements
+ closed world assumption, suppressing unpredictability
+ unique name assumption, suppressing co-denotation
+ referential opacity, suppressing entailments
+ negation, suppressing unwanted statements

The following vocabulary provides a term to introduce a semantics and offers a few possible applications.

```turtle
# VOCABULARY

nng:SemanticsAspect a rdf:Class ;
    rdfs:comment "An aspect of a semantics that differs from RDF’s default." .
	
nng:UNA a nng:SemanticsAspect ;
    rdfs:label "Unique Name Assumption" ;
    rdfs:comment "Each entity is denoted by exactly one identifier." 

nng:CWA a nng:SemanticsAspect ;
    rdfs:label "Closed World Assumption" ;
    rdfs:comment "The data is complete." 

nng:HYP a nng:SemanticsAspect ;
    rdfs:label "Hypothetical, unasserted Assertion" ;
    rdfs:comment "A graph documented, but not asserted." 

nng:OPA a nng:SemanticsAspect ;
    rdfs:label "Referential Opacity" ;
    rdfs:comment "All IRIs are interpreted to refer to entities in the real world, but only in the specific syntactic form provided (i.e. no co-denotation with other identifiers referring to the same entities)." .

nng:NEG a nng:SemanticsAspect ;
    rdfs:label "Negated" ;
    rdfs:comment "A graph considered false." 
```


## Semantics Profiles

From such aspects then semantic profiles can be constructed, that allow to conveniently establish environments tailored to specific needs. We could for example imagine that the following set of semantics profiles would support many if not most applications:

- `APP` - application intuitions like they are typically found in RDBMS backed systems
- `CIT` - referential opacity, as in Named Graphs, Carroll et al 2005, to faithfully record graphs, supporting use cases like versioning, explainable AI, warrants
- `TYP` - entailment-optimized semantics as hinted at in https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html

We can also see other, less specific uses of nested graphs concerned with semantics issues like:
- blank node scoping via specific blank node scoping graphs (maybe to be called "bGraphs")
- entailment scoping to e.g. state that within some nested graphs no contradictions are allowed (a SPARQL dataset itself constituting an outermost nested graph)

The following vocabulary combines semantics aspects and [naming semantics](#graph-types) into semantics profiles catered to different application scenarios.

```turtle
# VOCABULARY

nng:SemanticsProfile  a rdf:Class ;
    rdfs:comment "A combination of semantics aspects into a coherent whole." .

nng:hasAspect a rdf:Property ;
    rdfs:comment "Describes semantics aspects of a semantics profile" .


nng:APP a nng:SemanticsProfile ;
    rdfs:label "Application Profile" ;
    rdfs:comment "A semantics profile capturing typical intuitions of in-house application development" ;
    nng:hasAspect nng:UNA , 
                  nng:CWA ,
                  nng:Address ,      # we discourage overloading of graph names
                  nng:Identifier ,
                  nng:GraphSource .

nng:CIT a nng:SemanticsProfile ;
    rdfs:label "Citation Profile" ;
    rdfs:comment "A semantics profile capturing the semantics of Named Graphs, Carroll et al 2005, with the purpose to faithfully record graph instances with syntactic precision." ;
    nng:hasAspect nng:OPA ,
                  nng:Address ,
                  nng:Identifier ,
                  nng:GraphType .

nng:LOG a nng:SemanticsProfile ;
    rdfs:label "Logic Profile" ;
    rdfs:comment "A profile to enable reasoning over nested graphs" ;
    nng:hasAspect nng:Address ,
                  nng:Content ,
                  nng:GraphType .
```

## Practical Application

We can see two ways how such semantics profiles can be applied to RDF data: either they explicitly [include graph literals](graphLiterals.md) or they apply some syntactic sugar.

The practical problem that any approach on configurable semantics has to solve is how to guarantee that the RDF data so qualified can never be mistaken for regular RDF data. If the data is introduced as a regular snippet of RDF, accompanied by an additional statement declaring its specific semantics, RDF provides no guarantee that an RDF processor is aware of that semantics fixing before deriving possibly unwanted entailments that can then not be taken back. Such guarantees can be provided through out-of-band means, e.g. by careful control of entailment procedures and entailed statements. Another way is to implement the inclusion in a way that no misunderstanding is possible, e.g. by defining very specific inclusion properties for each desired semantics. The latter approach will be discussed in some of the following scenarios.


### Inclusion enabling Configurable Semantics

The inclusion mechanism allows to import graph literals with extremely restricted semantics. Adding to the inclusion a semantics instruction allows to tailor the semantics of the included graph to the desired effect. We already gave the following example:
```
THIS nng:includes [
    rdf:value ":s :p :o"^^nng:GraphLiteral ;
    nng:semantics nng:APP
] .
```
To make this arrangement more usable and also tighter against misinterpretation by an over-eager inferencing engine, we could define proper subproperties of `nng:includes`, like e.g. `nng:includesAPP`:
```
nng:includesAPP rdfs:subPropertyOf nng:includes ;
                rdfs:range nng:APP .
```
This allows a streamlined inclusion of RDF data into a graph with very specific semantics.
```
THIS nng:includesAPP ":s :p :o"^^nng:GraphLiteral .
```
Integrating such inclusions into regular RDF assertions is rather seamless as well, e.g.:
```
:Bob :claims [ nng:includesCIT ":s :p :o"^^nng:GraphLiteral ].
```

Tailored semantics can be defined from the building blocks provided so far. We might for example start from the following construct, which expresses that the list of Alice's things follows the usual application intuitions, i.e. it is not concerned with syntactic fidelity, it is complete and the unique name assumption applies. We call it `ClosedList`:
```
:Alice :has [ rdf:value "(:D :E :F)"^^nng:GraphLiteral ;
              nng:semantics nng:Interpretation ,
                            nng:UNA ,
                            nng:CWA ]
```
Because that's rather involved we create a shorter description of the desired semantics:  
```
ex:ClosedList a nng:SemanticsProfile ;
              nng:semantics nng:Interpretation ,
                            nng:UNA ,
                            nng:CWA .
```
And apply it:
```
:Alice :has [ rdf:value "( :D :E :F)"^^nng:GraphLiteral ;
              nng:semantics ex:ClosedList ]
```
That's still not very elegant, so let's define a property:
```
ex:includesClosedList rdfs:subPropertyOf nng:includes ;
                      rdfs:range ex:ClosedList .
```
And apply that:
```
:Alice :has [ ex:includesClosedList "( :D :E :F )"^^nng:GraphLiteral ]
```
That's of course a lot of effort for one list, but it can pay off in an application context where we know that certain data sources are indeed complete and well kept and therefore it's safe to overrule the integration focused standard semantics of RDF.


### Syntactic Sugar for Configurable Semantics

The following syntactic sugar aims to express inclusion with configurable semantics even more succinctly. 
An anonymous RDF graph literal is equipped with an argument specifying the intended semantics, re-using the already familiar square bracket syntax, e.g.:

[APP]":a :b :c , :d" :e :f .

The following examples show some possible scenarios, involving both aspects and profiles:
```
[APP]" :a :b :c , :d " :e :f .
:g :h [LOG]" :h :i :k " .
:l :m [HYP,OPA]" :n :o :p " ,
      [NEG,CIT]" :q :r :s " .
```
Note that mixing semantics profiles is not advisable with the profiles suggested above, as properties might contradict each other. In principle however profiles and aspects can be combined in modular fashion. If contradictions occur, the fixings of inner nested graphs overrule those of the graphs enclosing them. Contradictions within the same nested graph can't be resolved automatically and have to be interpreted as logical `OR`.

This syntactic sugar requires that the included literal is named by a bank node, not by an explicit name - a restriction that we consider sensible anyway.


### Term Semantics Syntactic Sugar

To make the application of configurable semantics more precise we explore a variant of RDF literals that targets individual terms. 

A popular example to motivate referential opacity is the Superman comic, with the reporter Lois Lane not being aware that her crush Superman is in fact the same person as her slightly dull colleague Clark Kent. This can precisely be modelled with a referentially opaque semantics applied only to the identifier for Superman: 
```
:LouisLane :loves [OPA]":Superman" .
```
Note how the references to Louis Lane and the concept of loving are still referentially transparent, as they should be, and solely the reference to Superman is constrained to refer only to that specific persona of the extra-terrestrial character Kal-El, but never to its alternative persona Clark Kent.

Here the square bracket prefix notation is used not to name the term - there's no need for that - but to indicate a certain semantics. This syntax in combination with the literal guarantees that the reference to Superman is always interpreted with the appropriate semantics. In this special datatype declaration may be omitted.

> [TODO]
>
> This syntactic sugar is not solidly defined yet. It would be nice to have but still needs some work.
> A slightly less daring, but also less succinct variant would be a simple property list combined with a term literal:
>    [nng:semantics nng:Opaque]":Superman"
