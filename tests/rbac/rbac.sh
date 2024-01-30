#! /bin/bash

comment 'Nested Graph Access Authorization
These requests demonstrate the integrity of an in-line rbac model in combination with nested graphs.

The initial dataset and queries illustrate access control with a trivial in-line authorization mechanism.
An adequate mechanism would not rely on inline data, but could employ analaogous logic.

The second examples concern a dataset which includes nested graphs.
For such a model, the authorization logic is extended to recognize the relations between graphs.
'


set -e
if [[ -z $STORE_HOST ]]; then source ../define.sh; fi
export TRANSCRIPT_OUTPUT=rbac.txt
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

comment 'The initial dataset comprises just data graphs and an authroization graph.
These are sufficient to limit user access to those data graphs for the authorization graph affords them read access.
'

if [[ "$1" != "no_import" ]]
then

  curl_clear_repository_content ;

  comment import simple dataset
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix user: <http://example.org/user/> .
@prefix data: <http://example.org/data/> .
@prefix acl: <http://www.w3.org/ns/auth/acl#> .
# the access control graph
:authorizations {
  _:acl1 acl:accessTo data:graph1 ;
    acl:mode acl:Read ;
    acl:agent user:User1 .
  _:acl2 acl:accessTo data:graph1 ;
    acl:mode acl:Read ;
    acl:agent user:User2 .
  _:acl3 acl:accessTo data:graph1 ;
    acl:mode acl:Write ;
    acl:agent user:User2 .
  _:acl4 acl:accessTo data:graph2 ;
    acl:mode acl:Read ;
    acl:agent user:User2 .
} .

data:graph1 {
  :s1 :p1 'o1' .
} .

data:graph2 {
  :s2 :p2 'o2' .
} .
EOF
fi


comment dataset content
curl_graph_store_get | tee $ECHO_OUTPUT >> $TRANSCRIPT_OUTPUT

comment simple query for authorizations
curl_query <<EOF
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
select ?who ?access ?what
where { 
  graph :authorizations { _:auth acl:accessTo ?what; acl:mode ?access; acl:agent ?who }
}
EOF

comment A simple query for data
curl_query <<EOF
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
select ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
where { 
  graph ?data { ?s ?p ?o }
}
EOF

comment An access-controlled query for data limits User1 to the content of only data:graph1
curl_query '$user=<http://example.org/user/User1>' <<EOF
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
where { 
  graph :authorizations { _:auth acl:accessTo ?data ; acl:mode acl:Read ; acl:agent ?user }
  graph ?data { ?s ?p ?o }
}
EOF


if [[ "$1" != "no_import" ]]
then

  curl_clear_repository_content ;

  comment import dataset with nested graphs
curl_import <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix user: <http://example.org/user/> .
@prefix data: <http://example.org/data/> .
@prefix acl: <http://www.w3.org/ns/auth/acl#> .
# the access control graph
:authorizations {
  _:acl1 acl:accessTo data:graph1 ;
    acl:mode acl:Read ;
    acl:agent user:User1 .
  _:acl2 acl:accessTo data:graph1 ;
    acl:mode acl:Read ;
    acl:agent user:User2 .
  _:acl3 acl:accessTo data:graph1 ;
    acl:mode acl:Write ;
    acl:agent user:User2 .
  _:acl4 acl:accessTo data:graph2 ;
    acl:mode acl:Read ;
    acl:agent user:User2 .
} .

data:graph1 {
  :s1 :p1 'o1' .
  data:subgraph1 { :subs1 :subp1 'sub-o1' . } .
} .

data:graph2 {
  :s2 :p2 'o2' .
  data:subgraph2 { :subs2 :subp2 'sub-o2' . } .
} .
EOF
fi

comment An access-controlled query for nested data adds paths to the access inference
curl_query '$user=<http://example.org/user/User1>' <<EOF
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
prefix nng: <http://nngraph.org/>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
FROM NAMED nng:embeddings
where { 
  graph :authorizations {
    _:auth acl:accessTo ?dataRoot ; acl:mode acl:Read ; acl:agent ?user .
    graph nng:embeddings { ?dataRoot nng:asserts* ?data . }
  }
  graph ?data { ?s ?p ?o }
}
EOF

