# a copy of nestedQueries.lisp to check if the workbook is working okay


james, 28.01.24

[...]

the sparql process or changes to align with nng-trig turned out to be non-trivial.

for this version of the sample dataset

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


you proposed a query of the form

prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
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


the particular issue is that the "graph ?who { ... } filter (?age < 16)" clause expresses a basic graph pattern with none of its own statement patterns to be filtered.
the "?action { ... }" is a nested graph, which introduces its own bgp.

the parsed result is a graph form with a bgp which contains just a bgp

(select
    (filter
        (graph ?who
            (bgp 
                (bgp (graph ?action)
                    (bgp (graph <http://nngraph.org/embeddings>) (triple ??PARENT <http://nngraph.org/asserts> ?action))
                    (triple ??GRAPH-ASSERTED-476 <http://example.org/object> ??477)
                    (bgp (graph ??GRAPH-ASSERTED-476)
                        (bgp (graph <http://nngraph.org/embeddings>)
                                (triple ?action <http://nngraph.org/asserts> ??GRAPH-ASSERTED-476)
                        )
                        (triple <http://example.org/Alice> ?does ?what)
                    )
                    (triple ??477 <http://example.org/age> ?age)
                    (triple ??477 <http://example.org/type> ?type)
                )
            )
        )
        (:< ?::age 16)
    )
    (?who ?action ?does ?what ?age ?type)
)

with the eventual proper attention to the filter placement, it expands into

(PROJECT
    (FILTER
        (JOIN
            (JOIN
                (BGP (graph <http://nngraph.org/embeddings>)
                    (triple ?who <http://nngraph.org/asserts> ?action :COUNT 8 :DIMENSIONS (?::who #:constant2379 ?::action))
                )
                (JOIN
                    (JOIN
                        (BGP (graph <http://nngraph.org/embeddings>)
                            (triple ?action
                                    <http://nngraph.org/asserts>
                                    ??GRAPH-ASSERTED-471
                                    :COUNT
                                    8
                                    :DIMENSIONS
                                    (?::action #:constant2380 ?::?GRAPH-ASSERTED-471)
                            )
                        )
                        (BGP (graph ??GRAPH-ASSERTED-471)
                            (triple <http://example.org/Alice> ?does ?what :COUNT 7 :DIMENSIONS (#:constant2381 ?::does ?::what))
                        )
                    )
                    (BGP (graph ?action)
                        (triple ??GRAPH-ASSERTED-471
                                <http://example.org/object>
                                ??472
                                :PREDICATE-COUNT
                                2
                                :COUNT
                                2
                                :DIMENSIONS
                                (?::?GRAPH-ASSERTED-471 #:constant2382 ?::?472)
                        )
                        (triple ??472
                                <http://example.org/type>
                                ?type
                                :PREDICATE-COUNT
                                2
                                :COUNT
                                2
                                :DIMENSIONS
                                (?::?472 #:constant2384 ?::type)
                        )
                        (triple ??472
                                <http://example.org/age>
                                ?age
                                :PREDICATE-COUNT
                                6
                                :COUNT
                                6
                                :DIMENSIONS
                                (?::?472 #:constant2383 ?::age)
                        )
                    )
                )
            )
            (TABLE :DIMENSIONS 'unit)
        )
        '(:< ?age 16)
    )
    '(?who ?action ?does ?what ?age ?type)
)

which does return a reasonable result.

* (test-sparql *q0* :repository-id "seg/test")
(
    (<http://example.org/Alice> <http://example.org/Buying> <http://example.org/buys> <http://example.org/Car> 12 <http://example.org/Sedan>)
    (<http://example.org/Alice> <http://example.org/Buying> <http://example.org/buys> <http://example.org/Car> 0 <http://example.org/Coupe>)
)
(?::|who| ?::|action| ?::|does| ?::|what| ?::|age| ?::|type|)

---
james anderson | james@dydra.com | https://dydra.com