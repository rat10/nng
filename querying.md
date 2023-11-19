# Querying

```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

> PLEASE EXCUSE THE CHAOS AROUND HERE !!!


> a detailed discussion of querying, including 
>
> - display of annotations (as "there is more..." or similar)
> - scoping queries to nested graphs (recursively following their nested graphs)
> - querying included graph literals
> - displaying results with non-standard semantics, e.g. unasserted, opaque, etc

```



A publicly accessible prototype implementation is available at 
https://observablehq.com/@datagenous/nested-named-graphs.

## Basic Design

### entailment process
BGP matching is defined as an entailment process.
Simple entailment is defined on the basis of (and is equivalent to) same term equality.
entailment rules of graph transclusion
- we define relations
- and how they determine target graph construction

### terminology
the context graph is the initial target graph
  as defined in FROM and FROM NAMED
the target graph is the graph to match BGP against
  it can change over the course of a query


### Depth First vs Breadth First Search of Nested Graphs
 
[Olaf's formalization](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Nov/0027.html ) can be understood as the equivalent of a depth first search. Results for nested BGPs are to be expected, but not exactly intuitive.
One way to work around that is to go breadth first.


### querying with context
  to return results with context (for each result the graph it was found in)
    eg `:G1 :Car` instead of just `:Car`
  one has to retain the name of the source graph
  from which a matched graph pattern originates
  that requires the target graph to become a QUAD graph


## inherited annotations

how to query inherited annotations on nested graphs?


## Extensions to SPARQL

### FROM NAMED|ALL|DEFAULT
SPARQL leaves it unspecified if the context graph is the default graph or the union of all named graphs. This needs a solution.

### WITH nng:Literal|nng:quote|nng:Report|nng:Record
We introduce graph literals as a queryable datatype to implement non-default semantics. However, we need to control how matches against these graph literals get included in query results. By default they are not included. They can however be matched against by
- either calling them in a WITH clause (WITH nng:Literal|nng:quote|nng:Report|nng:Record)
- or by matching them explicitly in a query, using the appropriate inclusion property

TODO examples

### CONTEXT
expressions
- 'SELECT [?g]?a …' to explicitly demand for the context of term
- 'with CONTEXT' to ask for all contexts
- 'WHERE [?g]{…' as you proposed

SELECT result sets as TSV
	[:ng_a]:a1 :b2 :c3 [:ng_d]:d4 :e5



### do we always union?
  if we query for "FROM :Alice" then every graph transcluded into :Alice becomes part of the target graph as well (it is "union-ed" into the target graph)
  we consider it sensible to union but it's not mandatory

### union vs merge of blank nodes
what are the consequences for blank graphs if we merge?
what strategy do we recommend?
what may happen to other strategies wrt blank node merging?



## Result Formats



## Querying Nested Graphs

### querying as usual

```sparql
SELECT *
WHERE ?g { ?s ?p ?o }
```

### querying along nesting paths
querying for an annotation on a nesting graph or any graph it is nested in

```sparql
SELECT *
WHERE ?g { ?s ?p ?o }
      ?g annotated* ?q
```

### querying for a report



## The current implementation exhibits (at least) two idiosyncrasies:

- it provides no means to bind the actual graph which comprises a matched statement. To do so will require BGP processing to include quad statement patterns
- a query which provides as its matching dataset description an explicit list of graphs will match a BGP against a single effective graph which is the closure of all nested graphs at those roots, rather than computing a distinct effective graph from each root graph.

a query for a BGP over all graphs will find it in any graph, also nested ones. as olaf's formalization illustrates it finds the same BGP again per nesting graph, not only in the innermost graph containing it. that is counterintuitive. what to do about it?






## Querying Included Literals

We have to differentiate between 
- regular RDF data and data included from literals.
- data *in* graph literals and data included *from* graph literals with special semantics.
- data with semantics defining it as asserted or un-asserted data.


A query MUST NOT return results *in* RDF literals or *included with un-asserted semantics* from RDF literals if not explicitly asked for (to prevent accidental confusion of asserted and un-asserted data).  
This is guaranteed by the need to use specific keywords in a `WITH` clause to include literals in the context graph of a query. 

A query MUST return RDF literals *included with asserted semantics* and it MUST annotate the returned data with those semantics (because asserted data has to be visible, but its specific semantics have to be visible too).   
[TODO] this is not yet guaranteed, as it requires some modification to the query execution engine. Those modifications however will be beneficial to all queries on nested graphs, not just such including graphs with special semantics.


Explicitly asking for literal data with un-asserted semantics can be performed in two ways: either use a WITH modifier to the query or explicitly ask for the content of a literal.
Any query asking specifically for data from a literal will get those results without having to select the literal type in a WITH clause.
A query using the 'WITH' modifier will include results from all literals of that type:
- LITERAL will include all ":s :p :o"^^nng:GraphLiteral and ":s"^^nng:TermLiteral literals, included or not
- INCLUDED will include all included literals, asserted and un-asserted, but not their LITERAL source
- REPORT will include all unasserted transparent types

Annotating the returned data with semantics is performed in a similar way as when authoring. However, asserted terms are not put in quotes:
- a term in a result set is encoded as a term literal, e.g. [QUOTE]:Superman, [REPORT]":Superman"
- a graph in a CONSTRUCT result is encoded as a graph term, e.g. [QUOTE]{:s :p :o}, [REPORT]":s :p :o"

[TODO] no quotes around asserted literals - is that a good idea? and feasible?

Just to clarify: graph literals that are included without semantics modifiers have regular RDF semantics and when queried the results are displayed like regular RDF data - because that's what they are - without any prepended semantics modifier.

PROBLEM: how will the query engine know that some semantics is asserted or un-asserted? Will it have t look up the semantics' definition on the web?

<!--

Querying nested graph literals requires some extra arrangements: query engines should support querying these quotes, but must return results in the same syntax: as quoted graph literals. 

In a TSV/CSV query result set a value returned from an unasserted statement has to be rendered as a singleton unasserted term, e.g. `{":a"}`. Note that we can by default omit the naming part `[]`, but it will be added if the query explicitly asks for it. 

> [TODO] To ensure that unasserted values are not accidentally returned, a special `with UNASSERTED` parameter could be provided in the query. However, putting the query result in quotes might be just as effective and less troublesome. The opposite approach, a parameter `without UNASSERTED` that suppresses unasserted results on demand might also be an option. TBD

-->

### Example
```turtle
prefix : <http://ex.org/>
prefix nng: <http://rat.io/nng/>

:X nng:includes ":Alice :likes :Skiing"^^nng:GraphLiteral .
:Bob :says ":Moon :madeOf :Cheese"^^nng:GraphLiteral .
:Alice :said ":s :p :o. :a :b :c"^^nng:GraphLiteral .
[nng:name :Y, nng:semantics QUOTE]":ThisGraph a :Quote" .
:LoisLane :loves [QUOTE]":Superman", :Skiing, [REPORT]":ClarkKent" .
:Kid :loves [REPORT]":Superman" .
:Carol :claims {":Denis :goes :Swimming"} .
:Y {:Some :dubious :Thing}
:ClarkKent owl:sameAs :Superman .
:ClarkKent :loves :LoisLane .
```
### what to expect without WITH clause or explicit addressing
```sparql
SELECT ?s
WHERE  { ?s ?p :Superman }
```
here i would like the result to include  
- :LoisLane   
because she loves the opaque (but asserted) version of :Superman  
but not 
- :Kid  
because it loves an unasserted comic figure (poor kid) 

```sparql
SELECT ?o
WHERE { :LoisLane :loves ?o }
```
here i would like to see
- [QUOTE]:Superman
- :Skiing
but not 
- [REPORT]":ClarkKent"

```sparql
SELECT ?o
WHERE { :moon ?p ?o}
```
here i would like to see
- nothing
because the respective candidate is a literal

### what to expect with WITH clause

Query modifiers are introduced by a 'WITH' clause and use the provided semantics identifiers, e.g. LITERAL, RECORD, REPORT, OPAQUE:
```sparql
SELECT ?s 
WHERE  { ?s ?p :Superman }
WITH   REPORT
```
here i would like to see
- :LoisLane 
- :Kid       
because she loves the opaque (but asserted) version of :Superman  
and the kid loves the reported Superman

```sparql
SELECT ?o
WHERE { :LoisLane :loves ?o }
WITH   REPORT
```
here i would like to see
-  [QUOTE]:Superman (no quotes around this IRI because it's asserted)
- :Skiing
- [REPORT]":ClarkKent"

```sparql
SELECT ?o
WHERE { :moon ?p ?o}
WITH LITERAL
```
here i would like to see
-  [LITERAL]":Cheese"
because the respective candidate is a literal


[TODO]   what if also the name of the nested graph that this value originated from has to be recorded? then the syntax becomes quite convoluted.
            


### what to expect with Explicit Addressing

If a query addresses a graph literal explicitly, its results are rendered like regular RDF.
```turtle
:Alice :said ":s :p :o. :a :b :c"^^nng:GraphLiteral .
```
[HELP]  i'd like to address the graph literal
    but how do i do that?
       maybe i need the following little helpers:
```turtle
nng:hasSource rdfs:range nng:GraphLiteral .
[]{:a :b :c} nng:hasSource ":A :b :C"^^nng:Graph

# select all objects in the literal
# assuming that graph literals are graphs too (ie referenced per graph keyword) ???
SELECT ?so
WHERE ?a nng:hasSource ?src
        graph ?src { ?ss ?sp ?so }
```


### what to expect when CONSTRUCTing results

Currently that's future work, as result sets are the more immediate need. 
However, I expect that constructed graphs will also contain
    - terms from nested graphs with special semantics or 
    - nested terms with special semantics
so it will again be necessary to be able to encode semantics per term. In the case where  whole statements have the same semantics they have to be encoded as nested graphs.


