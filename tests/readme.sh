#! /bin/bash

# import/query examples to demonstrate readme use cases.


set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

curl_clear_repository_content ;

curl -v -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}" \
  --data-binary @- <<EOF
@base <http://dydra.com/> .
prefix :    <http://ex.org/>
prefix nng: <http://nng.io/>
:G1 {
    :G2 {
        :Alice :buys :Car .
        :G2 nng:domain [ :age 20 ];            # Alice, not the car, is 20 years old
            nng:relation [ :payment :Cash ];  
            nng:range nng:Interpretation ,     # Alice buys a car, not a website
                       [ :color :black ].  
    } :source :Denis ;                          # an annotation on the graph
      :purpose :JoyRiding .                     # sloppy, but not too ambiguous
    :G3 {    
        [] {                                    # graphs may be named by blank nodes 
            :Alice :buys :Car .                 # probably a different car buying event
            THIS nng:domain [ :age 28 ] .      # self reference
        } :source :Eve .    
    } :todo :AddDetail .                        # add detail
}                                               # then remove this level of nesting
                                                # without changing the data topology
EOF

cat > /dev/null <<EOF

(parse-trig-star "
prefix :    <http://ex.org/>
prefix nng: <http://nng.io/>
:G1 {
    :G2 {
        :Alice :buys :Car .
        :G2 nng:domain [ :age 20 ];            # Alice, not the car, is 20 years old
            nng:relation [ :payment :Cash ];  
            nng:range nng:Interpretation ,     # Alice buys a car, not a website
                       [ :color :black ].  
    } :source :Denis ;                          # an annotation on the graph
      :purpose :JoyRiding .                     # sloppy, but not too ambiguous
    :G3 {    
        [] {                                    # graphs may be named by blank nodes 
            :Alice :buys :Car .                 # probably a different car buying event
            THIS nng:domain [ :age 28 ] .      # self reference
        } :source :Eve .    
    } :todo :AddDetail .                        # add detail
}                                               # then remove this level of nesting
                                                # without changing the data topology

")

;;; nestings
(test-sparql "
prefix : <http://ex.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?s ?p ?o
WHERE  {graph nng:embeddings { ?s ?p ?o } }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p,o
urn:dydra:default,http://nested-named-graph.org/transcludes,http://ex.org/G1
http://ex.org/G1,http://nested-named-graph.org/transcludes,http://ex.org/G3
http://ex.org/G1,http://nested-named-graph.org/transcludes,http://ex.org/G2
http://ex.org/G3,http://nested-named-graph.org/transcludes,_:b29


;;; based on that :G1 itself contains
(test-sparql "
prefix : <http://ex.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?s ?p ?o
WHERE { graph :G1 { ?s ?p ?o } }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p,o
http://ex.org/G3,http://ex.org/todo,http://ex.org/AddDetail
http://ex.org/G2,http://ex.org/purpose,http://ex.org/JoyRiding
http://ex.org/G2,http://ex.org/source,http://ex.org/Denis

;;; ... and the transcluded content is
(test-sparql "
prefix : <http://ex.org/>
prefix nng: <http://nested-named-graph.org/>
SELECT ?s ?p ?o
FROM INCLUDED nng:NestedGraph
WHERE { graph :G1 { ?s ?p ?o } }
"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p,o
_:b29,http://nng.io/domain,_:o-30
http://ex.org/Alice,http://ex.org/buys,http://ex.org/Car
_:o-30,http://ex.org/age,28
_:b29,http://ex.org/source,http://ex.org/Eve
http://ex.org/Alice,http://ex.org/buys,http://ex.org/Car
_:o-25,http://ex.org/age,20
_:o-26,http://ex.org/payment,http://ex.org/Cash
_:o-27,http://ex.org/color,http://ex.org/black
http://ex.org/G2,http://nng.io/domain,_:o-25
http://ex.org/G2,http://nng.io/relation,_:o-26
http://ex.org/G2,http://nng.io/range,_:o-27
http://ex.org/G2,http://nng.io/range,http://nng.io/Interpretation
http://ex.org/G3,http://ex.org/todo,http://ex.org/AddDetail
http://ex.org/G2,http://ex.org/purpose,http://ex.org/JoyRiding
http://ex.org/G2,http://ex.org/source,http://ex.org/Denis






EOF