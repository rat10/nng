# Fragment Identification

So far we didn't discuss in depth what exactly we are annotating when we add attributes to a nested graph. There are however important differences to consider.
Annotating a triple or graph as a whole is well suited to describe administrative detail like the statement's source, date of ingestion, reliability, etc.
However, sometimes we want to qualify the statement in certain ways, like providing further detail about its subject or object or the relation type itself.

In many cases application context will help to disambiguate if an annotation is meant to annotate the statement itself or some part of it. Some vocabularies explicitly specify the type of thing they annotate to the effect that an annotation on a statement's source can't be misunderstood for describing the source of the subjects described in that statement.
Still, in some cases we may need to be more precise or we might in general wish for a more expressive, and also more machine-processable formalism.
This is where fragment identifiers for RDF statements come in.

Fragment identifiers are well-known in web architecture as a means to refer to specific parts of a network resource. They are appended to the resource's IRI, introduced by a `#` hash sign.
As a graph is composed of triples and triples are composed of subject, predicate and object, the following set of fragment identifiers is needed:

- #s (subject)
- #p (predicate)
- #o (object)
- #t (triple)
- #g (graph)

For example:
```
:g1{ :a :b :c } 
:g1#s :d :e .
```
annotates the subject `:a` alone. A more compact syntax is
```
[]{ :a :b :c }#s :d :e .
```
if readability is not considered an issue. However, annotating multiple fragments would mandate a separation of annotations from the annotated statement:
```
:g1 { :a :b :c } 
:g1#s :d :e .
:g1#o :d :f .
```
Identification via fragment identifiers is distributive, i.e. it addresses each node of that type. An annotation of all triples in a nested graph, instead of the nested graph itself, can therefore be invoked via the `#t` triple fragment identifier, like so:
```
:g2 { :a :b :c . 
       :d :e :f }
:g2#t :g :h .
```
None of the fragment identifiers discriminates between single and multiple instances. In the example above each of the triples in graph `:g2` gets annotated individually. Likewise a reference to the subject would annotate each subject node, in this example `:a` and `:d`. 
Annotating the graph itself would either just omit the fragment identifier or, to be explicit, use the `#g` fragment identifier.

As a motivating example, consider Alice buying a house when she turns 40:
```
:g1 { :Alice :buys :House }
:g1#s :age 40 .
```
Without the fragment identifier it would even for a human reader be impossible to disambiguate if the house is 40 years old when Alice buys it or if she herself is. A few decades from now one might even wonder if the annotation wants to express that the triple itself stems from the early days of the semantic web.
Modelling data in this way also helps to keep the number of entity identifiers low, as they can always be qualified when the need arises. In standard RDF we would have to make some contortions to precisely model what's going on, i.e. either create an identifier for `:Alice40` or, to avoid identifier proliferation, create an n-ary relation like the following:
```
[ rdf:value :Alice ;
  :age 40 ] :buys :House
```
This is quite involved and does require that either users or some helpful background machinery ensure that a query for `:Alice` also retrieves all existentials that have `:Alice` as their `rdf:value` (or, in the aforementioned variant, all of `:Alice`s sub-identifiers like `:Alice40`). In a more elaborate example this style of modelling will quickly become unpractical, whereas annotations nicely ensure that the main fact stays in focus.

> [TODO] 
> 
> The '#' syntax is failing in TriG (which is quite embarrassing TBH). Alternatives like '?' and '/' need escaping too. So either one breaks one's fingers when typing or one has to use a more explicit expression, e.g.
>
>    :g1 nng:subject [ :age 40 ]
>
> Yes, that sucks.

> [NOTE] 
>
> We would like to extend this mechanism to be able to address metadata in web pages, like referring to embedded RDFa via e.g. a `#RDFa` fragment identifier. It has to be seen if this can be made work in practice.
> Also, we wonder if other types of fragments, e.g. algorithmically defined complex objects like Concise Bounded Descriptions (CBD), could be addressed this way.
> One problem is that it's not obvious how the set of s/p/o/t/g fragment identifiers can be extended. Would we support namespaces in the fragment section of nested graph names? Maybe. Otherwise they would need to be hard coded into RDF. Achieving consensus on a set of algorithms would probably not be easy.


## Disambiguating Identification Semantics

Identification is a slippery slope, full of out-of-band conventions and everyday intuitions that suggest precision when in fact ambiguity rules the place. An IRI may be used to address a web resource itself or to denote a thing or topic in the real world that the web resource is about (see [Cool URIs](https://www.w3.org/TR/cooluris/)). Addressing is not unambiguous either: requesting an information resource from an IRI may e.g. return different representations depending on content negotiation mechanisms. Denotation itself is ambiguous: the thing or topic referred to usually has facets of meaning, e.g. <https://paris.com> may be used to refer to the city of Paris, to its historic center, to the greater metropolitan area, or, depending on context, to some other topic like the Paris climate accord, the upcoming Olympics, etc.

RDF provides no easy to use and flexible provisions to express such specific identification semantics. Although in many cases the context in which an IRI is used provides the necessary disambiguation, this might not be possible to process by a machine. In some cases even contextualization will not suffice and an explicit description of identification semantics would be beneficial. 


To help disambiguate intended identification semantics we propose a small vocabulary with two classes referring to the two main kinds of identification semantics, interpretation and artifact.
```turtle
# VOCABULARY

nng:identifiedAs a rdf:Property ;
    rdfs:label "Interpretation semantics ;
    rdfs:comment "Specifies how an identifier should be interpreted." .

nng:Interpretation a nng:SemanticsAspect ;
    rdfs:label "Interpretation" ;
    rdfs:comment "The identifier is interpreted to refer to an entity in the real world." .

nng:ART a nng:SemanticsAspect ;
    rdfs:label "Artifact" ;
    rdfs:comment "The identifier is used to refer to a web resource, i.e. an artifact." .
```


Note that these annotations can't be used when creating an identifier, e.g. when naming a nested graph. They only serve to disambiguate the intended interpretation when using an IRI as identifier, i.e. when "calling" it in a specific way. 
This proposal has several advantages over other solutions like IRI re-direction, hash identifiers and special sub-IRIs: it doesn't depend on out-of-band means like server configuration, it leaves hash identifiers for other purposes and it doesn't require the creation of a new set of identifiers.

In the following example the IRI <https://www.paris.com> is used to either refer to the website of Paris or to the city itself. The annotation via a fragment identifier disambiguates the intended referent:
```
[]{<https://www.paris.com> :created 1995 .}#s nng:identifiedAs nng:ART .
[]{<https://www.paris.com> :created "3rd century BC" .}#s nng:identifiedAs nng:INT .
```




