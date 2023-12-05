#! /bin/bash

# import/query examples to demonstrate synthetic use cases.


set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

curl_clear_repository_content ;

curl -v -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}" \
  --data-binary @- <<EOF
@base <http://dydra.com/> .
prefix : <http://example.org/>
prefix nng: <http://nested-named-graph.org/>
prefix iana: <https://www.iana.org/assignments/media-types/application/>
prefix owl: <http://www.w3.org/2002/07/owl#>
# :X nng:includes ':Alice :likes :Skiing'^^nng:ttl nng:embeddings.
# nng:embeddings { :X nng:includes ':Alice :likes :Skiing'^^iana:trig . }
:Bob :says ':Moon :madeOf :Cheese'^^iana:trig .
:Alice :said ':s :p :o. :a :b :c'^^iana:trig .
[ :Y nng:Quote]':ThisGraph a :Quote'^^iana:trig .
## :LoisLane :loves [QUOTE]':Superman', :Skiing, [REPORT]':ClarkKent' .
:LoisLane :loves ':Superman', :Skiing, ':ClarkKent' .
## :Kid :loves [REPORT]':Superman' .
:Kid :loves ':Superman' .
:Carol :claims {":Denis :goes :Swimming"} .
:Y {:Some :dubious :Thing} .
:ClarkKent owl:sameAs :Superman .
:ClarkKent :loves :LoisLane .
EOF

cat > /dev/null <<EOF

EOF