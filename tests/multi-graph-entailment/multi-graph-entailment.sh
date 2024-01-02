#! /bin/bash

# import/query examples which adopt the multi-graph cases introduced by pfps.
#
#   https://lists.w3.org/Archives/Public/public-rdf-star-wg/2023Oct/0108.html
#
# Q/E? is taken to mean query/entailment == ASK


set -e
if [[ -z $STORE_HOST ]]; then source ../define.sh; fi
TRANSCRIPT_OUTPUT=multi-graph-entailment.txt
truncate -s 0 $TRANSCRIPT_OUTPUT

function curl_import () {
  tee -a $TRANSCRIPT_OUTPUT \
  | curl_graph_store_update -H "Content-Type: application/trig" -w "%{http_code}\n" -o  ${ECHO_OUTPUT} \
  | test_post_success
}

function curl_query () {
  tee -a $TRANSCRIPT_OUTPUT | cat > $QUERY_INPUT ;
  echo >> $TRANSCRIPT_OUTPUT ;
  curl -s -X POST https://${STORE_HOST}/seg/test/sparql \
    -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-query+sse" \
    -u ":${STORE_TOKEN}" \
    --data-binary @$QUERY_INPUT \
   >> $TRANSCRIPT_OUTPUT
  echo >> $TRANSCRIPT_OUTPUT ;
  echo >> $TRANSCRIPT_OUTPUT ;
  curl -s -X POST https://${STORE_HOST}/seg/test/sparql \
    -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
    -u ":${STORE_TOKEN}" \
    --data-binary @$QUERY_INPUT \
    | tee -a $TRANSCRIPT_OUTPUT > $RESULT_OUTPUT
  echo >> $TRANSCRIPT_OUTPUT
}


# { :Linköping a :City } in one graph
#
# this also is expressed either as a statement with a subject graph or as                                                                                                                                    
# an nested graph with annotations.
# the representation is identical. 

# the statement requires no explict dataset definition.
# it is present in the default graph.
# the annotated graph
#

cat >> $TRANSCRIPT_OUTPUT <<EOF

{ :Linköping a :City ; 
             :in :Sweden . } :source :nyt .
 Q/E?
{ :Linköping a :City . } :source :nyt . 
EOF

curl_clear_repository_content ;

echo '
import subject graph dataset
' >> $TRANSCRIPT_OUTPUT
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
 { :Linköping a :City ; :in :Sweden . } :source :nyt .
EOF

echo >> $TRANSCRIPT_OUTPUT
curl_graph_store_get >> $TRANSCRIPT_OUTPUT

echo '
subject graph query
'>> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City . } :source :nyt .
}
EOF
fgrep -q -i true $RESULT_OUTPUT

echo >> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City ; :in :Sweden . } :source :nyt .
}
EOF
fgrep -q -i true $RESULT_OUTPUT

echo '
embedded graph query
'>> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :Linköping a :City ; :in :Sweden . } .
}
EOF
fgrep -q -i true $RESULT_OUTPUT



# { :cat :is :alive , :dead }
#
# this also is expressed either as a statement with a subject graph or as                                                                                                                                    
# an nested graph with annotations.
# the representation is identical.              
#
# as statement with a subject graph, it requires no explict dataset definition.
# the query tests whether there is any graph present as the subject of statement
# in the default graph, where the statement asserts that logical status.
# the test is not affected be the presence of the additional :is assertion.
#
# as a nested graph, it requires no explict dataset definition, so long as
# we continue to nested the toplevel graphs in the default graph
# the query tests whether there is any nested graph embedded as a subject and annotated with
# that logical status.
#
# the test is not affected be the presence of the additional :is assertion.
# a pattern like { :cat :is :alive ; :is :old . } woudl yield false

cat >> $TRANSCRIPT_OUTPUT <<EOF

{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
Q/E?
{ :cat :is :alive . } :logicalStatus :inconsistent .
EOF

curl_clear_repository_content

echo '
import subject graph dataset
' >> $TRANSCRIPT_OUTPUT
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
EOF

echo >> $TRANSCRIPT_OUTPUT
curl_graph_store_get >> $TRANSCRIPT_OUTPUT
 
echo '
subject graph query' >> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
  { :cat :is :alive . } :logicalStatus :inconsistent .
}
EOF
fgrep -q -i true $RESULT_OUTPUT


curl_clear_repository_content ;

echo '
import nested graph dataset
'  >> $TRANSCRIPT_OUTPUT
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
[]{ :cat :is :alive , :dead . } :logicalStatus :inconsistent .
EOF

echo >> $TRANSCRIPT_OUTPUT
curl_graph_store_get >> $TRANSCRIPT_OUTPUT

echo '
nested = subject graph query' >> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
 { :cat :is :alive . } :logicalStatus :inconsistent .
}
EOF
fgrep -q -i true $RESULT_OUTPUT

echo '
overconstrained query' >> $TRANSCRIPT_OUTPUT
curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
ask
where {
{ :cat :is :alive; :is :old . } :logicalStatus :inconsistent .
}
EOF
fgrep -q -i false $RESULT_OUTPUT




