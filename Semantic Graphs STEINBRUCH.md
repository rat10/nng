# Semantic Graphs (SG) - DRAFT






## Graph Literals




### Graph Literal Semantics

- Quotation: a quoted assertion is not asserted and it's IRIs are not interpreted. It is really just a literal, referring to itself. However, it is of datatype RDF, which makes it amenable to further processing.
- Reification: an assertion is noted but not asserted. However, the IRIs refer to things in the realm of interpretation, they are not a form of quotation. This is the semantics of RDF standard reification.
- Literalization: an assertion is made, but IRIs are interpreted *verbatim* so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3.
- Interpretation: lastly, an assertion that is asserted and interpreted. This amounts to regular RDF, i.e. no quotation at all, no literal involved.

Again, but in tabular form (the two rightmost columns will make more sense in the course of what is outlined below):

|  semantics       |  INTERPRETED |  ASSERTED  |  abbr. |  syntax         |
|------------------|--------------|------------|--------|-----------------|
|  Quotation       |  no          |  no        |  QUT   |  "..."^^rdf:ttl |
|  Reification     |  yes         |  no        |  REI   |  []{"..."}      |
|  Literalization  |  (sort of)   |  yes       |  LIT   |  []"..."        |
|  Interpretation  |  yes         |  yes       |  INT   |  n/a            |


This categorization should cover most use cases that are not targeting specific semantic arrangements like Unique Name Assumption, Closed World Assumption, etc. Of course, there's always a way to advance even deeper into the rabbit hole...


### Unasserted Assertion

Unasserted assertions are a niche but recurring use case that so far isn't properly supported in RDF. Some participants in the RDF-star CG strongly argued in its favour. The intent is to document assertions that for any reason one doesn't want to endorse, e.g. because they are outdated, represent a contested viewpoint, don't pass a given reliability threshold, etc.

The RDF standard reification vocabulary is often used to implement unasserted assertions, but the specified semantics don't support this interpretation and its verbosity is considered a nuisance. A semantically sound and at the same time easy to use and understand mechanism would be a useful addition to RDF's expressive capabilities.

However, the semantics of existing approaches in this area, like RDF standard reification and RDF-star, differ in subtle but important aspects. We present a few different variations on the theme.


#### Quotation

The most straightforward use case of graph literals is documenting statements without endorsing them. 
```
:Bob :proclaimed ":i :LOVE :pineapples'"^^rdf:ttl .
```
A graph literal represents a quote, documenting with syntactic fidelity the assertion made (although the example somehow unrealistically assumes that Bob speaks in triples).
In a more specific arrangement we might want to document the revision history of a graph or implement an explainable AI approach. Here we aim to actually assert a statement, but also to document its precise syntactic form before any transformations or entailments. Such transformations are common in RDF processes to improve interoperability, e.g. replacing external vocabulary with inhouse terms that refer to the same meaning, entailing super- or subproperty relations or even just some syntactic normalizations. However, sometimes it is desirable to retain the initial state of an assertion.
To that end we introduce the following property:
```
DEF

sg:statedAs a rdf:Property ;
    rdfs:range sg:GraphLiteral ;
    rdfs:comment "The object describes the original syntactic form of a graph" .
```

The following example shows how this can be used to document some normalization:
```
[]{ :s :p :o } sg:statedAs ":S :p :O"^^rdf:ttl
```
In the next example the literal is accompanied by a hash value to improve security:
```
[]{ :s :p :o } sg:statedAs [
    rdf:value ":S :p :O"^^rdf:ttl ;
    sg:hash "72511fef12df97439b16ecda1415f98a"^^MD5
]
```
Note that while the graph literal is accompanying an assertion of the same type, itself it is unasserted.


#### Reification - Referentially Transparent Citation

