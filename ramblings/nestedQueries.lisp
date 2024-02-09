;; EXAMPLE

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
:Alice {
    :Buying {
        { :Car1 | :Alice :buys :Car . } 
            :subject [ :age 22 ] ; 
            :object [ :age 12 ; 
                    :type :Sedan ; 
                    :reason :Ambition ] .
        { :Car2 | :Alice :leases :Car . } 
            :subject [ :age 42 ] ; 
            :object [ :age 0 ; 
                    :type :Coupe ] ; 
            :relation [ :reason :Fun ].
    } .
    { :Loving |
        { :Band1 | :Alice :loves :SuzieQuattro . }
            :subject [ :age 12 ]  .
        << :Movie1 | :Alice :hypes :Zendaya . >> 
            :subject [ :age 17 ] .
    }  :reason :Fun .
    { :Doing |
        { :Sports1 | :Alice :plays :Tennis . }
            :subject [ :age 15 ] ; 
            :predicate [ :level :Beginner ] .
    } :reason { :Right | :Ambition :is :King . } .
}.


;; N-QUADS
;; nested graph in object position and quoted graph are paresd correctly

<http://example.org/Loving> <http://example.org/reason> <http://example.org/Fun> <http://example.org/Alice> .
<http://example.org/Doing> <http://example.org/reason> <http://example.org/Right> <http://example.org/Alice> .
<http://example.org/Alice> <http://example.org/leases> <http://example.org/Car> <http://example.org/Car2> .
<http://example.org/Alice> <http://example.org/buys> <http://example.org/Car> <http://example.org/Car1> .
<urn:dydra:default> <http://nngraph.org/asserts> <http://example.org/Alice> <http://nngraph.org/embeddings> .
<http://example.org/Alice> <http://nngraph.org/asserts> <http://example.org/Buying> <http://nngraph.org/embeddings> .
<http://example.org/Alice> <http://nngraph.org/asserts> <http://example.org/Loving> <http://nngraph.org/embeddings> .
<http://example.org/Alice> <http://nngraph.org/asserts> <http://example.org/Doing> <http://nngraph.org/embeddings> .
<http://example.org/Alice> <http://nngraph.org/asserts> <http://example.org/Right> <http://nngraph.org/embeddings> .
<http://example.org/Buying> <http://nngraph.org/asserts> <http://example.org/Car2> <http://nngraph.org/embeddings> .
<http://example.org/Buying> <http://nngraph.org/asserts> <http://example.org/Car1> <http://nngraph.org/embeddings> .
<http://example.org/Loving> <http://nngraph.org/quotes> <http://example.org/Movie1> <http://nngraph.org/embeddings> .   ;; correct !
<http://example.org/Loving> <http://nngraph.org/asserts> <http://example.org/Band1> <http://nngraph.org/embeddings> .
<http://example.org/Doing> <http://nngraph.org/asserts> <http://example.org/Sports1> <http://nngraph.org/embeddings> .
<http://example.org/Car2> <http://example.org/subject> _:o-84 <http://example.org/Buying> .
<http://example.org/Car2> <http://example.org/object> _:o-85 <http://example.org/Buying> .
<http://example.org/Car2> <http://example.org/relation> _:o-86 <http://example.org/Buying> .
<http://example.org/Car1> <http://example.org/subject> _:o-82 <http://example.org/Buying> .
<http://example.org/Car1> <http://example.org/object> _:o-83 <http://example.org/Buying> .
_:o-82 <http://example.org/age> "22"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Buying> .
_:o-83 <http://example.org/type> <http://example.org/Sedan> <http://example.org/Buying> .
_:o-83 <http://example.org/age> "12"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Buying> .
_:o-83 <http://example.org/reason> <http://example.org/Ambition> <http://example.org/Buying> .
_:o-84 <http://example.org/age> "42"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Buying> .
_:o-85 <http://example.org/type> <http://example.org/Coupe> <http://example.org/Buying> .
_:o-85 <http://example.org/age> "0"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Buying> .
_:o-86 <http://example.org/reason> <http://example.org/Fun> <http://example.org/Buying> .
<http://example.org/Band1> <http://example.org/subject> _:o-89 <http://example.org/Loving> .
<http://example.org/Movie1> <http://example.org/subject> _:o-90 <http://example.org/Loving> .
_:o-90 <http://example.org/age> "17"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Loving> .
_:o-89 <http://example.org/age> "12"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Loving> .
<http://example.org/Alice> <http://example.org/loves> <http://example.org/SuzieQuattro> <http://example.org/Band1> .
<http://example.org/Sports1> <http://example.org/subject> _:o-91 <http://example.org/Doing> .
<http://example.org/Sports1> <http://example.org/predicate> _:o-92 <http://example.org/Doing> .
_:o-92 <http://example.org/level> <http://example.org/Beginner> <http://example.org/Doing> .
_:o-91 <http://example.org/age> "15"^^<http://www.w3.org/2001/XMLSchema#integer> <http://example.org/Doing> .
<http://example.org/Alice> <http://example.org/plays> <http://example.org/Tennis> <http://example.org/Sports1> .
<http://example.org/Ambition> <http://example.org/is> <http://example.org/King> <http://example.org/Right> .            ;; correct !
<http://example.org/Alice> <http://example.org/hypes> <http://example.org/Zendaya> <http://example.org/Movie1> .



