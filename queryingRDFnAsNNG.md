# RDFn example in NNG

Souripriya Das  posted an [example](https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Dec/0030.html) showcasing how RDFn can annotate triples without invalidating pre-existing queries. The following explores how NNG handle that problem.

Tested on the [NNG Workbook](https://observablehq.com/@datagenous/nested-named-graphs) on 13.12.2023

## VARIANT 1
The annotation is expected to be located in the same graph as the assertion.

### NNG
```turtle 
prefix : <http://ex.org/>
:term1 {
    :Cleveland :servedAs :POTUS .
    THIS :from 1885 ;
         :to 1889 .
} .  # closing dot!
:term2 {
    :Cleveland :servedAs :POTUS .
    THIS :from 1893 ;
         :to 1897 .
} .
```
### SPARQL
```sparql
prefix : <http://ex.org/>
select
     ?graph ?who ?start ?end 
where {
    graph ?graph  { 
        ?who    :servedAs :POTUS .
        ?graph  :from   ?start ;
                :to     ?end .
    }
}
```
### RESULT
```turtle
[
  [
    "graph",
    "who",
    "start",
    "end"
  ],
  [
    "http://ex.org/term1",
    "http://ex.org/Cleveland",
    1885,
    1889
  ],
  [
    "http://ex.org/term2",
    "http://ex.org/Cleveland",
    1893,
    1897
  ]
] 
```

## VARIANT 2
The annotation can be located anywhere: in the same graph, in the default graph or even doubly nested within another graph.

### NNG
```turtle
prefix : <http://ex.org/>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
:term1 {
    :Cleveland :servedAs :POTUS .
    THIS :from 1885 ; :to 1889 .
} . 
:term2 {
    :Cleveland :servedAs :POTUS .
    :noTerm3 {
        :term3 :from rdf:nil ; :to rdf:nil .
    } .
} .
:term2 :from 1893 ; :to 1897 .
:term3 {
    :Cleveland :servedAs :POTUS .
} .
```

### SPARQL
```sparql
prefix : <http://ex.org/>
prefix nng: <http://nested-named-graph.org/>
select
     ?who ?graph ?start ?end ?source
from named all
where {
    graph ?graph { ?who :servedAs :POTUS . } 
    graph ?source {  ?graph  :from ?start ; :to ?end .} 
}
```
### RESULT
```turtle
[
  [
    "who",
    "graph",
    "start",
    "end",
    "source"
  ],
  [
    "http://ex.org/Cleveland",
    "http://ex.org/term1",
    1885,
    1889,
    "http://ex.org/term1"
  ],
  [
    "http://ex.org/Cleveland",
    "http://ex.org/term2",
    1893,
    1897,
    "urn:dydra:default"
  ],
  [
    "http://ex.org/Cleveland",
    "http://ex.org/term3",
    "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil",
    "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil",
    "http://ex.org/noTerm3"
  ]
] 
```
### N-QUADS
```turtle
<urn:dydra:default> <http://nested-named-graph.org/transcludes> <http://ex.org/term1> <http://nested-named-graph.org/embeddings> .
<urn:dydra:default> <http://nested-named-graph.org/transcludes> <http://ex.org/term2> <http://nested-named-graph.org/embeddings> .
<urn:dydra:default> <http://nested-named-graph.org/transcludes> <http://ex.org/term3> <http://nested-named-graph.org/embeddings> .
<http://ex.org/term2> <http://nested-named-graph.org/transcludes> <http://ex.org/noTerm3> <http://nested-named-graph.org/embeddings> .
<http://ex.org/term1> <http://ex.org/to> "1889"^^<http://www.w3.org/2001/XMLSchema#integer> <http://ex.org/term1> .
<http://ex.org/term1> <http://ex.org/from> "1885"^^<http://www.w3.org/2001/XMLSchema#integer> <http://ex.org/term1> .
<http://ex.org/Cleveland> <http://ex.org/servedAs> <http://ex.org/POTUS> <http://ex.org/term1> .
<http://ex.org/Cleveland> <http://ex.org/servedAs> <http://ex.org/POTUS> <http://ex.org/term2> .
<http://ex.org/Cleveland> <http://ex.org/servedAs> <http://ex.org/POTUS> <http://ex.org/term3> .
<http://ex.org/term3> <http://ex.org/to> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://ex.org/noTerm3> .
<http://ex.org/term3> <http://ex.org/from> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://ex.org/noTerm3> .
<http://ex.org/term2> <http://ex.org/to> "1897"^^<http://www.w3.org/2001/XMLSchema#integer> .
<http://ex.org/term2> <http://ex.org/from> "1893"^^<http://www.w3.org/2001/XMLSchema#integer> .
```