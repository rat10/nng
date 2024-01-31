#! /bin/bash

# simple bill of materials use case
# the a model represents each entity in a bom treee in its own graph, links
# the graphs via object/subject identities, thereby representing the bom
# structure, and annotates individual property assertions either as
# nested, recorded or reported statements, or as a combination of asserted and
# quoted statements.
#


set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi
export TRANSCRIPT_OUTPUT=bom.txt
truncate -s 0 $TRANSCRIPT_OUTPUT

function curl_import () {
  tee -a $TRANSCRIPT_OUTPUT \
  | tee $ECHO_OUTPUT \
  | curl_graph_store_update -H "Content-Type: application/trig" -w "%{http_code}\n" -o  ${ECHO_OUTPUT} \
  | test_post_success
}

function curl_query () {
  tee -a $TRANSCRIPT_OUTPUT | tee $ECHO_OUTPUT | cat > $QUERY_INPUT ;
  echo "" >> $TRANSCRIPT_OUTPUT ;
  curl -s -X POST https://${STORE_HOST}/seg/test/sparql \
    -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-query+sse" \
    -u ":${STORE_TOKEN}" \
    --data-binary @$QUERY_INPUT \
   >> $TRANSCRIPT_OUTPUT
  echo "" >> $TRANSCRIPT_OUTPUT ;
  echo "" >> $TRANSCRIPT_OUTPUT ;
  echo "https://${STORE_HOST}/seg/test/sparql?$@"
  curl -s -X POST "https://${STORE_HOST}/seg/test/sparql?$@" \
    -H "Content-Type: application/sparql-query" -H "Accept: text/csv" \
    -u ":${STORE_TOKEN}" \
    --data-binary @$QUERY_INPUT \
    | tee $ECHO_OUTPUT | tee -a $TRANSCRIPT_OUTPUT > $RESULT_OUTPUT
  echo "" >> $TRANSCRIPT_OUTPUT
}

function comment () {
 echo " " | tee -a $TRANSCRIPT_OUTPUT > $ECHO_OUTPUT
 echo " - - -" | tee -a $TRANSCRIPT_OUTPUT > $ECHO_OUTPUT
 echo $@ | tee -a $TRANSCRIPT_OUTPUT > $ECHO_OUTPUT
 echo " - - -" | tee -a $TRANSCRIPT_OUTPUT > $ECHO_OUTPUT
}


comment 'the dataset is a transliterated construct result'

if [[ "$1" != "no_import" ]]
then

  curl_clear_repository_content ;

  curl_import < bom-base.trig
fi


comment bom basic dataset content
curl_graph_store_get | tee $ECHO_OUTPUT >> $TRANSCRIPT_OUTPUT

curl_query <<EOF
prefix : <http://example.org/> 
select ?s ?o
from <urn:dydra:all>
where { ?s <http://data.com/def/bom>* ?o }
EOF


if [[ "$1" != "no_import" ]]
then

  curl_clear_repository_content ;

  curl_import < bom-annotated.trig
fi
comment bom annotated dataset content
curl_graph_store_get | tee $ECHO_OUTPUT >> $TRANSCRIPT_OUTPUT


curl_query <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?s ?o
from nng:AssertedGraph
where {
  ?s <http://data.com/def/revision> ?o.
}
EOF


curl_query  <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?s ?p ?o
from included nng:AssertedGraph
where {
  { graph <http://data.com/graph/cesf/cesf41> { ?s ?p ?o. } }
}
EOF

