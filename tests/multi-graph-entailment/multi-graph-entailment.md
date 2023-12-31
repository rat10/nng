# ###
# ###

{ :Linköping a :City ; 
             :in :Sweden . } :source :nyt .
 Q/E?
{ :Linköping a :City . } :source :nyt . 

# import subject graph dataset

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :Linköping a :City ; :in :Sweden . } :source :nyt .

<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:topgraph-22 <http://nested-named-graph.org/embeddings> .
<http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City> _:topgraph-22 .
<http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden> _:topgraph-22 .
_:topgraph-22 <http://example.org/source> <http://example.org/nyt> .

# subject graph query

# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
    { :Linköping a :City . } :source :nyt .
}

(ask (bgp (triple _:nodeFORMULA-85
                  <http://example.org/source>
                  <http://example.org/nyt>)
          (bgp (graph _:nodeFORMULA-85)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>))))

{ "head": {}, "boolean": true }

# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City ; :in :Sweden . } :source :nyt .
}

(ask (bgp (triple _:nodeFORMULA-87
                  <http://example.org/source>
                  <http://example.org/nyt>)
          (bgp (graph _:nodeFORMULA-87)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
               (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>))))

{ "head": {}, "boolean": true }


# embedded graph query

# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City ; :in :Sweden . } .
}

(ask (bgp (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
          (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>)))

{ "head": {}, "boolean": true }

# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 []{ :Linköping a :City ; :in :Sweden . } .
}

