#! /bin/bash

set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

# test dataset clause variants

curl -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}"  <<EOF \
 | test_success
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
:defaultSubject :defaultPredicate 'default object' .
[]{ :nestedSubject :nestedPredicate 'default nested anonymous object' }
[nng:NestedGraph]{ :nestedSubject :nestedPredicate 'explicit nested anonymous object' }
[nng:Quote]{ :quotedSubject :quotedPredicate 'o' }
[nng:Report]{ :reportSubject :reportPredicate 'o' }
[nng:Record]{ :recordSubject :recordPredicate 'o' }
[nng:GraphLiteral]{ :literalSubject :literalPredicate 'o' }
EOF


echo "test from variants" > $ECHO_OUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:NestedGraph
where { ?s ?p ?o }
EOF
fgrep -s nestedPredicate $RESULT_POUTPUT
fgrep -vs defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:Quote
where { ?s ?p ?o }
EOF
fgrep -s quotedPredicate $RESULT_POUTPUT
fgrep -vs defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:Report
where { ?s ?p ?o }
EOF
fgrep -s reportedPredicate $RESULT_POUTPUT
fgrep -vs defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:Record
where { ?s ?p ?o }
EOF
fgrep -s recordedPredicate $RESULT_POUTPUT
fgrep -vs defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:GraphLiteral ; 
where { ?s ?p ?o }
EOF
fgrep -s literalPredicate $RESULT_POUTPUT
fgrep -vs defaultPredicate $RESULT_POUTPUT


echo "test included variants" > $ECHO_OUTPUT
# the root graph in this case is the default graph, which means its content is returned

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:NestedGraph
where { ?s ?p ?o }
EOF
fgrep -s nestedPredicate $RESULT_POUTPUT
fgrep -s defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:Quote
where { ?s ?p ?o }
EOF
fgrep -s quotedPredicate $RESULT_POUTPUT
fgrep -s defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:Report
where { ?s ?p ?o }
EOF
fgrep -s reportedPredicate $RESULT_POUTPUT
fgrep -s defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:Record
where { ?s ?p ?o }
EOF
fgrep -s recordedPredicate $RESULT_POUTPUT
fgrep -s defaultPredicate $RESULT_POUTPUT

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULT_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:GraphLiteral ; 
where { ?s ?p ?o }
EOF
fgrep -s literalPredicate $RESULT_POUTPUT
fgrep -s defaultPredicate $RESULT_POUTPUT
