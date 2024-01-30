#! /bin/bash

set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

# illustrate bom queries
# - those which target just the bom structure
# - those which rely on graph nesting
# - those which apply to both aspects

export TRANSCRIPT_OUTPUT=bom-excerpt.txt
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
import bom excerpt dataset
' >> $TRANSCRIPT_OUTPUT


cat bom-excerpt.trig | curl_import


echo "test bom relations" | tee  $ECHO_OUTPUT >> $TRANSCRIPT_OUTPUT

curl_query <<EOF
prefix : <http://example.org/> 
select ?s ?o
from <urn:dydra:all>
where { ?s <http://data.com/def/bom>* ?o }
EOF


cat <<EOF > /dev/null
(parse-trig-star (read-file "bom-excerpt.trig"))

(parse-trig-star "
prefix : <http://www.example.org/> 
<http://data.com/graph/salesItem/item003>  { { <http://data.com/id/salesItem/item003> <http://data.com/def/orderablePartNumber> 'SL3S4021ETF' .} . } .
")

(parse-trig-star "
prefix : <http://www.example.org/> 
<http://data.com/graph/salesItem/item003>  { { <http://data.com/id/salesItem/item003> <http://data.com/def/orderablePartNumber> 'SL3S4021ETF' .} :p 'o' . } .
")

(parse-trig-star "
prefix : <http://www.example.org/> 
<http://data.com/graph/salesItem/item003>  {
  << <http://data.com/id/salesItem/item003> <http://data.com/def/orderablePartNumber> 'SL3S4021ETF' . >> 
    <http://data.com/def/release> '2022' . } .
")

EOF
