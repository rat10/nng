@base <http://dydra.com/> .
@prefix : <http://example.org/> .
:Alice {
    :Buying {
        { :Car1 | :Alice :buys :Car . } 
            :subject [ :age 22 ] ; 
            :object [ :age 12 ; 
                    :type :Sedan ; 
                    :reason :Ambition ] .
        { :Car2 | :Alice :buys :Car . } 
            :subject [ :age 42 ] ; 
            :object [ :age 0 ; 
                    :type :Coupe ] ; 
            :relation [ :reason :Fun ].
    } .
    { :Loving |
        { :Band1 | :Alice :loves :SuzieQuattro . }
            :subject [ :age 12 ]  .
    }  :reason :Fun .
    { :Doing |
        { :Sports1 | :Alice :plays :Tennis . } 
            :subject [ :age 15 ] ; 
            :predicate [ :level :Beginner ] .
    } :reason :Ambition.
}.


;; QUERY 1
;; elaborate nesting nees to be aware of full graph structure
;; it catches all the fish
;; but requires too much upfront knowledge
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
    "http://example.org/buys",
    "http://example.org/Car",
    0,
    "http://example.org/Coupe"
]

;; LESS ELABORATE NESTING

;; QUERY 2
;; less elaborate nesting than 1
;; asking for age inline returns outer graph
;; as the outer graph contains the age attribute
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what  .} 
       ?prop [ :age ?age ]
    } 
 }

[
    "http://example.org/Loving",
    "http://example.org/SuzieQuattro",
    12,
    null
]

;; QUERY 3
;; less elaborate nesting than 1
;; asking for age as optional returns inner graph
;; ¿ because it is not optional ?
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what  .} 
    } 
    optional { ?graph ?prop2 [ :age ?age2 ]}
 }

[
    "http://example.org/Band1",
    "http://example.org/SuzieQuattro",
    null,
    12
]

;; QUERY 4
;; combining inline and optional query for age
;; seems to ignore the optional 
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?what  ?age ?age2
where { 
   graph ?graph { 
       { :Alice :loves ?what  .} 
        ?prop [ :age ?age ]
    } 
    optional { ?graph ?prop2 [ :age ?age2 ]}
 }

[
    "http://example.org/Loving",
    "http://example.org/SuzieQuattro",
    12,
    null
]


;; INLINE USE OF optional ?

;; QUERY 5
;; correct use of optional
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does ?age 
where { 
   graph ?graph { :Alice ?does ?what } 
   optional { ?graph  ?prop [ :age ?age ] .}
}

[ 
    [ "graph", "does", "age" ], 
    [ "http://example.org/Car2", "http://example.org/buys", 0 ], 
    [ "http://example.org/Car2", "http://example.org/buys", 42 ], 
    [ "http://example.org/Car1", "http://example.org/buys", 22 ], 
    [ "http://example.org/Car1", "http://example.org/buys", 12 ], 
    [ "http://example.org/Band1", "http://example.org/loves", 12 ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://example.org/Sports1", "http://example.org/plays", 15 ] 
] 

;; QUERY 6
;; compared to 5 inlining OPTIONAL loses the ages
;; so that's probably just plain wrong SPARQL-wise
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
    [ "graph", "does", "age" ], 
    [ "http://example.org/Car2", "http://example.org/buys", null ], 
    [ "http://example.org/Car1", "http://example.org/buys", null ], 
    [ "http://example.org/Band1", "http://example.org/loves", null ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ], 
    [ "http://example.org/Sports1", "http://example.org/plays", null ] 
] 


;; EXPERIMENTS WITH from AND from named

;; QUERY 7
;; a FROM  clause gives no results at all (because GRAPH keyword)
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
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
from named :Alice
where { 
   graph ?graph { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}

[ 
    [ "http://example.org/Sports1", "http://example.org/plays", null ], 
    [ "http://example.org/Band1", "http://example.org/loves", null ], 
    [ "http://example.org/Car2", "http://example.org/buys", null ], 
    [ "http://example.org/Car1", "http://example.org/buys", null ] 
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
    [ "http://example.org/Car2", "http://example.org/buys", null ], 
    [ "http://example.org/Car1", "http://example.org/buys", null ] 
] 


;; IDEA: INSTEAD OF USING from named JUST NAME THE GRAPH !

;; QUERY 10
;; querying only graph :Buying seems like an easy fix
;; but returns results from other graphs as well
prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
select ?graph ?does  ?age 
where { 
   graph :Buying { :Alice ?does ?what } 
   OPTIONAL { ?graph  ?prop [ :age ?age ] .}
}
[
    [ "http://example.org/Car1", "http://example.org/buys", 12 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car2", "http://example.org/buys", 42 ],
    [ "http://example.org/Car2", "http://example.org/buys", 0 ],
    [ "http://example.org/Band1", "http://example.org/buys", 12 ],
    [ "http://example.org/Sports1", "http://example.org/buys", 15 ]
]

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
    [ null, "http://example.org/buys", 42 ],
    [ null, "http://example.org/buys", 0 ]
] 

;; QUERY 12
;; inlining the optional into :Buying should do the trick
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
    [ "http://example.org/Car1", "http://example.org/buys", 12 ],
    [ "http://example.org/Car1", "http://example.org/buys", 22 ],
    [ "http://example.org/Car2", "http://example.org/buys", 42 ],
    [ "http://example.org/Car2", "http://example.org/buys", 0 ]
] 
;; but with an udate to the data, removing all mentions of :age from :Car1
@base <http://dydra.com/> .
@prefix : <http://example.org/> .
:Alice {
    :Buying {
        { :Car1 | :Alice :buys :Car . } 
            :object [ :type :Sedan ; 
                      :reason :Ambition ] .
        { :Car2 | :Alice :buys :Car . } 
            :subject [ :age 42 ] ; 
            :object [ :age 0 ; 
                      :type :Coupe ] ; 
            :relation [ :reason :Fun ].
    } .
    { :Loving |
        { :Band1 | :Alice :loves :SuzieQuattro . }
            :subject [ :age 12 ]  .
    }  :reason :Fun .
    { :Doing |
        { :Sports1 | :Alice :plays :Tennis . } 
            :subject [ :age 15 ] ; 
            :predicate [ :level :Beginner ] .
    } :reason :Ambition.
}.
;; the results are missing :Car1 completely
[
  [ "http://example.org/Car2", "http://example.org/buys", 42 ],
  [ "http://example.org/Car2", "http://example.org/buys", 0 ]
] 