(ask (bgp (graph _:node91)
          (bgp (graph <http://nested-named-graph.org/embeddings>)
               (triple _:nodeCONTEXT-GRAPH-93
                       <http://nested-named-graph.org/transcludes>
                       _:node91))
          (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
          (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>)))

{ "head": {}, "boolean": true }

# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?g
where {
 ?g { :Linköping a :City ; :in :Sweden . } .
}

(select ?g (bgp (graph ?g)
     (bgp (graph <http://nested-named-graph.org/embeddings>)
          (triple _:nodeCONTEXT-GRAPH-98
                  <http://nested-named-graph.org/transcludes>
                  ?g))
     (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
     (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>)))

{ "head": { "vars": [ "g" ] },
   "results": {
   "bindings": [
 { "g": {"type":"bnode", "value":"topgraph-22"} } ] } }


# sparql star term query

# ###
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  << :Linköping a :City >> :source :nyt .
}

(ask (bgp (triple _:nodeGRAPH-101
                  <http://example.org/source>
                  <http://example.org/nyt>)
          (bgp (graph _:nodeGRAPH-101)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>))))

{ "head": {}, "boolean": true }


# import nested graph dataset - equivalent representation

# ###
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :Linköping a :City ; :in :Sweden . } :source :nyt .

    note
    the n-quads are teh same as for the subject graph dataset above
    because the subject graph dataset is just syntactic sugar for this one here
    leaving out the name prefix

<http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City> _:b23 .
<http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden> _:b23 .
<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:b23 <http://nested-named-graph.org/embeddings> .
<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:topgraph-22 <http://nested-named-graph.org/embeddings> .
<http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City> _:topgraph-22 .
<http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden> _:topgraph-22 .
_:b23 <http://example.org/source> <http://example.org/nyt> .
_:topgraph-22 <http://example.org/source> <http://example.org/nyt> .



# ###
# ###

{ :Linköping a :City . } :saidBy :john .
{ :Linköping :in :Sweden . } :saidBy :john .
Q/E? 
{ :Linköping a :City ; :in :Sweden . } :saidBy :john .


# two nested graphs, annotated

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :Linköping a :City . } :saidBy :john .
[]{ :Linköping :in :Sweden . } :saidBy :john .

    "from included" merges the nested graphs related to the default graph,
    but as the graph identity is no longer present, there is no relation to ":saidBy john"
    and without that a join with two graph instances fails as,
    where the identity is retained, the graphs are distinct.

[TODO]
    a query that only merges graphs that are :saidBy :John
    to preserve graph annotations
    -> needs BGPs expressing quads



# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
from included nng:NestedGraph
where {
  { :Linköping a :City ; :in :Sweden . }
}

(ask (bgp (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
          (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>)))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
from included nng:NestedGraph
where {
  { :Linköping a :City ; :in :Sweden . } :saidBy :john .
}

(ask (bgp (triple _:nodeFORMULA-105
                  <http://example.org/saidBy>
                  <http://example.org/john>)
          (bgp (graph _:nodeFORMULA-105)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
               (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>))))

{ "head": {}, "boolean": false }

    from included nng:NestedGraph
    constructs a graph containing all the statements about linköping
    but doesn't preserve annotations


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  ?g { :Linköping a :City ; :in :Sweden . }
}

(ask (bgp (graph ?g)
          (bgp (graph <http://nested-named-graph.org/embeddings>)
               (triple _:nodeCONTEXT-GRAPH-108
                       <http://nested-named-graph.org/transcludes>
                       ?g))
          (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
          (triple <http://example.org/Linköping> <http://example.org/in> <http://example.org/Sweden>)))

{ "head": {}, "boolean": false }

    because they are in different graphs
    

# the same applies as two statements with graph subjects

# ###

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :Linköping a :City . } :saidBy :john .
{ :Linköping :in :Sweden . } :saidBy :john .


# ###
# ###

{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
Q/E?
{ :cat :is :alive . } :logicalStatus :inconsistent .


# import subject graph dataset

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .

<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:topgraph-40 <http://nested-named-graph.org/embeddings> .
<http://example.org/cat> <http://example.org/is> <http://example.org/alive> _:topgraph-40 .
<http://example.org/cat> <http://example.org/is> <http://example.org/dead> _:topgraph-40 .
_:topgraph-40 <http://example.org/logicalStatus> <http://example.org/inconsistent> .


# subject graph query

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :cat :is :alive . } :logicalStatus :inconsistent .
}

(ask (bgp (triple _:nodeFORMULA-111
                  <http://example.org/logicalStatus>
                  <http://example.org/inconsistent>)
          (bgp (graph _:nodeFORMULA-111)
               (triple <http://example.org/cat> <http://example.org/is> <http://example.org/alive>))))

{ "head": {}, "boolean": true }


# import nested graph dataset

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .

<http://example.org/cat> <http://example.org/is> <http://example.org/alive> _:b41 .
<http://example.org/cat> <http://example.org/is> <http://example.org/dead> _:b41 .
<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:b41 <http://nested-named-graph.org/embeddings> .
_:b41 <http://example.org/logicalStatus> <http://example.org/inconsistent> .


# nested = subject graph query

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 { :cat :is :alive . } :logicalStatus :inconsistent .
}

(ask (bgp (triple _:nodeFORMULA-113
                  <http://example.org/logicalStatus>
                  <http://example.org/inconsistent>)
          (bgp (graph _:nodeFORMULA-113)
               (triple <http://example.org/cat> <http://example.org/is> <http://example.org/alive>))))

{ "head": {}, "boolean": true }


# over-constrained query

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
{ :cat :is :alive; :is :old . } :logicalStatus :inconsistent .
}

(ask (bgp (triple _:nodeFORMULA-115
                  <http://example.org/logicalStatus>
                  <http://example.org/inconsistent>)
          (bgp (graph _:nodeFORMULA-115)
               (triple <http://example.org/cat> <http://example.org/is> <http://example.org/alive>)
               (triple <http://example.org/cat> <http://example.org/is> <http://example.org/old>))))

{ "head": {}, "boolean": false }


# ###
# ###

:geography :truths { :Linköping a :City .
                   :City rdfs:subClassOf :Location . }
Q/E?
:geography :truths { :Linköping a :Location . }


# ###

<urn:dydra:default> <http://nested-named-graph.org/transcludes> _:termgraph-15 <http://nested-named-graph.org/embeddings> .
<http://example.org/City> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://example.org/Location> _:termgraph-15 .
<http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City> _:termgraph-15 .
<http://example.org/geography> <http://example.org/truths> _:termgraph-15 .


# import object graph dataset

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
:geography :truths { :Linköping a :City .
                     :City rdfs:subClassOf :Location . } .
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 :geography :truths { :Linköping a :City . :City rdfs:subClassOf :Location .}
}

(ask (bgp (triple <http://example.org/geography>
                  <http://example.org/truths>
                  _:nodeFORMULA-117)
          (bgp (graph _:nodeFORMULA-117)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>)
               (triple <http://example.org/City> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://example.org/Location>))))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 :geography :truths { :Linköping a :City . }
}

(ask (bgp (triple <http://example.org/geography>
                  <http://example.org/truths>
                  _:nodeFORMULA-119)
          (bgp (graph _:nodeFORMULA-119)
               (triple <http://example.org/Linköping> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/City>))))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 :geography :truths { :City rdfs:subClassOf :Location . }
}

(ask (bgp (triple <http://example.org/geography>
                  <http://example.org/truths>
                  _:nodeFORMULA-121)
          (bgp (graph _:nodeFORMULA-121)
               (triple <http://example.org/City> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://example.org/Location>))))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 :geography :truths { :Linköping a/rdfs:subClassOf :Location . }
}

(ask (bgp (triple <http://example.org/geography>
                  <http://example.org/truths>
                  _:nodeFORMULA-123)
          (bgp (graph _:nodeFORMULA-123)
               (triple <http://example.org/Linköping>
                       (<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>/<http://www.w3.org/2000/01/rdf-schema#subClassOf>)
                       <http://example.org/Location>))))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
from <urn:dydra:all>
where {
  :Linköping a/rdfs:subClassOf* :Location .
}

(ask (bgp (triple <http://example.org/Linköping>
                  (<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>/<http://www.w3.org/2000/01/rdf-schema#subClassOf>*)
                  <http://example.org/Location>)))

{ "head": {}, "boolean": true }


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 :geography :truths { :Linköping a/rdfs:subClassOf* :Location . }
}

(ask (bgp (triple <http://example.org/geography>
                  <http://example.org/truths>
                  _:nodeFORMULA-126)
          (bgp (graph _:nodeFORMULA-126)
               (triple <http://example.org/Linköping>
                       (<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>/<http://www.w3.org/2000/01/rdf-schema#subClassOf>*)
                       <http://example.org/Location>))))

{ "head": {}, "boolean": false }

    false because of an anomaly in the dydra implementation
    (it returns the wildcard (see below) instead of the last graph)


# ###

prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select *
where {
  graph ?graph { :Linköping a/rdfs:subClassOf* :Location .  }
}

(select ?graph (graph ?graph
       (bgp (triple <http://example.org/Linköping>
                    (<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>/<http://www.w3.org/2000/01/rdf-schema#subClassOf>*)
                    <http://example.org/Location>))))

{ "head": { "vars": [ "graph" ] },
   "results": {
   "bindings": [
 { "graph": {"type":"uri", "value":"urn:dydra:named"} } ] } }

