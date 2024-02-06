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
;; elaborate nesting needs to be aware of full graph structure
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
    "http://example.org/leases",    ;; leases is correct
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
    "http://example.org/Loving",                ;; Loving
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
    "http://example.org/Band1",                 ;; Band1
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
    "http://example.org/Loving",                ;; Loving
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
  [ "http://example.org/Car1", "http://example.org/buys", 22 ],
  [ "http://example.org/Car1", "http://example.org/buys", 12 ],
  [ "http://example.org/Car2", "http://example.org/leases", 0 ],
  [ "http://example.org/Car2", "http://example.org/leases", 42 ],
  [ "http://example.org/Band1", "http://example.org/loves", 12 ],
  [ "http://example.org/Movie1", "http://example.org/hypes", 17 ],
  [ "http://example.org/Sports1", "http://example.org/plays", 15 ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
  [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ]
] 


;; QUERY 6
;; compared to 5 inlining OPTIONAL loses the ages
;; so that's probably just plain wrong SPARQL-wise
;; does return the quoted movie

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
    [ "http://example.org/Movie1", "http://example.org/hypes", null ],        ;; returns the quoted movie 
    [ "http://example.org/Sports1", "http://example.org/plays", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ],
    [ "http://nngraph.org/embeddings", "http://nngraph.org/asserts", null ]  
                                                                              ;; but doesn't list the quoted embedding
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
;; doesn't retrieve the quoted movie

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

;; QUERY 10
;; querying only graph :Buying seems like an easy fix
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