In some cases the syntactic fidelity of straight graph literals can be problematic. We might want to document that Bob made the claim that the moon is a big cheese ball, but we don't know the exact terms he uttered. We don't know if he said `:Moon` or `:moon` and we don't want to give the impression that we do, nor do we want to be dragged into arguments about such detail.
The semantics of RDF standard reification captures this intuition as it doesn't refer to the exact syntactic representation, it is not quotation. Instead it denotes the meaning, like any triple does per the RDF semantics: it refers not to the identifier `:Moon` but to Earth's moon itself. This intuition guides the definition of the following property:
```
DEF

sg:StatementGraph a rdfs:Class ;
    rdfs:subClassOf rdf:Statement, sg:GraphLiteral ;
    rdfs:comment "A Graph Literal describing the meaning of an RDF graph" .

sg:states a rdf:Property ;
    rdfs:range sg:StatementGraph ;
    rdfs:comment "The literal object describes the original meaning of a graph" .
```
To safe us from discussions about what Bob said verbatim, but concentrate on the meaning of what he said, we would reformulate the above assertion as:
```
:Bob sg:states ":Moon :madeOf :Cheese"^^rdf:ttl .
```
Again, the graph literal is not asserted (and we have no intention to do so), but we are also not bound or even fixated on its syntactic accuracy. We just get along the fact.

To be free in the choice of properties, the following modelling primitive can be used:
```
:Bob :uttered [
    rdf:value ":Moon :madeOf :Cheese"^^rdf:ttl ;
    a sg:StatementGraph .
] 
```
Note that by default no entailments would be derived from the graph literal. Only the additional typing of the literal as statement graph will allow RDF engines to derive further facts and e.g. replace `:Moon` by `:moon`.

Mapped to RDF standard reification this would be equal to:
```
:Bob :uttered [
    a rdf:Statement ;
    rdf:subject :Moon ;
    rdf:predicate :madeOf ;
    rdf:object :Cheese .
]
```

##### Nested Graph Literals - Syntactic Sugar for RDF Standard Reification

We consider this use case important enough to warrant its own dose of syntactic sugar, a combination of braces and quotation marks:
```
:Bob :uttered []{" :Moon :madeOf :Cheese "} .
```
Intuitions, and consequently usability and acceptance in practice, are served by two aspects:

- the nested brackets signal regular RDF, i.e. interpreted, queryable
- the parentheses signal citation, not actual assertion
- a datatype declaration can be omitted as long as we're not dealing with generalized RDF

Compared to RDF standard reification this is not only less verbose, but also more intuitive to use.



### Literalization - Referentially Opaque Assertions

The RDF-star CG report has proposed an approach to quotation semantics in which the quoted RDF-star triple refers to entities in the realm of interpretation, but only via the exact syntactic form used in the RDF-star triple. 
No entailments would be derived from the graph literal.
However, contrary to the approach of RDF-star and also Notation3, the literalized graph is indeed asserted. This semantics could be specified by means of the following vocabulary:
```
DEF

sg:LiteralizedGraph a rdfs:Class ;
    rdfs:comment "A quoted assertion. IRIs are interpreted, but *verbatim*, so to say, as their literal form is significant, e.g. the IRIs `:Superman`and `:ClarkKent` can't be used interchangeably although they refer to the same thing. This is a semantics quite close to the RDF-star CG proposal and to Notation3." .

sg:statesLiterally a rdf:Property ;
	rdfs:range sg:GraphLiteral ;
    rdfs:comment "The object describes the meaning of a graph when provided in this specific syntactic form" .
```
It would be used as:
```
:Bob sg:statesLiterally ":Moon :madeOf :Cheese"^^rdf:ttl .
```
or, to be more free in the use of vocabulary:
```
:Bob :muttered [
	rdf:value ":Moon :madeOf :Cheese"^^rdf:ttl ;
	a sg:LiteralizedGraph.
] 
```




### Importing Assertions

Graph literals provide a way to reference an RDF graph for purposes beyond mere documentation and quotation. The main idea is to process via graph literals everything in need of specific semantics arrangements different from the standard RDF semantics, and manage their inclusion into the active data via specific properties. This ensures that statements with special semantics are not processed like standard RDF, which could result in unwanted entailments (that could then not be taken back because of the monotonic nature of RDF).


#### Import via Inclusion

Inclusion offers the possibility to parse a graph literal and add its content into a graph. It can intuitively be understood as adding the statements documented in a literal graph to the set of asserted statements. This works very much like `owl:imports` for ontologies and the respective property is named to allude to that similarity:
```
DEF

sg:includes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain sg:Graph ;
    rdfs:range sg:GraphLiteral ;
    rdfs:comment "Includes the literal as regular RDF data into the current graph, like owl:imports does for RDF ontologies." .
```
Importing a literal is defined on graphs and on individual nodes.

Importing a literal into a graph doesn't create a nested graph but includes the statements from the graph literal into a graph. The including graph may be explicitly named or referenced as the local graph.

