#! /bin/bash

# import/query examples which adopt the multi-graph cases introduced by pfps.
#
#   https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0108.html

set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

# Q/E? is taken to mean query/entailment == ASK



echo ":Linköping a :City in one graph" > $ECHO_OUTPUT
# this is either an annotated, nested graph or a statement with a graph as its
# subject.
# the statement requires no explict dataset definition.
# it is present in the default graph.
# the annotated graph
#
# { :Linköping a :City ; 
#            :in :Sweden . } :source :nyt .
# Q/E?
# { :Linköping a :City . } :source :nyt . 
#

# as a statement
curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :Linköping a :City ; :in :Sweden . } :source :nyt .
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City . } :source :nyt .
}
EOF

fgrep -i true $RESULTS_OUTPUT


# as an annotated anonymous graph, embedded in the default graph
curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :Linköping a :City ; :in :Sweden . } :source :nyt .
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  ?g { :Linköping a :City . } :source :nyt .
}
EOF

fgrep -i true $RESULTS_OUTPUT



echo ":cat :is :alive , :dead" > $ECHO_OUTPUT
# this is also either an annotated, nested graph or a statement with a graph as
# its subject.
#
#{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
#Q/E?
#{ :cat :is :alive . } :logicalStatus :inconsistent .
#

# as statement with a graph, it requires no explict dataset definition.
# the query tests whether there is any graph present as the subject of statement
# in the default graph, where the statement asserts that logical status.
# the test is not affected be the presence of the additional :is assertion.

curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :cat :is :alive . } :logicalStatus :inconsistent .
}
EOF

fgrep -i true $RESULTS_OUTPUT

# as a nested graph, it requires no explict dataset definition, so long as
# we continue to nested the toplevel graphs in the default graph
# the query tests whether there is any nested graph present and annotated with
# that logical status.
# the test is not affected be the presence of the additional :is assertion.
# a pattern like { :cat :is :alive ; :is :old . } woudl yield false

curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
[]{ :cat :is :alive . } :logicalStatus :inconsistent .
}
EOF

fgrep -i true $RESULTS_OUTPUT



echo ":Linköping a :City in two graphs" > $ECHO_OUTPUT
# this is yet another case which is either embedded subjects or nested graphs
# in this case, however, there are two elements.
# where it is understood to be embedded subjects, those subjects constitute
# distinct graphs, while the entailment expression specifies just one graph.
#
#{ :Linköping a :City . } :saidBy :john .
#{ :Linköping :in :Sweden . } :saidBy :john .
#Q/E? 
#{ :Linköping a :City ; :in :Sweden . } :saidBy :john .
#
# this examines the combined content of two annotated statements.
# several variant queries are possible, but is is not clear how to formulate
# one with a single subject "graph term" to match the
# dataset which includes distinct statements - especially if the dataset were
# to record different properties for the respective statements.

# first alternative : two annotated, nested graphs
curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :Linköping a :City . } :saidBy :john .
[]{ :Linköping :in :Sweden . } :saidBy :john .
EOF

# from included should merge the nested graphs related to the default graph.
# this should then join with two instances of :saidBy john
# it would not. however match something like
#    []{ :Linköping a :City ; :in :Sweden . } :saidBy :john ; :deniedBy ::william .
# as these two annotations both relate to the same subject, but that dataset annotates distinct subjects.
curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
from included nng:NestedGraph
where {
  []{ :Linköping a :City ; :in :Sweden . } :saidBy :john .
}
EOF

fgrep -i true $RESULTS_OUTPUT

# second alternative : two annotated statements
# where the datset is defined to include all nested graphs,
# both statements appear in the effective target graph and
# and the query returns true.
curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :Linköping a :City . } :saidBy :john .
{ :Linköping :in :Sweden . } :saidBy :john .
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
from included nng:NestedGraph
where {
  []{ :Linköping a :City ; :in :Sweden . } :saidBy :john .
}
EOF

fgrep -i true $RESULTS_OUTPUT



echo ":geography :truths" > $ECHO_OUTPUT
# this demonstrates that entailment rules would apply for a graph
# which is embedded as a statement object.
# where the query is reformulated to use a property path rather then to presume
# support for rdfs subclassof inference, it is a simple sparql expression.
# as the embedded graph is then the object of a statement in the default graph,
# no dataset declaration is necessary
#
#:geography :truths { :Linköping a :City .
#                   :City rdfs:subclassOf :Location . }
#Q/E?
#:geography :truths { :Linköping a :Location . }

curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/trig" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
:geography :truths { :Linköping a :City .
                     :City rdfs:subclassOf :Location . }
EOF

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  :geography :truths { :Linköping a/rdfs:subclassOf* :Location . }
}
EOF

fgrep -i true $RESULTS_OUTPUT