;; QUERY 1
;; elaborate nesting that needs to be aware of full graph structure
;; PROBLEM
;; it catches all the fish
;; but requires a lot of upfront knowledge

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?who ?action ?does ?what ?age ?type
where { 
    graph ?who { 
        ?action { 
            { :Alice ?does ?what } 
              :object [ :age ?age; 
                        :type ?type ] . 
        } 
    }
    filter (?age < 16)
}

[
    "http://example.org/Alice",
    "http://example.org/Buying",
    "http://example.org/buys",
    "http://example.org/Car",
    12,
    "http://example.org/Sedan"
],
[
    "http://example.org/Alice",
    "http://example.org/Buying",
    "http://example.org/leases",                ;; :leases is correct
    "http://example.org/Car",
    0,
    "http://example.org/Coupe"
]


;; QUERY 2
;; less elaborate nesting than 1
;; PROBLEM
;; querying nested graphs takes some getting used to
;; asking for age inline returns outer graph
;; as the outer graph contains the age attribute
;; SOLUTION
;; see QUERY 2-A

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
   graph ?graph { 
       { :Alice :loves ?what .}                 ;; this is a nested graph!
           ?prop [ :age ?age ]
    } 
}

[
    "http://example.org/Loving",                ;; :Loving, not :Band1
    "http://example.org/SuzieQuattro",          ;; although :SuzieQuattro is contained in :Band1
    12                                          ;; the age annotation to :SuzieQuattro is contained in :Loving
                                                ;; but attributed to :Band1
]

;; QUERY 2-A
;; now the ?graph refers to the directly enclosing graph as expected
;; SOLUTION
;; i assume the solution could also be called "write propoer sparql, not sparql-nng"
;; it makes sense to write the query this way

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
    graph ?graph { :Alice :loves ?what .} 
    ?graph ?prop [ :age ?age ] .
}

[ 
    "http://example.org/Band1",                 ;; :Band1 is what we want
    "http://example.org/SuzieQuattro", 
    12
] 

;; QUERY 2-B
;; PROBLEM
;; why does this not return any results? ah, of course...
;; sparql is hard!
;; SOLUTION
;; ignore this query

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
   graph ?graph { 
        :Alice :loves ?what .
        ?graph ?prop [ :age ?age ]
    } 
}

[
    [ "graph", "what", "age" ]
] 

;; QUERY 2-C
;; actually, nested graphs don't need a GRAPH keyword - great!
 
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
       { ?graph | :Alice :loves ?what .} 
           ?prop [ :age ?age ]
}

