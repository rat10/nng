#! /bin/bash

# test that the nesting relation is inclusion by default and when declared
#

#source ../define.sh
#set -e

clear_repository_content ;

curl_graph_store_update -H "Content-Type: application/rdf+nng" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

[nng:RECORD]{ <http://example.org/s>  <http://example.org/p> <http://example.org/o> . }
EOF

curl_graph_store_get > /tmp/test.out

fgrep -c http://example.org/s /tmp/test.out | fgrep -s "1"
fgrep -c http://example.org/p /tmp/test.out | fgrep -s "1"
fgrep -c http://example.org/o /tmp/test.out | fgrep -s "1"
fgrep -c nng:records /tmp/test.out | fgrep -s "1"

