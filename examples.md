# Examples


## WG Use Cases
[WG use case wiki](https://github.com/w3c/rdf-ucr/wiki)  
[Summary](https://github.com/w3c/rdf-ucr/wiki/Summary)  
[More use cases, yet un-redacted](https://github.com/w3c/rdf-ucr/wiki/Status-of--use-cases-submitted-to-community-group)


### [Capturing triple origin in SPARQL-star](https://github.com/w3c/rdf-ucr/wiki/Capturing-triple-origin-in-SPARQL-star)

This is actually a querying use case, exploring how the annotation syntax can be used in WHERE clauses to capture the source of a result when the query runs over multiple datasets.
```turtle
SELECT * WHERE {
   ?g { ?s ?p ?o } rdf:source ?source . 
}
```
[TODO] check


### [Describing a Union of Changes to a Named Graph](https://github.com/w3c/rdf-ucr/wiki/Describing-a-Union-of-Changes-to-a-Named-Graph)

The original example is as follows:
```turtle
prefix : <http://example.org/ns#>
base <http://example.com/>

graph <data?version=1> {
  <7d5d0d651caa> a :Work .
}
graph <data?version=2> {
  <7d5d0d651caa> a :Text .
  << <7d5d0d651caa> :subject <semantics> >> :suggestedBy <classifyer> .
}
```

The WG use case wiki argues that the use cases requires tokens, not types, if an outdated versions happens to have occurred multiple times but under differing circumstances. We choose `Quote` semantics to provide referential opacity for the inner unasserted statement in graph `data?version=2`. We could also apply that to the superseded graph `data?version=1`.
```turtle
<data?version=1> {
  <7d5d0d651caa> a :Work .
}
<data?version=2> {
  <7d5d0d651caa> a :Text .
  [] << <7d5d0d651caa> :subject <semantics> . >> :suggestedBy <classifyer> .
}
```

The WG use case wiki provides the following translation to RDF-star:
```turtle
<7d5d0d651caa> a :Text {| :statedIn <data?version=2> |} .
<< <7d5d0d651caa> a :Work >> :statedIn <data?version=1> ; :retractedIn <data?version=2> .
<< <7d5d0d651caa> :subject <semantics> >> :suggestedBy <classifyer> {| :statedIn <data?version=2> |} .
```

That we would translate to NNG in another way:
```turtle
[] { <7d5d0d651caa> a :Text }
     :statedIn <data?version=2>

[] << <7d5d0d651caa> a :Work . >>
     :statedIn <data?version=1> ; 
     :retractedIn <data?version=2> .

[] { [] << <7d5d0d651caa> :subject <semantics> . >>
        :suggestedBy <classifyer> } ;
      :statedIn <data?version=2> .   
```


### [CIDOC-CRM events](https://github.com/w3c/rdf-ucr/wiki/RDF-star-for-CIDOC-CRM-events)

The use case centers around the need to represent a current version and two unasserted previous versions. The previous versions themselves are identical, but have different annotations. We use the `Report` type (referentially transparent and unasserted) to encode them.

```turtle
ex:Ioannes_68 a crm:E21_Person , ex:Gender_Eunuch ;
    rdfs:label "John the Orphanotrophos" .

# the current version
<#assignment-1> { ex:Ioannes_68 a ex:Gender_Eunuch }
	a crm:E17_Type_Assignment ;
	crm:P14_carried_out_by ex:Paphlagonian_family ;
	rdfs:label "Castration gender assignment" .

# a previous version, from one source
[] "{ ex:Ioannes_68 a ex:Gender_Male }"
    a crm:E17_Type_Assignment ;
    crm:P14_carried_out_by ex:emperor ;
    crm:P182_inverse_starts_after_or_with_the_end_of <#assignment-1> ;
    rdfs:label "Gender assignment by decree" .

# the same previous version, but from another source
[] "{ ex:Ioannes_68 a ex:Gender_Male }"
    a crm:E17_Type_Assignment ;
    crm:P14_carried_out_by ex:Paphlagonian_family ;
    crm:P183_ends_before_the_start_of <#assignment-1> ;
    rdfs:label "Birth gender assignment" .
```


### [RDF star for explanation and provenance in biological data](https://github.com/w3c/rdf-ucr/wiki/RDF-star-for-explanation-and-provenance-in-biological-data)

This is a use case from the UniProt project which until today uses RDF/XML because of its syntactic sugar for RDF standard reification. Converting it to NNG is straightforward. The WG UC wiki argues that the use case calls for referential transparency, despite it belonging to the provenance category, and that it is unclear if types or tokens are to be preferred. We would argue that a token-bases approach at least doesn't do any harm.
```turtle
[] { <Q14739#SIP9E6E0C5B850FBF4F> up:fullName "3-beta-hydroxysterol Delta (14)-reductase" }
    up:attribution [ up:manual true ;
     		         up:evidence ECO:0000303 ;
 		             up:source citation:16784888 ] .
```


### [RDF star for labelled property graphs](https://github.com/w3c/rdf-ucr/wiki/RDF-star-for-labelled-property-graphs)

This use case is about one of the prime drivers of the RDF-star standardization effort: improving compatibility between RDF and LPG. 
As with most use cases it favors tokens over types, in this case emphasized by the fact that LPGs support multi-edges. Contrary to the UC wiki, which argues for an unclear situation, we see a need for referential transparency (but could just as well employ e.g. quoting semantics).   
The use case is also interesting in that it explicitly mentions that the annotation mechanism shouldn't interact with named graphs. So it conflates two important topics.   
However, as no details are provided we can only make up a very synthetic example combining named graphs from the application domain with nested graphs from the annotation domain.
```turtle
:Application_1 {
    :Annotation_1 { :a :b :c } :d 1 .
    :Annotation_2 { :a :b :c } :d 2 .
}
```
Of course, an application that has strong assumptions about the named graphs in its dataset might be irritated about named graphs that actually represent annotations. However, it can only be speculated about if such assumptions are harder to cater for than incorporating a new term type.

Dydra's implementation currently stores all nesting relations (here described via `http://nng.org/transcludes`) in a separate graph. This graph is consulted about the semantics of each named graph when constructing a target graph. 
```turtle
<urn:dydra:default>             <http://nng.org/transcludes>    <http://ex.org/Application_1>   <http://nng.org/embeddings> .
<http://ex.org/Application_1>   <http://nng.org/transcludes>    <http://ex.org/Annotation_y>    <http://nng.org/embeddings> .
<http://ex.org/Application_1>   <http://nng.org/transcludes>    <http://ex.org/Annotation_x>    <http://nng.org/embeddings> .
<http://ex.org/Annotation_y>    <http://ex.org/d>               <http://ex.org/y>               <http://ex.org/Application_1> .
<http://ex.org/Annotation_x>    <http://ex.org/d>               <http://ex.org/x>               <http://ex.org/Application_1> .
<http://ex.org/a>               <http://ex.org/b>               <http://ex.org/c>               <http://ex.org/Annotation_y> .
<http://ex.org/a>               <http://ex.org/b>               <http://ex.org/c>               <http://ex.org/Annotation_x> .
```




### [RDF star for recording commit deltas to an RDF graph](https://github.com/w3c/rdf-ucr/wiki/RDF-star-for-recording-commit-deltas-to-an-RDF-graph) 

The WG wiki argues that the use case calls for lists of triples, not triples - and we would argue that graphs are even more helpful - and full opacity (also of blank nodes).
```turtle
r:47e1cf2 a :Commit ; 
    :graph r:geneology;
    :time "2002-05-30T09:00:00"^^xsd:dateTime;
    :delete [] << a:bob b:age 23 . >> ;
    :add [] << a:bob b:age 24 . a:bob b:gender b:male . >> .
r:47a54ad a :Commit ; 
    :graph r:geneology;
    :time "2002-06-07T09:00:00"^^xsd:dateTime;
    :add [] {                               # TODO we don't have nested quotes yet
        [] << a:bob b:gender b:male . >> b:certainty 0.1 
    }.
r:47a54ae a :Commit ; 
     :graph r:geneology;
     :time "2002-06-07T09:00:01"^^xsd:dateTime;
     :add [] {                              # TODO we don't have nested quotes yet
        [] << a:bob b:gender b:male . >> b:support _:x .
     	_:x b:source b:news-of-the-world  ;
     	    b:date "1999-04-01"^^xsd:date  . 
 	    [] << a:bob b:gender b:male . >> b:support _:y  .
     	_:y b:source b:weekly-world-news ;
     	    b:date "2001-08-09"^^xsd:date  .
     }
```


### [RDF‐star for Wikidata](https://github.com/w3c/rdf-ucr/wiki/RDF%E2%80%90star-for-Wikidata)

There are different ways to model Wikidata. The UC wiki choses one in which the a main relation (one could also call it a shortcut, see below) is represented as a standard RDF triple, and variants are represented unasserted statements with appropriate annotations. The UC wiki identifies those annotated and unasserted statements as tokens, not types. It argues that it is unclear if those unasserted statements should be considered referentially transparent or opaque. We follow the principle "In dubio pro Open World" and treat them as referentially transparent, but unasserted `Report`s.
```turtle
[] { wd:USA wd:president wd:JoeBiden . }
     wikibase:rank wikibase:PreferredRank ;
     wd:start_date "2021-01-20"^^xsd:dateTime ;
     wd:predecessor wd:DonaldTrump ;
     prov:wasDerivedFrom wdref:a_reference , wdref:an_other_reference .

[] "{ wd:USA wd:president wd:DonaldTrump . }"
     wikibase:rank wikibase:NormalRank ;
     wd:start_date "2017-01-20"^^xsd:dateTime ;
     wd:start_date "2021-01-20"^^xsd:dateTime .
```



## Other Examples

### Descriptions and Situations (DnS) shortcut relations

Descriptions and Situations (DnS) is an ontology design patterns that distinguishes the description of objects and the relations between these objects - not un-similar to the way Labeled Property Graphs model information. A particularly interesting concept is that of a "shortcut relation": a basic relation that captures the essential information hidden in a much more complex n-ary relation. Different projects from the cultural heritage domain use this approach: they model data in ways amenable to OWL reasoners, but add such shortcut relations to help users navigate the resulting often very complex structures.
In the example below the central piece of information is that Alice visits the ISWC conference. That statement is annotated with links to background information like a detailed travel schedule and what she plans to do at the conference. 


```turtle
:T1 {
    :Alice :travelsTo :ISWC23 .
    THIS nng:relation [ rdfs:seeAlso :S1 ,    # THIS graph self reference
                                     :P1 ] .
} a :Travel .
:S1 {
    :Schedule :startsAt :Hamburg ;
              :byMeans :Plane ;
              :date "05.11.2023" ;
              :gate ...
} a :Schedule .
:P1 {
    :Purpose :present :Poster ;
             :topic :MetaVisualization ;
             ...
}
```

### Layers of Nesting Embedded in Named Graphs as we know them
This example combines several orthogonal dimensions of annotation: application specific dimensions and unsound graph naming practices, and also administrative annotations intermixed with qualifying annotations.
```turtle
prefix :    <http://ex.org/>
prefix nng: <http://nng.io/>

:Bob :source :Laptop ;
     :status :Unredacted ;
     :visibility :Private .

:Bob {
    :Z {
        :Y {
            :X {
                :Alice :buys :Car .
            } 
            nng:domain [ :age 20 ] ;
            nng:relation [ :payment :Cash ;
                            :purpose :JoyRiding ] ;
            nng:range [ :color :black ;
                         :model :Coupe ] ;
            nng:graph [ :source :Denis ] .
        }
    } :type :FirstCarEvent ;
      :source :GreenDiary ;
      :date :10_12_08 .
}
```
Imagine adding more levels of nesting for different accounts of Alice buying her first car,
eg her parents helping fund it,
the insurance company having yet a different view, etc. Nothing breaks, it's just adding more layers of nesting.

```turtle
<http://ex.org/Bob>     <http://ex.org/source>        <http://ex.org/Laptop> .
<http://ex.org/Bob>     <http://ex.org/status>        <http://ex.org/Unredacted> .
<http://ex.org/Bob>     <http://ex.org/visibility>    <http://ex.org/Private> .
<http://ex.org/Bob>     <http://nng.io/transcludes>   <http://ex.org/Z>             <http://ex.org/Bob> .
<http://ex.org/Z>       <http://nng.io/transcludes>   <http://ex.org/Y>             <http://ex.org/Z> .
<http://ex.org/Y>       <http://nng.io/transcludes>   <http://ex.org/X>             <http://ex.org/Y> .
<http://ex.org/Alice>   <http://ex.org/buys>          <http://ex.org/Car>           <http://ex.org/X> .
<http://ex.org/X>       <http://nng.io/subject>       _:o-93                        <http://ex.org/Y> .
_:o-93                  <http://ex.org/age>           "20"^^<http://www.w3.org/2001/XMLSchema#integer> 
                                                                                    <http://ex.org/Y> .
<http://ex.org/X>       <http://nng.io/predicate>     _:o-94                        <http://ex.org/Y> .
_:o-94                  <http://ex.org/payment>       <http://ex.org/Cash>          <http://ex.org/Y> .
_:o-94                  <http://ex.org/purpose>       <http://ex.org/JoyRiding>     <http://ex.org/Y> .
<http://ex.org/X>       <http://nng.io/object>        _:o-95                        <http://ex.org/Y> .
_:o-95                  <http://ex.org/color>         <http://ex.org/black>         <http://ex.org/Y> .
_:o-95                  <http://ex.org/model>         <http://ex.org/Coupe>         <http://ex.org/Y> .
<http://ex.org/X>       <http://nng.io/graph>         _:o-96                        <http://ex.org/Y> .
_:o-96                  <http://ex.org/source>        <http://ex.org/Denis>         <http://ex.org/Y> .
<http://ex.org/Z>       <http://ex.org/type>          <http://ex.org/FirstCarEvent> <http://ex.org/Bob> .
<http://ex.org/Z>       <http://ex.org/source>        <http://ex.org/GreenDiary>    <http://ex.org/Bob> .
<http://ex.org/Z>       <http://ex.org/date>          <http://ex.org/10_12_08>      <http://ex.org/Bob> .
```




### Superman

The notorious [Superman](https://www.w3.org/2001/12/attributions/#superman) problem can be addressed as an application of graph literals, for example using the proposed syntactic sugar for `nng:Record`s (asserted, but referentially opaque types):
```turtle
[] {" :LoisLane :loves :Superman . "} .
```

Even a much more precise variant via a [term literal](citationSemantics.md) is thinkable:
```turtle
:LoisLane :loves []{":Superman"} .
```
Here only the reference to Superman himself is referentially opaque - no need to apply the same mechanism to Lois Lane or the concept of love. However, term literals are still "at risk".  
An already available alternative would be to annotate the object in the relation with the intended interpretation.
```turtle
:S { :LoisLane :loves :Superman .
      THIS nng:range [ :hasLexicalRepresentation ":Superman"^^xsd:string ] }
```
That of course can't prevent undesired entailments, but it might still prove helpful in practice.


### Related Approaches

#### RDFn
Examples for RDFn stress the approach's virtues w.r.t. to its resilience against updates and change. Nested graphs provide these indeed very desirable properties as well.
The following example adds a second AliceBuysCar event, and adds detail to the first, without changing the data topology or requiring a re-write of queries:
```turtle
:Y {
    :X {
        :Alice :buys :Car .
    } nng:domain [ :age 20 ]
      nng:relation [ :payment :Cash ;
                     :purpose :JoyRiding ] ;
      nng:range [ :color :black ;
                  :model :Coupe ] ; 
                  nng:Interpretation ;       # disambiguating identification
      :source :Denis .
    :W {
        :V {
            :Alice :buys :Car .
        } nng:domain [ :age 28 ] ;
          :source :Eve .
    } :todo :AddDetail .                    # add detail, then remove this nesting
}                                           # without changing the data topology
```

#### OneGraph
The [OneGraph](https://www.semantic-web-journal.net/system/files/swj3273.pdf) paper in Section 3.1 discusses problems related to the type/token distinction. Annotations on types suffer from unclear belonging and dangling link problems when the same statement occurs multiple times (or rather: is annotated multiple times in different ways.

The following example records two different sources for the statement that Alice knows Bob. Since both annotations are comprised of multiple parts it is impossible to attach them all to one statement (type), as e.g. in this case source and date would be intermixed. A sound solution requires to either create an occurrence identifier for each annotation, or - in case that step was omitted with the first annotation - a re-modelling of existing data or a 'raggy' annotation structure, sometimes with occurrence identifier, sometimes without. NNG avoids this problem because it always creates a token identifier. 
```turtle
:sid_1 { :Alice :knows :Bob . }
    :since 2020 ;
    :statedBy :NYTimes .
:sid_2 { :Alice :knows :Bob . }
    :since 2021 ;
    :statedBy :TheGuardian .
```
The problem gets even more complex if an annotation occurrence aims to annotate the type without asserting it. NNG would model this via graph literals, whereas RDF-star provides no immediate solution.
```turtle
[] { :Bob :cooks :Good .}
    :source :Denis .        # Denis likes Bob's cooking .
[] "{ :Bob :cooks :Good .}"
    :source :Daisy .        # Daisy at least wouldn't want to recommend him.
```
RDF-star would assert the statement and add two triple terms with the respective annotations. It would however remain unclear that Daisy did never intend to actually assert the statement. Even worse, it would require elaborate bookkeeping to ensure that in case Denis annotation is removed, also the asserted triple is removed - or, respectively, that it remains if only Daisy's annotation is deleted. 

The token-based approach of NNG provides a basis on which these problems can't occur.

#### Labelled Property Graph (LPG)
LPGs employ a modelling style that differentiates between two kinds of relations: attribute relations that describe objects, and object relations that describe relations between objects. This has some similarity to the Descriptions and Situations (DnS) pattern described above.
NNGs can help capture the LPG style of modelling in RDF by concentrating object descriptions in nested graphs. 

#### N-Ary Relations
N-ary relations have a tendency to get rather un-wieldy, branching out and providing the unfamiliar user with little help to find beginning, center and end. Ontology design patterns optimized for OWL reasoning are a notorious example, but any mildly complex piece of information will quickly suffer from how little structure and boundaries RDF provides beyond graphs and lists. Nested graphs can help to structure information into easily recognizable entities and still provide all the flexibility of the underlying graph formalism.  

#### Singleton Properties
With NNG the core of an annotated relation - its unannotated form - is front and center. This provides a distinct usability advantage over singleton properties approach. Singleton properties do indeed provide a semantically very sound alternative to NNG, but suffer from the lack of support for graphs and the fact that they make the relation type hard to identify.

#### RDF-star 
Repeating an example from the [introduction](introexample.md):

```turtle
:X {
    :Alice :buys :Car .
} 
    nng:domain [ :age 20 ] ;
    nng:range [ :color :black ;
                :model :Coupe ] ;
    :payment :Cash ;
    :purpose :JoyRiding ;
    :source :Denis .
```

A sloppy mapping to RDF-star:

```turtle
:Alice :buys :Car .
<< :Alice :buys :Car >> 
    rdf-star:hasOccurrence :X .
:X  nng:domain [ :age 20 ] ;
    nng:range [ :color :black ;
                :model :Coupe ] ;
    :payment :Cash ;
    :purpose :JoyRiding ;
    :source :Denis .
```

An exact mapping:
```turtle
:Alice_1 :buys_1 :Car_1 .
:Alice_1 rdf:type :Alice ;
    :age 20 .
<< :Alice_1 :buys :Car_1 >> :source Denis .
<< :Alice_1 rdf:type :Alice >> :source Denis .
<< :Alice_1 :age 20 >> :source Denis .
:buys_1 rdfs:subPropertyOf :buys ;
    :payment :Cash ;
    :purpose :JoyRiding .
<< :buys_1 rdfs:subPropertyOf :buys  >> :source Denis .
<< :buys_1 :payment :Cash >> :source Denis .
<< :buys_1 :purpose :JoyRiding  >> :source Denis .
:Car_1 rdf:type :Car ;
    :color :Black ;
    :model :Coupe .
<< :Car_1 rdf:type :Car >> :source Denis .
<< :Car_1 :color :Black >> :source Denis .
<< :Car_1 :model :Coupe >> :source Denis .
```
Imagine what happens with a second level of nesting or even the TEP mechanism.


### Graph Literals
Graph literals provide an elegant solution to some hard problems.

#### Reports - literals as un-asserted transparent types
(what RDF standard reification is popularly misused to represent)
```turtle
:Bob :says [] "{ :Moon :madeOf :Cheese . }" .

                 # " ... " indicate un-assertedness
                 # { ... } indicate referential transparency
```
Less syntactic sugar, same meaning:
```turtle
:Bob :says [ nng:reports ":Moon :madeOf :Cheese ."^^nng:ttl ]
```

#### Warrants, Versioning, Verifiable Credentials, Explainable AI
Graph literals provide an easy way to document RDF state verbatim in the most unambiguous way.
```turtle
:Y {
    :X {
        :Alice :buys :Car .
    } nng:domain [ :age 20 ]
      nng:relation [ :payment :Cash ;
                     :purpose :JoyRiding ] ;
      nng:range [ :color :black ;
                  :model :Coupe ] ;
      :source :Denis .
      nng:statedAs ":X {                    # documenting the original source
                        :Alice :buys :Car .
                    } nng:domain [ :age 20 ]
                      nng:relation [ :payment :Cash ;
                                     :purpose :JoyRiding ] ;
                      nng:range [ :color :black ;
                                  :model :Coupe ] ;
                      :source :Denis ."^^nng:ttl .
}
```

#### Reasoning on Graphs
Graph literals provide a clear distinction between an abstract graph - as a literal - and its application. Reasoning over abstract graphs can be performed on literal types, saving it from the ambiguities of graph instantiation in practice. This effectively introduces a level of indirection that makes the distinction between the two realms explicit, but also links them explicitly - to the benefit of both.

Thereby graph literals provide the basis to e.g. support rule-based reasoning with Notation3 formulas in standard RDF, especially when using quotes. Likewise they might be useful in the context of the [RDF surfaces](https://arxiv.org/abs/2305.08476) project that aims to facilitate FOL reasoning on the Semantic Web.