# Examples


## [WG Use Cases](https://github.com/w3c/rdf-ucr/wiki/Summary)


### [CIDOC-CRM](https://github.com/w3c/rdf-ucr/wiki/RDF-star-for-CIDOC-CRM-events)

A short example of how the CIDOC-CRM use case can be encoded with nested named graphs, modelled after Niklas' example on the [mailinglist](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Nov/0026.html).

```turtle
ex:Ioannes_68 a crm:E21_Person , ex:Gender_Eunuch ;
    rdfs:label "John the Orphanotrophos" .

<#assignment-1> { ex:Ioannes_68 a ex:Gender_Eunuch }
	a crm:E17_Type_Assignment ;
	crm:P14_carried_out_by ex:Paphlagonian_family ;
	rdfs:label "Castration gender assignment" .

[] { ex:Ioannes_68 a ex:Gender_Male }
    a crm:E17_Type_Assignment ;
    crm:P14_carried_out_by ex:emperor ;
    crm:P182_inverse_starts_after_or_with_the_end_of <#assignment-1> ;
    rdfs:label "Gender assignment by decree" .

[] { ex:Ioannes_68 a ex:Gender_Male }
    a crm:E17_Type_Assignment ;
    crm:P14_carried_out_by ex:Paphlagonian_family ;
    crm:P183_ends_before_the_start_of <#assignment-1> ;
    rdfs:label "Birth gender assignment" .

```

### [Superman](https://www.w3.org/2001/12/attributions/#superman) 

The notorious Superman problem can be addressed as an application of graph literals, for example using the proposed syntactic sugar for `nng:Record`s (asserted, but referentially opaque types):
```turtle
[] {":LoisLane :loves :Superman"} .
```

Even a much more precise variant via a [term literal](citationSemantics.md) is thinkable:
```turtle
:LoisLane :loves []{":Superman"} .
```
Here only the reference to Superman himself is referentially opaque - no need to apply the same mechanism to Lois Lane or the concept of love. However, term literals are still "at risk".



## Other Examples

### Descriptions and Situations (DnS) shortcut relations

Descriptions and Situations (DnS) is an ontology design patterns that distinguishes the description of objects and the relations between these objects - not un-similar to the way Labeled Property Graphs model information. A particularly interesting concept is that of a "shortcut relation": a basic relation that captures the essential information hidden in a much more complex n-ary relation.  
In the example below the central piece of information is that Alice visits the ISWC conference. That statement is annotated with links to background information like a detailed travel schedule and what she plans to do at the conference. 


```turtle
:T1 {
    :Alice :travelsTo :ISWC23 .
    THIS nng:predicate [ rdfs:seeAlso :S1 ,    # THIS graph self reference
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
This example combines several orthogonal dimensions of annotation: application specific dimensions and unsound graph naming practices, administrative annotations intermixed with qualifying annotations.
```turtle
:Bob :source :Laptop ;
     :status :Unredacted ;
     :visibility :Private .

:Bob {
    :Z {
        :Y {
            :X {
                :Alice :buys :Car .
            } 
            nng:subject [ :age 20 ] ;
            nng:predicate [ :payment :Cash ;
                            :purpose :JoyRiding ] ;
            nng:object [ :color :black ;
                         :model :Coupe ] ;
            nng:graph [ :source :Denis ] .
        }
    } :FirstCarEvent ;
      :source :GreenDiary ;
      :date :10_12_08 .
}
```
Imagine adding more levels of nesting for different accounts of Alice buying her first car,
eg her parents helping fund it,
the insurance company having yet a different view, etc. Nothing breaks, it's just adding more layers of nesting.


## TODO

We hope to provide more examples soon.

### Related Approaches

#### RDFn
Souri Das' examples stress the RDFn approach's virtues w.r.t. to resilience against updates and change. We think that nested graphs provide these very desirable properties as well.

#### OneGraph
The OneGraph paper discusses a problem related to the type/token distinction. Annotations on types suffer from dangling link problems and unclear belonging when multiple occurrences have been annotated and some of them get removed from the data. We believe that our token-based approach provides a robust basis in which this problem can't occur.

#### Labelled Property Graph 
Object attributes and relations between objects

#### N-Ary Relations
N-ary relations have a tendency to get rather un-wieldy. Branching out requires to change existing statements. NNG can help with both.

#### Singleton Properties
With NNG the core of an annotated relation, its unannotated form, is front and center, providing a distinct usability advantage over the semantically very sound singleton properties approach.


### Graph Literals
Graph literals provide an elegant solution to some hard problems.

#### RDF standard reification
Graph literals are both more succinct and more flexible.

#### Notation3 formulas
We hope that graph literals provide everything needed to properly support N3 formulas in standard RDF, but we await a comment from the experts :)

#### Warrants, Versioning, Verifiable Credentials, Explainable AI
Graph literals provide an easy way to document RDF state verbatim in the most unambiguous way.

#### Reasoning on Graphs
Graph literals provide a clear distinction between an abstract graph - as a literal - and its application. Reasoning over abstract graphs can be performed on literal types, saving it from the ambiguities of graph instantiation in practice. This effectively introduces a level of indirection that makes the distinction between the two realms explicit, but also links them explicitly - to the benefit of both.
