# Fragment Identification

```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 


syntactic sugar
read again as a whole

```



So far we didn't discuss in depth what exactly we are annotating when we add attributes to a nested graph. There are however important differences to consider.
Annotating a triple or graph as a whole is well suited to describe administrative detail like the statement's source, date of ingestion, reliability, etc.
However, sometimes we want to qualify the statement in certain ways, like providing further detail about its subject or object or the relation type itself.

In many cases application context will help to disambiguate if an annotation is meant to annotate the statement itself or some part of it. Some vocabularies explicitly specify the type of thing they annotate to the effect that an annotation on a statement's source can't be misunderstood for describing the source of the things described in that statement.
Still, in some cases we may need to be more precise or we might in general wish for a more expressive, and also more machine-processable formalism.

As a motivating example, consider Alice buying a house when she turns 40:
```turtle
:g1 { :Alice :buys :House }
:g1?s :age 40 .       # ':g1?s' addressing the subject in ':g1', details below
```
Without the fragment identifier it would even for a human reader be impossible to disambiguate if the house is 40 years old when Alice buys it or if she herself is. A few decades from now one might even wonder if the annotation wants to express that the triple itself stems from the early days of the semantic web.
Modelling data in this way also helps to keep the number of entity identifiers low, as they can always be qualified when the need arises. In standard RDF we would have to make some contortions to precisely model what's going on, i.e. either create an identifier for `:Alice40` or, to avoid identifier proliferation, create an n-ary relation like the following:
```turtle
[ rdf:value :Alice ;
  :age 40 ] :buys :House
```
This is quite involved and does require that either users or some helpful background machinery ensure that a query for `:Alice` also retrieves all existentials that have `:Alice` as their `rdf:value` (or, in the aforementioned variant, all of `:Alice`s sub-identifiers like `:Alice40`). In a more elaborate example this style of modelling will quickly become unpractical, whereas annotations nicely ensure that the main fact stays in focus.

Fragment identifiers for RDF statements are defined as a small vocabulary. As a graph is composed of triples and triples are composed of subject, predicate and object, the following set of fragment identifiers is needed:

```turtle
# VOCABULARY

nng:subject a rdf:Property;
  rdfs:domain nng:GraphSource ;
  rdfs:comment "Addresses the subject of a statement, or all subjects of all statements in a graph source" .

nng:predicate a rdf:Property;
  rdfs:domain nng:GraphSource ;
  rdfs:comment "Addresses the predicate of a statement, or all predicate of all statements in a graph source" .

nng:object a rdf:Property;
  rdfs:domain nng:GraphSource ;
  rdfs:comment "Addresses the object of a statement, or all object of all statements in a graph source" .

nng:triple a rdf:Property;
  rdfs:domain nng:GraphSource ;
  rdfs:comment "Addresses all statements in a graph source" .

nng:graph a rdf:Property;
  rdfs:domain nng:GraphSource ;
  rdfs:comment "Addresses a graph source" .
```

A property to explicitly annotate the graph itself is provided to disambiguate careful modelling from cases where careless annotation might annotate the graph but mean a term.

However, applying that vocabulary is a bit tedious, e.g.:
```turtle
:g1 { :Alice :buys :House }
:g1 nng:subject [ :age 40 ] . 
```
To ease the pain, we define some syntactic sugar:
- `:someIRI?s` to refer to the subject
- `:someIRI?p` to refer to the predicate
- `:someIRI?o` to refer to the object
- `:someIRI?t` to refer to the triple
- `:someIRI?g` to refer to the graph

For example:
```
:g1{ :a :b :c } 
:g1?s :d :e .
```
annotates the subject `:a` in `:g1` alone. 

Annotating multiple fragments is possible in the same way:
```
:g1 { :a :b :c } 
:g1?s :d :e .
:g1?o :d :f .
```

Identification via fragment identifiers is distributive, i.e. it addresses each node of that type. An annotation of all triples in a nested graph, instead of the nested graph itself, can therefore be invoked via the `?t` triple fragment identifier, like so:
```
:g2 { :a :b :c . 
       :d :e :f }
:g2?t :g :h .
```
None of the fragment identifiers discriminates between single and multiple instances. In the example above each of the triples in graph `:g2` gets annotated individually. Likewise a reference to the subject would annotate each subject node, in this example `:a` and `:d`. 
Annotating the graph itself would either just omit the fragment identifier or, to be explicit, use the `?g` fragment identifier.


> [NOTE] 
>
> We would like to extend this mechanism to be able to address metadata in web pages, like referring to embedded RDFa via e.g. a `?RDFa` fragment identifier. It has to be seen if this can be made work in practice.
> Also, we wonder if other types of fragments, e.g. algorithmically defined complex objects like Concise Bounded Descriptions (CBD), could be addressed this way.
> One problem is that it's not obvious how the set of s/p/o/t/g fragment identifiers can be extended. Would we support namespaces in the fragment section of nested graph names? Maybe. Otherwise they would need to be hard coded into RDF. Achieving consensus on a set of algorithms would probably not be easy.