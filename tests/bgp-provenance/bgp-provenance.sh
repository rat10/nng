#! /bin/bash

# examples which demonstrate how to extract result graph provenance.
#


set -e
if [[ -z $STORE_HOST ]]; then source ../define.sh; fi
export TRANSCRIPT_OUTPUT=bgp-provenance.txt
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
  curl -s -X POST https://${STORE_HOST}/seg/test/sparql \
    -H "Content-Type: application/sparql-query" -H "Accept: text/csv" \
    -u ":${STORE_TOKEN}" \
    --data-binary @$QUERY_INPUT \
    | tee $ECHO_OUTPUT | tee -a $TRANSCRIPT_OUTPUT > $RESULT_OUTPUT
  echo "" >> $TRANSCRIPT_OUTPUT
}

curl_clear_repository_content ;

echo '
import subject graph dataset
' >> $TRANSCRIPT_OUTPUT
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
:Alice {
   :Buying {
       { :Car1 | :Alice :buys :Car . } :subject [ :age 22 ] ; :object [ :age 12 ; :type :Sedan ; :reason :Ambition ] .
       { :Car2 | :Alice :buys :Car . } :subject [ :age 42 ] ; :object [ :age 0 ; :type :Coupe ] ; :relation [ :reason :Fun ].
   } .
   { :Loving |
       { :Band1 | :Alice :loves :SuzieQuattro . } :subject [ :age 12 ]  .
   }  :reason :Fun .
   { :Doing |
       { :Sports1 | :Alice :plays :Tennis . } :subject [ :age 15 ] ; :predicate [ :level :Beginner ] .
   } :reason :Ambition.
}.
EOF


echo >> $TRANSCRIPT_OUTPUT
curl_graph_store_get >> $TRANSCRIPT_OUTPUT


curl_query <<EOF
prefix : <http://example.org/>
select ?who ?action ?does ?what ?age ?type
where { 
  graph ?who { ?action { { :Alice ?does ?what } :object [ :age ?age; :type ?type ] . } }
  filter (?age < 16)
}
EOF


curl_query <<EOF
prefix : <http://example.org/> 
select ?action ?topic ?does ?what ?role ?age
where { 
  graph ?topic { :Alice ?does ?what }
  graph ?action { ?topic ?role [ :age ?age ] . }
  filter (?age < 16)
}
EOF


curl_query <<EOF
prefix : <http://example.org/> 
select ?who ?action1 ?does1 ?what1 ?subjectAge ?action2 ?does2 ?what2 ?objectAge
where { 
 graph ?who {
   ?action1 { { :Alice ?does1 ?what1 } :subject [ :age ?subjectAge ] . } .
   ?action2 { { :Alice ?does2 ?what2 } :object [ :age ?objectAge ] . } .
 }
  filter (?subjectAge < 16 && ?objectAge < 16)
}
EOF



