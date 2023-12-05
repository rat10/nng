# Disambiguating Identification Semantics

RDF is astonishingly sloppy when it comes to identifying things: an IRI may be used to refer to a webpage or to the thing that webpage describes or to a graph retrievable from that IRI (maybe embedded as RDFa, maybe from an out-of-band defined SPARQL endpoint). NNG provides an easy way to disambiguate naming semantics on demand, clarifying what an IRI is meant to refer to when used in a given statement (and that IRI may well be used refer to something else in the next statement).   
In the following example the IRI <https://www.paris.com> is used to either refer to the website of Paris or to the city itself. The annotation via a fragment identifier disambiguates the intended referent:

```turtle
[]{<https://www.paris.com> :created 1995 .}
    nng:domain nng:Artifact.

[]{<https://www.paris.com> :created "3rd century BC" .}
    nng:domain nng:Interpretation .
```

Note that these annotations can't be used when creating an identifier, e.g. when naming a nested graph. They only serve to disambiguate the intended interpretation when using an IRI as identifier, i.e. when "calling" it in a specific way. 

## Discussion

Identification is a slippery slope, full of out-of-band conventions and everyday intuitions that suggest precision when in fact ambiguity rules the place. An IRI may be used to address a web resource itself or to denote a thing or topic in the real world that the web resource is about (see [Cool URIs](https://www.w3.org/TR/cooluris/)). Addressing is not unambiguous either: requesting an information resource from an IRI may e.g. return different representations depending on content negotiation mechanisms. Also denotation is ambiguous: the thing or topic referred to usually has facets of meaning, e.g. <https://paris.com> may be used to refer to the city of Paris, to its historic center, to the greater metropolitan area, or, depending on context, to some other topic like the Paris climate accord, the upcoming Olympics, etc.

Opinions vary on the question if this is really a problem in practice. In most cases the context in which an IRI is used provides the necessary disambiguation. However, this might not be possible to process by a machine. In some cases even contextualization will not suffice and an explicit description of identification semantics would be beneficial. 

RDF provides no easy to use and flexible provisions to express such specific identification semantics. Workarounds like IRI re-direction, hash identifiers and special sub-IRIs have been proposed, but they all have problems: they depend on out-of-band means like server configuration, they prohibit the use of hash identifiers for other purposes or they require the creation of a second set of identifiers.

## Vocabulary

We propose a small vocabulary with two classes referring to the two main kinds of identification semantics, *interpretation* and *artifact*, to be used as annotations on terms in statements via fragment identifiers. This is a late binding approach to disambiguation of identification semantics, very light weight and to be used only when needed, i.e. when vocabularies and application context don't provide enough disambiguation. 

```turtle
# VOCABULARY

nng:identifiedAs a rdf:Property ;
    rdfs:label "Interpretation semantics ;
    rdfs:comment "Specifies how an identifier should be interpreted." .

nng:Interpretation a nng:SemanticsAspect ;
    rdfs:label "Interpretation" ;
    rdfs:comment "The identifier is interpreted to refer to an entity in the real world." .

nng:Artifact a nng:SemanticsAspect ;
    rdfs:label "Artifact" ;
    rdfs:comment "The identifier is used to refer to a resource retrievable over the internet, i.e. an artifact." .
```