The following example includes a graph literal into another graph (local or not):
```
ex:Graph_1 sg:includes ":s :p :o . :u :v :w ."^^rdf:ttl .
```
To include a graph literal into the local graph a syntactically more elegant approach is available, using a self-referencing identifier, `<.>` (see [below](#mapping-to-named-graphs)), to refer to the enclosing nested graph:
```
<.> sg:includes ":s :p :o . :u :v :w ."^^rdf:ttl .
```
Inclusion means that the graph can be assumed to contain the statements from the included literal. Those statements therefore can not only be queried but also reasoned on, new entailments can be derived, etc. However, new entailments can not be written back into the graph literal. Therefore the only guarantee that this mechanism provides is a reference to an original state.

Inclusion can also be used to provide well-formedness guarantees, comparable to un-folding/un-blessing operators in other languages. We will see such applications when discussing [shapes](#shapes) below.


#### Import via Transclusion

Transclusion in the most basic arrangement only includes by reference, meaning that a transcluded graph is asserted and can be queried, but it is referentially opaque and no entailments can be derived - blocking any kind of change to and inference on the transcluded data, much like the semantics of Notation3 formulas and RDF-star triple terms per the semantics presented in the CG report. 

The respective property is defined as:
```
DEF

sg:transcludes a rdf:Property,
    rdfs:subPropertyOf owl:imports ;
    rdfs:domain sg:Graph ;
    rdfs:range sg:GraphLiteral ;
    rdfs:comment "Transcludes the literal via reference. Transcluding a graph literal provides certain immutability guarantees for the transcluded graph." .
```
A usage example would be the following:
```
_:thisGraph sg:transcludes ":s :p :o"^^rdf:ttl .
```

However, transclusion also makes it possible to configure the semantics of transcluded graph literals. Mediating access through the transclusion property guarantees that such semantics arrangements are obeyed and no unintended entailments can leak into transcluding graphs. Configurable semantics are discussed in detail only later [below](#configurable-semantics), so a simple example has to suffice here:
```
<.> sg:transcludes [
    rdf:value ":s :p :o"^^rdf:ttl ;
    sg:semantics sg:APP
] .
```
An additional annotation with a semantics attribute, in this case `APP`, can loosen the very restrictive base semantics to arrange for use cases driven by e.g. application intuitions like a Closed World Assumption, an Unique Name Assumption, etc.



## Configurable Semantics

The semantics of RDF is designed to reflect the realities of a shared and decentralized information system spanning the whole world: no one ever has a complete grasp on the data, people use different names to refer to the same thing (and sometimes also the same name to refer to different things), no-one is entitled to modify someone else's data, what is not in the data at hand may nonetheless be true, etc. Some of these criteria have names, like the Open World Assumption (OWA) or the No Unique Name Assumption (NUNA). Some, like referential transparency, are so deeply baked into the formalism that they a barely noticed. Some only become visible through the absence of certain constructs like e.g. negation.

Some of these semantic fixings are rather counter-intuitive to application developers accustomed to closed environments e.g. driven by relational database systems, as those systems tend to take a rather opposing stance: in an in-house application the data is expected to be complete, what is not in the database is false, everything has exactly one name, etc.

Environments focusing on the integration of data tend to have a different perspective then applications optimized to put that data to use. This tension between data integration semantics for the open semantic web and application semantics for in-house use of such data has frustrated application developers since the start of the Semantic Web. At the time a popular intuition was that mechanisms should be added to the RDF semantics machinery that allowed to put into effect on demand more restrictive semantics, tailored to the needs of applications. However, such mechanisms have never materialized and one of the reasons might have been the problem of how to describe the boundaries of such a change of semantics regime, even more so after the RDF 1.1 WG failed to standardize a semantics of named graphs.
Nested graphs do offer the chance to rectify this issue as they provide a semantically sound handle to identify graphs of RDF data.


### Semantics Aspects

Establishing the right set of semantic features is of course a task on its own, but some candidates seem pretty obvious:

+ unasserted assertions, suppressing endorsement of contentious statements
+ closed world assumption, suppressing unpredictability
+ unique name assumption, suppressing co-denotation
+ referential opacity, suppressing entailments
+ negation, suppressing unwanted statements

The following vocabulary provides a term to introduce a semantics and offers a few possible applications.

```
DEF

sg:SemanticsAspect a rdf:Class ;
    rdfs:comment "An aspect of a semantics that differs from RDF’s default." .
	
sg:UNA a sg:SemanticsAspect ;
    rdfs:label "Unique Name Assumption" ;
    rdfs:comment "Each entity is denoted by exactly one identifier." 

sg:CWA a sg:SemanticsAspect ;
    rdfs:label "Closed World Assumption" ;
    rdfs:comment "The data is complete." 

sg:HYP a sg:SemanticsAspect ;
    rdfs:label "Hypothetical, unasserted Assertion" ;
    rdfs:comment "A graph documented, but not asserted." 

sg:OPA a sg:SemanticsAspect ;
    rdfs:label "Referential Opacity" ;
    rdfs:comment "All IRIs are interpreted to refer to entities in the real world, but only in the specific syntactic form provided (i.e. no co-denotation with other identifiers referring to the same entities)." .

sg:NEG a sg:SemanticsAspect ;
    rdfs:label "Negated" ;
    rdfs:comment "A graph considered false." 
```


### Semantics Profiles

From such aspects then semantic profiles can be constructed, that allow to conveniently establish environments tailored to specific needs. We could for example imagine that the following set of semantics profiles would support many if not most applications:

- `APP` - application intuitions like they are typically found in RDBMS backed systems
- `CIT` - referential opacity, as in Named Graphs, Carroll et al 2005, to faithfully record graphs, supporting use cases like versioning, explainable AI, warrants
- `TYP` - entailment-optimized semantics as hinted at in https://lists.w3.org/Archives/Public/public-rdf-star/2021May/0038.html

We can also see other, less specific uses of nested graphs concerned with semantics issues like:
- blank node scoping via specific blank node scoping graphs (maybe to be called "bGraphs")
- entailment scoping to e.g. state that within some nested graphs no contradictions are allowed (a SPARQL dataset itself constituting an outermost nested graph)

The following vocabulary combines semantics aspects and [naming semantics](#graph-types) into semantics profiles catered to different application scenarios.

```
DEF

sg:SemanticsProfile  a rdf:Class ;
    rdfs:comment "A combination of semantics aspects into a coherent whole." .

sg:hasAspect a rdf:Property ;
    rdfs:comment "Describes semantics aspects of a semantics profile" .


sg:APP a sg:SemanticsProfile ;
    rdfs:label "Application Profile" ;
    rdfs:comment "A semantics profile capturing typical intuitions of in-house application development" ;
    sg:hasAspect sg:UNA , 
                  sg:CWA ,
                  sg:Address ,      # we discourage overloading of graph names
                  sg:Identifier ,
                  sg:GraphSource .

sg:CIT a sg:SemanticsProfile ;
    rdfs:label "Citation Profile" ;
    rdfs:comment "A semantics profile capturing the semantics of Named Graphs, Carroll et al 2005, with the purpose to faithfully record graph instances with syntactic precision." ;
    sg:hasAspect sg:OPA ,
                  sg:Address ,
                  sg:Identifier ,
                  sg:GraphType .

sg:LOG a sg:SemanticsProfile ;
    rdfs:label "Logic Profile" ;
    rdfs:comment "A profile to enable reasoning over nested graphs" ;
    sg:hasAspect sg:Address ,
                  sg:Content ,
                  sg:GraphType .
```

### Practical Application

We can see two ways how such semantics profiles can be applied to RDF data: either they resort to an [transclusion](#graph-literals) construct based on regular RDF or they apply some syntactic sugar. Both approaches will be investigated below.

The practical problem that any approach on configurable semantics has to solve is how to guarantee that the RDF data so qualified can never be mistaken for regular RDF data. If the data would be introduced as a regular snippet of RDF, accompanied by an additional statement declaring its specific semantics, there could be no guarantee that an RDF processor is aware of that semantics fixing before deriving possibly unwanted entailments or in other ways processing the data in unintended ways.


#### Transclusion enabling Configurable Semantics

The transclusion mechanism introduced [above](#import-via-transclusion) allows to import graph literals with extremely restricted semantics. Adding to the transclusion a semantics instruction allows to tailor the semantics of the transcluded graph to the desired effect. We already gave the following example:
```
<.> sg:transcludes [
    rdf:value ":s :p :o"^^rdf:ttl ;
    sg:semantics sg:APP
] .
```
To make this arrangement more usable and also more tight, we could define proper subproperties of `sg:transcludes`, like e.g. `sg:transcludesAPP`:
```
sg:transcludesAPP rdfs:subPropertyOf sg:transcludes ;
                   rdfs:range sg:APP .
```
This allows a streamlined transclusion of RDF data into a graph with very specific semantics.
```
<.> sg:transcludesAPP ":s :p :o"^^rdf:ttl .
```
Integrating such transclusions into regular RDF assertions is rather seamless as well, e.g.:
```
:Bob :claims [ sg:transcludesCIT ":s :p :o"^^rdf:ttl ].
```

It isn't hard to define tailored semantics solutions from the building blocks provided so far. We might for example start from the following construct, which expresses that the list of Alice's things follows the usual application intuitions (i.e. it is not concerned with syntactic fidelity, it is complete and the unique name assumption applies):
```
:Alice :has [ rdf:value "(:D :E :F)"^^rdf:ttl ;
              sg:semantics sg:Interpretation ,
                            sg:UNA ,
                            sg:CWA ]
```
Because that's rather involved we create a shorter description of the desired semantics:  
```
ex:List a sg:SemanticsProfile ;
        sg:semantics sg:Interpretation ,
                      sg:UNA ,
                      sg:CWA .
```
And apply it:
```
:Alice :has [ rdf:value "( :D :E :F)"^^rdf:ttl ;
              sg:semantics ex:List ]
```
That's still not very elegant, so let's define a property:
```
ex:transcludesList rdfs:subPropertyOf sg:transcludes ;
                   rdfs:range ex:List .
```
And apply that:
```
:Alice :has [ ex:transcludesList "( :D :E :F )"^^rdf:ttl ]
```
That's of course a bit much for one list, but it may pay off in an application context where we know that certain data sources are indeed complete and well kept and therefore it's safe to overrule the integration focused standard semantics of RDF.


#### Syntactic Sugar for Configurable Semantics

> [TODO]  
>
> This syntactic sugar is not tested yet and needs more work. The re-use of prepended square brackets to not declare a name but a semantics may cause more irritation than comfort.

The following syntactic sugar aims to express transclusion with configurable semantics even more succinctly. An RDF graph literal is prepended with an argument specifying the intended semantics, re-using the already familiar square bracket syntax, e.g.:

[APP]":a :b :c , :d" :e :f .

Because of the prepended argument the explicit datatype declaration can be omitted.
Prepending the semantics fixing ensures that it can not be overlooked by a conforming parser. 

The following examples show some possible scenarios, involving both aspects and profiles:
```
[APP]" :a :b :c , :d " :e :f .
:g :h [LOG]" :h :i :k " .
:l :m [HYP,OPA]" :n :o :p " ,
      [NEG,CIT]" :q :r :s " .
```
Note that mixing semantics profiles is not advisable with the profiles suggested above, as properties might contradict each other. In principle however profiles and aspects can be combined in modular fashion. If contradictions occur, the fixings of inner nested graphs overrule those of the graphs enclosing them. Contradictions within the same nested graph can't be resolved automatically and have to be interpreted as logical `OR`.


#### Term Semantics Syntactic Sugar


To make the application of configurable semantics more precise we explore a variant of RDF literals that targets individual terms. 

A popular example to motivate referential opacity is the Superman comic, with the reporter Louis Lane not being aware that her crush Superman is in fact the same person as her slightly dull colleague Clark Kent. This can precisely be modelled with a referentially opaque semantics applied only to the identifier for Superman: 
```
:LouisLane :loves [OPA]":Superman" .
```
Note how the references to Louis Lane and the concept of loving are still referentially transparent, as they should be, and solely the reference to Superman is constrained to refer only to that specific persona of the extra-terrestrial character Kal-El, but never to its alternative persona Clark Kent.

Here the square bracket prefix notation is used not to name the term - there's no need for that - but to indicate a certain semantics. This syntax in combination with the literal guarantees that the reference to Superman is always interpreted with the appropriate semantics. In this special datatype declaration may be omitted.

> [TODO]
>
> This syntactic sugar is not solidly defined yet. It would be nice to have but still needs some work.
> A slightly less daring, but also less succinct variant would be a simple property list combined with a term literal:
>    [sg:semantics sg:Opaque]":Superman"









# TODO
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        




#