[
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    12
] 

;; QUERY 2-D
;; finally! a solution for the optional approach
;; PROBLEM
;; standalone graph not supported, "?b ?c" are superfluous.
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
    { ?graph | :Alice :loves ?what .} ?b ?c .
    optional { ?graph ?prop [ :age ?age ] }
}

[
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    12
] 




;; QUERY 3
;; same as QUERY 2-A, but with optional
;; SOLUTION
;; no PROBLEM, this works as expected

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
    graph ?graph {  :Alice :loves ?what } 
    optional { ?graph ?prop [ :age ?age ]}
 }

[
    "http://example.org/Band1",                 ;; Band1, as expected
    "http://example.org/SuzieQuattro",
    12
]


;; QUERY 4
;; combining inline and optional query for age
;; PROBLEM
;; seems to ignore the optional 
;; SOLUTION
;; there is no problem except it's not intuitive

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what .} 
            ?prop [ :age ?age ]
    } 
    optional { ?graph ?prop2 [ :age ?age2 ]}
 }

[
    "http://example.org/Loving",                ;; Loving
    "http://example.org/SuzieQuattro",
    12,                                         ;; from :Band1
    null                                        ;; no ?age2 as :Loving has no :age annotation
]

;; QUERY 4-A
;; introducing a new variable ?graph2
;; inline use of optional
;; PROBLEM
;; :Alice loves only :SuzieQuattro which is a Band
;; she doesn't love the :Movie1
;; also :Movie1 is quoted
;; and therefore alone should not be part of the target graph at all

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?graph2 ?what ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what  .} 
            ?prop [ :age ?age ]
        optional { ?graph2 ?prop2 [ :age ?age2 ]}
    } 
}

[
    [
        "http://example.org/Loving",
        "http://example.org/Movie1",
        "http://example.org/SuzieQuattro",
        12,                                     ;; Alice' age when loving SuzieQuattro
        17                                      ;; Alice' age when hyping Zendaya
    ],
    [
        "http://example.org/Loving",
        "http://example.org/Band1",
        "http://example.org/SuzieQuattro",
        12,                                     ;; Alice' age when loving SuzieQuattro
        12                                      ;; Alice' age when loving SuzieQuattro
    ]
] 

;; QUERY 4-B
;; correct use of optional
;; two different graph variables
;; PROBLEM
;; the query itself is the problem as ?graph2 is bound to all graphs with an age attribute
;; the results are correct
;; SOLUTION
;; don't use this query

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?graph2 ?what ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what  .} 
        ?prop [ :age ?age ]
    } 
    optional { ?graph2 ?prop2 [ :age ?age2 ]}
}

[
    [ "http://example.org/Loving", "http://example.org/Car1", "http://example.org/SuzieQuattro", 12, 12 ],
    [ "http://example.org/Loving", "http://example.org/Car1", "http://example.org/SuzieQuattro", 12, 22 ],
    [ "http://example.org/Loving", "http://example.org/Car2", "http://example.org/SuzieQuattro", 12, 42 ],
    [ "http://example.org/Loving", "http://example.org/Car2", "http://example.org/SuzieQuattro", 12, 0 ],
    [ "http://example.org/Loving", "http://example.org/Band1", "http://example.org/SuzieQuattro", 12, 12 ],
    [ "http://example.org/Loving", "http://example.org/Movie1", "http://example.org/SuzieQuattro", 12, 17 ],
    [ "http://example.org/Loving", "http://example.org/Sports1", "http://example.org/SuzieQuattro", 12, 15 ]
] 

;; QUERY 4-C
;; correct use of optional, only one graph variable
;; SOLUTION
;; basically this is the same as QUERY 3 above 
;; just one more variable in the result set

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?prop ?age
where { 
   graph ?graph { :Alice :loves ?what } 
   optional { ?graph ?prop [ :age ?age ]}
 }

[
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    "http://example.org/subject",
    12
]

