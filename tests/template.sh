#! /bin/bash

# all tests follow a similar pattern
# 1. clear the target repository
# 2. load it with test data
# 3. retrieve the content as nquads and validate them
# 4. execute queries and validate the results.
#

set -e
if [[ -z $STORE_HOST ]]; then source ../define.sh; fi

curl_clear_repository_content ;

curl_graph_store_update -H "Content-Type: text/turtle" <<EOF
@base <http://dydra.com/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

<http://example.org/s>
    <http://example.org/p> <http://example.org/o> .

<urn:dydra:default>
    <http://nested-named-graph.org/LOG> [
        <http://nested-named-graph.org/LOG> _:b21
    ] .
EOF

curl_graph_store_get > /tmp/template.out

fgrep -c http://example.org/s /tmp/template.out | fgrep -s "1"
fgrep -c http://example.org/p /tmp/template.out | fgrep -s "1"
fgrep -c http://example.org/o /tmp/template.out | fgrep -s "1"
fgrep -c urn:dydra:default /tmp/template.out | fgrep -s "1"
fgrep -c http://nested-named-graph.org/LOG /tmp/template.out | fgrep -s "2"
