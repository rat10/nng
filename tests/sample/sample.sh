#! /bin/bash

# import/query the sample dataset

set -e
if [[ -z $STORE_HOST ]]; then source ../define.sh; fi
TRANSCRIPT_OUTPUT=`basename ${0} .sh`.txt
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

curl_clear_repository_content

cat >> $TRANSCRIPT_OUTPUT <<EOF
import simplified nng dataset.
- vocabulary is limited to the defined terms
- statement terms are anonymous
EOF


echo '
import subject graph dataset
' >> $TRANSCRIPT_OUTPUT
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix nng: <http://nested-named-graph.org/> .

:G1 {
   :G2 {
       :Alice :buys :Car .
       :G2 nng:domain [ :age 20 ] ;          
           nng:relation [ :payment :Cash ] ; 
           nng:range :Interpretation ,    
                     [ :color :black ].  
   } :source :Denis ;                        
     :purpose :JoyRiding .                   
   :G3 {    
       [] {                                  
           :Alice :buys :Car .               
           THIS nng:domain [ :age 28 ] .
       }
    } :source :Eve .    
} :todo { :a :b { :d :e :f . } . } .
:G6 {  {:q :r :s .} {:u :v :w .} { :x :y :z .}  .}
EOF


echo >> $TRANSCRIPT_OUTPUT
curl_graph_store_get >> $TRANSCRIPT_OUTPUT


 