;; QUERY 4-D
;; SOLUTION
;; this is it:
;; - nested graphs
;; - two graph variables

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?outerGraph ?innerGraph ?what ?prop ?age
where { 
    graph ?outerGraph { 
        { ?innerGraph | :Alice :loves ?what . } 
            ?prop [ :age ?age ] .
    }
}

[
    "http://example.org/Loving",
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    "http://example.org/subject",
    12
] 

;; QUERY 4-E
;; same as QUERY 4-D, but with inside optional
;; PROBLEM
;; none, except the superfluous "?b ?c" as above in QUERY 2-D

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?outerGraph ?innerGraph ?what ?prop ?age
where { 
    graph ?outerGraph { 
        { ?innerGraph | :Alice :loves ?what . }  ?b ?c .
        optional { ?innerGraph ?prop [ :age ?age ] . }
    }
}

[
    "http://example.org/Loving",
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    "http://example.org/subject",
    12
] 




;; QUERY 5
;; correct use of optional
;; PROBLEM
;; the quoted movie is queried (which is not correct)
;; although its embedding is not listed (which is correct)

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does ?age 
where { 
   graph ?graph { :Alice ?does ?what } 
   optional { ?graph  ?prop [ :age ?age ] .}
}

[
  [ "http://example.org/Car1", "http://example.org/buys", 22 ],
  [ "http://example.org/Car1", "http://example.org/buys", 12 ],
  [ "http://example.org/Car2", "http://example.org/leases", 0 ],
  [ "http://example.org/Car2", "http://example.org/leases", 42 ],
  [ "http://example.org/Band1", "http://example.org/loves", 12 ],
  [ "http://example.org/Movie1", "http://example.org/hypes", 17 ],              ;; returns the quoted movie 
  [ "http://example.org/Sports1", "http://example.org/plays", 15 ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ]
                                                                                ;; but doesn't list the quoted embedding
] 


;; QUERY 6
;; PROBLEM
;; still incorrectly queries the quoted :Movie1 graph
;; compared to 5 inlining OPTIONAL loses the ages

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
where { 
    graph ?graph {  
        :Alice ?does ?what  .   
        optional { ?graph  ?prop [ :age ?age ] }
    } 
}

[
    [ "http://example.org/Car1", "http://example.org/buys", null ],
    [ "http://example.org/Car2", "http://example.org/leases", null ],
    [ "http://example.org/Band1", "http://example.org/loves", null ],
    [ "http://example.org/Movie1", "http://example.org/hypes", null ],          ;; returns the quoted movie 
    [ "http://example.org/Sports1", "http://example.org/plays", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ]  
                                                                                ;; but doesn't list the quoted embedding
] 

;; QUERY 6-A
;; PROBLEM
;; strange results, e.g. what's the reason for all those duplicate :leases?
;; SOLUTION
;; at least it doesn't return the quoted movie
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
where { 
    graph ?graph {  
        { ?graph2 | :Alice ?does ?what  .  } ?b ?c .
        optional { ?graph2  :subject [ :age ?age ] }
    } 
}

[
    [ "http://example.org/Buying", "http://example.org/leases", 42 ],
    [ "http://example.org/Buying", "http://example.org/leases", 42 ],
    [ "http://example.org/Buying", "http://example.org/leases", 42 ],
    [ "http://example.org/Buying", "http://example.org/buys", 22 ],
    [ "http://example.org/Buying", "http://example.org/buys", 22 ],
    [ "http://example.org/Loving", "http://example.org/loves", 12 ],
    [ "http://example.org/Doing", "http://example.org/plays", 15 ],
    [ "http://example.org/Doing", "http://example.org/plays", 15 ]
] 



;; EXPERIMENTS WITH 
;;
;;     FROM
;;
;; AND
;;
;;     FROM NAMED



