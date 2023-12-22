#! /bin/bash

set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

# illustrate bom queries
# - those which target just the bom structure
# - those which rely on graph nesting
# - those which apply to both aspects

curl -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}" \
     --data-binary @bom-excerpt.trig
 | test_success


echo "test bom relations" > $ECHO_OUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
select ?s ?p ?o
from <urn:dydra:all>
where { ?s <http://data.com/def/bom>* ?o }
EOF

