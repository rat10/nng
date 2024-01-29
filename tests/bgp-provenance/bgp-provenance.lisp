;;;

(in-package :spocq.i)
(initialize-spocq)


;;; (in-package :sparql-1-0-4)
;;; (trace |GroupGraphPattern| |GroupGraphPatternSub| |TriplesBlock| |GroupGraphPatternRest| |ConstituentGraph| |TriplesSameSubject| |TriplesBlockRest|)
;;; (trace |GroupGraphPattern-Constructor| |GroupGraphPatternSub-Constructor| |TriplesBlock-Constructor| |GroupGraphPatternRest-Constructor| |ConstituentGraph-Constructor| |TriplesSameSubject-Constructor| |TriplesBlockRest-Constructor|)

;;; based on this dataset
"
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
"



(defparameter *q0*
 "prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?who ?action ?does ?what ?age ?type
where { 
 graph ?who { ?action { { :Alice ?does ?what } :object [ :age ?age; :type ?type ] . } }
  filter (?age < 16)
}
")


(pprint-sse (parse-sparql *q0*))
(select
 (filter
  (graph ?who
         (bgp (bgp (graph ?action)
                   (bgp (graph <http://nngraph.org/embeddings>) (triple ??PARENT <http://nngraph.org/asserts> ?action))
                   (triple ??GRAPH-ASSERTED-2 <http://example.org/object> ??3)
                   (bgp (graph ??GRAPH-ASSERTED-2)
                        (bgp (graph <http://nngraph.org/embeddings>)
                             (triple ?action <http://nngraph.org/asserts> ??GRAPH-ASSERTED-2))
                        (triple <http://example.org/Alice> ?does ?what))
                   (triple ??3 <http://example.org/age> ?age)
                   (triple ??3 <http://example.org/type> ?type))))
  (:< ?::age 16))
 (?who ?action ?does ?what ?age ?type))

(pprint-sse (expand-query *q0* :repository-id "seg/test" :agent (system-agent)))

(test-sparql *q0* :repository-id "seg/test")


(defparameter *q1*
 "prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select ?who ?action1 ?does1 ?what1 ?age1 ?action2 ?does2 ?what2 ?age2
where { 
 graph ?who {
   ?action1 { { :Alice ?does1 ?what1 } :subject [ :age ?age1 ] . } .
   ?action2 { { :Alice ?does2 ?what2 } :object [ :age ?age2 ] . } .
 }
  filter (?age1 < 16 && ?age2 < 16)
}
")

(pprint-sse (parse-sparql *q1*))
(select
 (filter
  (graph ?who
         (bgp (bgp (graph ?action1)
                   (bgp (graph <http://nngraph.org/embeddings>)
                        (triple ??PARENT <http://nngraph.org/asserts> ?action1))
                   (triple ??GRAPH-ASSERTED-7 <http://example.org/subject> ??8)
                   (bgp (graph ??GRAPH-ASSERTED-7)
                        (bgp (graph <http://nngraph.org/embeddings>)
                             (triple ?action1 <http://nngraph.org/asserts> ??GRAPH-ASSERTED-7))
                        (triple <http://example.org/Alice> ?does1 ?what1))
                   (triple ??8 <http://example.org/age> ?age1))
              (bgp (graph ?action2)
                   (bgp (graph <http://nngraph.org/embeddings>)
                        (triple ??PARENT <http://nngraph.org/asserts> ?action2))
                   (triple ??GRAPH-ASSERTED-11 <http://example.org/object> ??12)
                   (bgp (graph ??GRAPH-ASSERTED-11)
                        (bgp (graph <http://nngraph.org/embeddings>)
                             (triple ?action2 <http://nngraph.org/asserts> ??GRAPH-ASSERTED-11))
                        (triple <http://example.org/Alice> ?does2 ?what2))
                   (triple ??12 <http://example.org/age> ?age2))))
  (&& (:< ?::age1 16) (:< ?::age2 16)))
 (?who ?action1 ?does1 ?what1 ?age1 ?action2 ?does2 ?what2 ?age2))

(pprint-sse (expand-query *q1* :repository-id "seg/test" :agent (system-agent)))

(test-sparql *q1* :repository-id "seg/test")