;; QUERY 7
;; PROBLEM
;; a FROM clause gives no results at all (because GRAPH keyword)
;; SOLUTION
;; that was to be expected 

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
from :Alice
where { 
   graph ?graph { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}


;; QUERY 8
;; FROM NAMED works only inside a graph, not for its annotations
;; doesn't retrieve the quoted movie (which is correct)

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
from named :Alice
where { 
   graph ?graph { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}

[ 
    [ "http://example.org/Car1", "http://example.org/buys", null ],
    [ "http://example.org/Car2", "http://example.org/leases", null ], 
    [ "http://example.org/Band1", "http://example.org/loves", null ], 
    [ "http://example.org/Sports1", "http://example.org/plays", null ],
] 


;; QUERY 9
;; narrowing down FROM NAMED gives the expected narrower result
;; of course again nothing for annotations

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
from named :Buying
where { 
   graph ?graph { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}
 
[ 
    [ "http://example.org/Car1", "http://example.org/buys", null ],
    [ "http://example.org/Car2", "http://example.org/leases", null ] 
] 


;; IDEA: INSTEAD OF USING from named JUST NAME THE GRAPH !
;; of course this is just a lame workaround

;; QUERY 10
;; querying only graph :Buying seems like an easy fix
;; PROBLEM
;; but returns results from other graphs as well
;; and mixes up predicates :buys and :leases, but not the others. 
;; weird.

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
where { 
   graph :Buying { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}

[
    [ "http://example.org/Car1", "http://example.org/leases", 12 ],
    [ "http://example.org/Car1", "http://example.org/leases", 22 ],
    [ "http://example.org/Car2", "http://example.org/leases", 42 ],
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Band1", "http://example.org/leases", 12 ],
    [ "http://example.org/Movie1", "http://example.org/leases", 17 ],
    [ "http://example.org/Sports1", "http://example.org/leases", 15 ],
    [ "http://example.org/Car1", "http://example.org/buys", 12 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car2", "http://example.org/buys", 42 ],
    [ "http://example.org/Car2", "http://example.org/buys", 0 ],
    [ "http://example.org/Band1", "http://example.org/buys", 12 ],
    [ "http://example.org/Movie1", "http://example.org/buys", 17 ],
    [ "http://example.org/Sports1", "http://example.org/buys", 15 ]
] 


;; QUERY 10-A
;; the query asks specifically for property :buys in graph :Buying
;; to remove one variable from teh mix
;; PROBLEM
;; results mix different graphs with actual cars from graph :Buying

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
    graph :Buying { :Alice :buys ?what } 
    optional { ?graph ?prop [ :age ?age ]}      ;; maybe ?graph is the problem
}

[
    [ "http://example.org/Car1", "http://example.org/Car", 12 ],
    [ "http://example.org/Car1", "http://example.org/Car", 22 ],
    [ "http://example.org/Car2", "http://example.org/Car", 42 ],
    [ "http://example.org/Car2", "http://example.org/Car", 0 ],
    [ "http://example.org/Band1", "http://example.org/Car", 12 ],
    [ "http://example.org/Movie1", "http://example.org/Car", 17 ],
    [ "http://example.org/Sports1", "http://example.org/Car", 15 ]
] 

;; QUERY 10-B
;; replacing the ?graph variable by :Buying
;; PROBLEM
;; it doesn't find the :age

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age
where { 
   graph :Buying { 
       :Alice :buys ?what 
    } 
    optional { :Buying ?prop [ :age ?age ]}
}

[
    [ null, "http://example.org/Car", null ]
] 

;; QUERY 10-C
;; PROBLEM
;; iiuc the sparql parser doesn't understand standalone nested graphs.
;; is that correct? do we need/want to do soemthing about it?

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph2 ?does ?age 
where { 
   graph :Buying { 
        { ?graph2 | :Alice ?does ?what . } .
   }
    OPTIONAL { ?graph2  ?prop [ :age ?age ] }  
}

>> RuntimeError: queryResult could not be resolved

;; same for 
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph2 ?does ?age 
where { 
   graph :Buying { 
        { ?graph2 | :Alice ?does ?what . } .
        OPTIONAL { ?graph2  ?prop [ :age ?age ] }  
   }
}

>> RuntimeError: queryResult could not be resolved

;; on a related note this one parses (but returns no results)
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph2 ?does ?age 
where { 
    graph :Buying { 
        { ?graph2 | :Alice ?does ?what . } 
            :age ?age  .
        OPTIONAL { ?graph2  ?prop [ :age ?age ] } .
    }
}

;; but this one throws an error 
;; (same for "_:a _:b" instead of [][]"")
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph2 ?does ?age 
where { 
    graph :Buying { 
        { ?graph2 | :Alice ?does ?what . } 
            [] [] .
    OPTIONAL { ?graph2  ?prop [ :age ?age ] } .
    }
}

;; however, this one (which logically is the same)
;; produces a rather ridiculous result
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does ?age 
where { 
    graph :Buying {
        { ?graph | :Alice ?does ?what } 
            ?x ?y .
        optional { ?graph  ?prop [ :age ?age ] .}
   }
}

[
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Car2", "http://example.org/leases", 42 ],
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Car2", "http://example.org/leases", 42 ],
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Car2", "http://example.org/leases", 42 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car1", "http://example.org/buys", 12 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car1", "http://example.org/buys", 12 ]
] 

;; so it seems to me that there is something wrong
;; but it's not clear to me what




;; QUERY 11
;; works only as long as every entry has at least one age attribute

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does ?age 
where { 
   graph :Buying {
         { :Alice ?does ?what } 
         ?prop [ :age ?age ] .
   }
}

[
    [ null, "http://example.org/buys", 12 ],
    [ null, "http://example.org/buys", 22 ],
    [ null, "http://example.org/leases", 42 ],
    [ null, "http://example.org/leases", 0 ]
] 


;; QUERY 12
;; inlining the optional into :Buying should do the trick
;; but doubles down on the predicates

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does ?age 
where { 
   graph :Buying {
         { :Alice ?does ?what } 
         optional { ?graph  ?prop [ :age ?age ] .}
   }
}

[
    [ "http://example.org/Car1", "http://example.org/leases", 12 ],
    [ "http://example.org/Car1", "http://example.org/leases", 22 ],
    [ "http://example.org/Car2", "http://example.org/leases", 42 ],
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Car1", "http://example.org/buys", 12 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car2", "http://example.org/buys", 42 ],
    [ "http://example.org/Car2", "http://example.org/buys", 0 ]
] 

;; but with an udate to the data
;; removing all mentions of :age from :Car1
;; the results are missing :Car1 completely
;; (and unsurprisingly still double down on the predicates)

@base <http://dydra.com/> .
@prefix : <http://example.org/> .
:Alice {
    :Buying {
        { :Car1 | :Alice :buys :Car . } 
            :object [
                    :type :Sedan ; 
                    :reason :Ambition ] .
        { :Car2 | :Alice :leases :Car . } 
            :subject [ :age 42 ] ; 
            :object [ :age 0 ; 
                    :type :Coupe ] ; 
            :relation [ :reason :Fun ].
    } .
    { :Loving |
        { :Band1 | :Alice :loves :SuzieQuattro . }
            :subject [ :age 12 ]  .
        << :Movie1 | :Alice :hypes :Zendaya . >> 
            :subject [ :age 17 ] .
    }  :reason :Fun .
    { :Doing |
        { :Sports1 | :Alice :plays :Tennis . }
            :subject [ :age 15 ] ; 
            :predicate [ :level :Beginner ] .
    } :reason { :Right | :Ambition :is :King . } .
}.

[
    [ "http://example.org/Car2", "http://example.org/leases",  42 ],
    [ "http://example.org/Car2", "http://example.org/leases", 0 ],
    [ "http://example.org/Car2", "http://example.org/buys", 42 ],
    [ "http://example.org/Car2", "http://example.org/buys", 0 ]
] 






