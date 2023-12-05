#! /bin/bash

# import/query examples demonstrate the synthetic use cases.


set -e
if [[ -z $STORE_HOST ]]; then source ./define.sh; fi

curl_clear_repository_content ;

curl -v -X PUT https://${STORE_HOST}/seg/test/service -H "Content-Type: application/trig" -u ":${STORE_TOKEN}" \
  --data-binary @- <<EOF
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
@prefix nng: <http://nested-named-graph.org/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

:Z {
    :Y {
        :X { 
            :Dog :eats :Fish .
            THIS :says :Alice ;  
                 nng:domain [ :name "Dodger" ]
        } :says :Bob ;
          :believes :Ben .
        :Goat :has :Ideas .
        :Beatrice :claims {" :Jake :knows :Larry . 
                             :Larry a :Star . "} .
    } :says :Carol ; 
      :believes :Curt ; 
      nng:tree :Example .
} :says :Zarathustra ;
  :source :Source_1 .

EOF

#|
1) who *says* ':Dog :eats :Fish .' ?
    > :Alice                            # give me only the result(s) from the THIS level
    > :Alice :Bob :Carol :Zarathustra   # give me results on all levels of nesting
    > :Alice :Bob                       # give me results from the first n=2 levels of nesting
                                        # nesting level count starts with THIS
|#

curl -X POST https://${STORE_HOST}/seg/test/sparql -H "Content-Type: application/sparql-query" -H "Accept: application/sparql-results+json" \
  -u ":${STORE_TOKEN}" \
  --data-binary @- -o $RESULTS_OUTPUT <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?who
from included nng:NestedGraph
where {
  { :Dog :eats :Fish . } :says ?who .
}
EOF

fgrep -i true $RESULTS_OUTPUT


cat > /dev/null <<EOF
;;; below, follows a transcript of a listener internal to the query processor.
;;; this can eventually be transformed into remote requests according to the pattern, above.

(test-sparql "select ?s ?p ?o ?g
where {
 {?s ?p ?o } union {graph ?g {?s ?p ?o}}
}"
             :repository-id "seg/test")
  
;;; show the embeddings
(test-sparql "
prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
where {
 {graph nng:embeddings {?s ?p ?o}}
}"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
s,p,o
urn:dydra:default,http://nested-named-graph.org/transcludes,http://example.org/Z
http://example.org/Z,http://nested-named-graph.org/transcludes,http://example.org/Y
http://example.org/Y,http://nested-named-graph.org/records,_:termgraph-5
http://example.org/Y,http://nested-named-graph.org/transcludes,http://example.org/X


;;;     > :Alice                            # give me only the result(s) from the THIS level

;;; produce the sisngle :says which is in that graph
;;; operate on the graph closure from the default graph root
;;; this include a spurious binding for the graph name
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?who
from included nng:NestedGraph
where {
  { :Dog :eats :Fish . } :says ?who .
}"
             :repository-id "seg/test"  :response-content-type mime:text/csv)
?BGP7,who
http://example.org/X,http://example.org/Alice


;;;     > :Alice :Bob :Carol :Zarathustra   # give me results on all levels of nesting
;;; is more complex

;;; produce the immediate references intra- and inter-graph
;;; operate on all graphs as named (including the default graph)
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what ?who ?where
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph ?where { ?what :says ?who . } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what,who,where
http://example.org/X,http://example.org/Bob,http://example.org/Y
http://example.org/X,http://example.org/Alice,http://example.org/X

;;; produce all pronouncements
;;; operate on all graphs as named (including the default graph)
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what ?root
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what,root
http://example.org/X,http://example.org/X
http://example.org/X,http://example.org/Y
http://example.org/X,urn:dydra:default
http://example.org/X,http://example.org/Z

;;; extend it with the orator in each venu
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what ?root ?venue ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
  { graph ?venue { ?root :says ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what,root,venue,orator
http://example.org/X,http://example.org/X,http://example.org/Y,http://example.org/Bob
http://example.org/X,http://example.org/X,http://example.org/X,http://example.org/Alice
http://example.org/X,http://example.org/Y,http://example.org/Z,http://example.org/Carol
http://example.org/X,http://example.org/Z,urn:dydra:default,http://example.org/Zarathustra


;;; reduce it to the orator
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
  { graph ?venue { ?root :says ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
orator
http://example.org/Bob
http://example.org/Alice
http://example.org/Carol
http://example.org/Zarathustra


;;;     > :Alice :Bob                       # give me results from the first n=2 levels of nesting
;;;                                         # nesting level count starts with THIS
;;; this was already produced be the query which referred to just the { :Dog :eats :Fish . } graph
;;; it can be done explicitly by limiting the embedding path length

(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what ?root ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes{0,1} ?what . } }
  { graph ?root { ?about :says ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what,root,orator
http://example.org/X,http://example.org/X,http://example.org/Alice
http://example.org/X,http://example.org/Y,http://example.org/Bob


#|
2) who *believes* ':Dog :eats :Fish .' ?
    >                                   # give me only the result(s) from the THIS level
    > :Ben :Curt                        # give me results on all levels of nesting
    > :Ben                              # give me results from the first n=2 levels of nesting
                                        # nesting level count starts with THIS
|#

;;;     > :Ben :Curt                        # give me results on all levels of nesting
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
  { graph ?venue { ?root :believes ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
orator
http://example.org/Ben
http://example.org/Curt

(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?orator
from included nng:NestedGraph
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes ?what . } }
  { graph ?venue { ?root :believes ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
orator
http://example.org/Curt


;;;    > :Ben                              # give me results from the first n=2 levels of nesting
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?orator
from included nng:NestedGraph
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph ?venue { ?what :believes ?orator } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
orator
http://example.org/Ben



#|
3) in which graph(s) occurs ':Goat :has ?o' ?
    >                                   # give me only results annotated with THIS
    > :Y                                # give me only the nearest graph
    > :Y :Z                             # give me all enclosing graphs (Olaf's case 3)
                                        # BUT not the DEFAULT graph, because :Z is not nested 
                                        #   in the default graph
                                        #   would you agree?
                                        #   or does that run counter your implementation?
|#

;;;    >                                   # give me only results annotated with THIS
;;; does not exist for :Goat :has ?o
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what
where {
  { graph ?what { :Goat :has ?o . ?what ?annotated ?with} }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what


;;;    > :Y                                # give me only the nearest graph
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?what
where {
  { graph ?what { :Goat :has ?o . } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)
what
http://example.org/Y


;;;     > :Y :Z                             # give me all enclosing graphs (Olaf's case 3)
(test-sparql "
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select distinct ?what ?root
where {
  { graph ?what { :Goat :has ?o . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
}"
             :repository-id "seg/test"   :response-content-type mime:text/csv)what,root
http://example.org/Y,http://example.org/Y
http://example.org/Y,urn:dydra:default
http://example.org/Y,http://example.org/Z


EOF