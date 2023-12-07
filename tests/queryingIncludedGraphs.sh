#! /bin/bash

# import/query examples to demonstrate synthetic use cases.


set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

curl_clear_repository_content ;

curl -v -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}" \
  --data-binary @- <<EOF
@base <http://dydra.com/> .
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
prefix iana: <https://www.iana.org/assignments/media-types/application/>
prefix owl: <http://www.w3.org/2002/07/owl#>

:Bob :says ':Moon :madeOf :Cheese'^^iana:trig .
:Alice :said ':s :p :o. :a :b :c'^^iana:trig .
[ :Y nng:Quote]':ThisGraph a :Quote'^^iana:trig .
[nng:Quote]{:LoisLane :loves :Superman} .
:LoisLane :loves :Skiing  .
[nng:Report]{:LoisLane :loves :ClarkKent} .
[nng:Report]{:Kid :loves :Superman }.
:Kid :loves ':Superman' .
:Carol :claims {":Denis :goes :Swimming"} .
:Y {:Some :dubious :Thing} .
:ClarkKent owl:sameAs :Superman .
:ClarkKent :loves :LoisLane .

# :X nng:includes ':Alice :likes :Skiing'^^nng:ttl nng:embeddings.
# nng:embeddings { :X nng:includes ':Alice :likes :Skiing'^^iana:trig . }
## :LoisLane :loves [QUOTE]':Superman', :Skiing, [REPORT]':ClarkKent' .
## :Kid :loves [REPORT]':Superman' .
EOF

cat > /dev/null <<EOF

;;; the standard result, without dataset defintion, yields just the assertion in the default graph
;;; a result which includes :LoisLane would require that the qualification apply to the term,
;;; rather than the statement.
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?s ?p
WHERE  { ?s ?p :Superman }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p
http://example.org/ClarkKent,http://www.w3.org/2002/07/owl#sameAs

;;; the quoted statement in made visible with a FROM INCLUDED dataset definition
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?s ?p
FROM INCLUDED nng:Quote
WHERE  { ?s ?p :Superman }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p
http://example.org/LoisLane,http://example.org/loves
http://example.org/ClarkKent,http://www.w3.org/2002/07/owl#sameAs


;;; the situation with :LoisLane is related variously, depending
;;; on which nested graphs are included
;;; here, none
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
WHERE { :LoisLane :loves ?o }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o
http://example.org/Skiing

;;; here, quotes
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
FROM INCLUDED nng:Quote
WHERE { :LoisLane :loves ?o }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o
http://example.org/Superman
http://example.org/Skiing

;;; here reports
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
FROM INCLUDED nng:Report
WHERE { :LoisLane :loves ?o }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o
http://example.org/ClarkKent
http://example.org/Skiing

;;; here both
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
FROM INCLUDED nng:Quote
FROM INCLUDED nng:Report
WHERE { :LoisLane :loves ?o }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o
http://example.org/ClarkKent
http://example.org/Superman
http://example.org/Skiing

;;; in order that assertions about the moon be visible literal graphs must be included
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
WHERE { :Moon ?p ?o}
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o

;;; with literal graphs incorporated into the dataset, the moon is visible
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?o
FROM INCLUDED nng:GraphLiteral
WHERE { :Moon ?p ?o}
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
o
http://example.org/Cheese


;;; explicit adressing is accomplished with standard sparql
(test-sparql "
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?g ?s ?p ?o
WHERE { 
 :Alice :said ?g .
 { GRAPH ?g { ?s ?p ?o }}
}
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
g,s,p,o
_:termgraph-15,http://example.org/a,http://example.org/b,http://example.org/c
_:termgraph-15,http://example.org/s,http://example.org/p,http://example.org/o


EOF