#   to retrieve annotations on a statement
##  see how rdf-star maps syntax to triples (including triple terms, ug)

        ?s ?p ?o {| ?a ?b |}

        i.e.

        ?s ?p ?o
        _:r rdf:reifies <<( ?s ?p ?o )>> ;
            ?a ?b .

##  with nested graphs

        ?s ?p ?o . ©?>[ ?a ?b ]

        i.e.

        ?g { ?s ?p ?o }
        ?g ?a ?b 

        or, if we inline © annotations

        ?g { ?s ?p ?o .
             ?g ?a ?b }

        or, if we also cater for term annotations

        ?g { ?s ?p ?o .
             ?g ?a ?b .
             ?g#s ?c ?d .
             ?g#p ?e ?f .
             ?g#o ?h ?i . }

    same, but more correct with OPTIONAL and UNION
        
        SELECT   ?s ?p ?o
                 ?g ?a ?b
                 ?g#s ?c ?d
                 ?g#p ?e ?f
                 ?g#o ?h ?i 
        WHERE {
            ?g { ?s ?p ?o .
                 OPTIONAL {         # searching for annotations inside the graph only
                     { ?g ?a ?b } 
                     UNION 
                     { ?g#s ?c ?d } 
                     UNION 
                     { ?g#p ?e ?f } 
                     UNION 
                     { ?g#o ?h ?i } 
                 }
            }
        }



#   recursively
##  with nested graphs (missing OPTIONAL)

        ?s ?p ?o . ©?*>[ ?a ?b ]

        i.e.

        ?g { ?s ?p ?o }
        ?g ng:in* ?ng              # a path of zero or more - a graph is nested in itself
        ?ng ?a ?b                  # therefore this also returns annotations on ?g

    second try (now with OPTIONAL):

        SELECT   ?s ?p ?o
                 ?g ?a ?b
                 ?g#s ?c ?d
                 ?g#p ?e ?f
                 ?g#o ?h ?i 
                 ?ng ?na ?nb
        WHERE {
            ?g { ?s ?p ?o .
                 OPTIONAL {        # graph & term annotations inside the graph
                     { ?g ?a ?b } 
                     UNION 
                     { ?g#s ?c ?d } 
                     UNION 
                     { ?g#p ?e ?f } 
                     UNION 
                     { ?g#o ?h ?i } 
                 }
            }
            OPTIONAL {
                ?g ng:in+ ?ng .    # a path of one or more
                ?ng ?na ?nb .      # no term annotations outside the graph
            }
        }
        


#   to retrieve annotations on terms
##  with nested graphs

        ?s ?p ?o . ©?@>[ ?a ?b ]   # an @ sign signifies qualification of terms

        i.e.

        ?g { ?s ?p ?o }
        ?g ?a ?b 
        ?g ng:onSubject _:bs       # ?g?val=subject ng:as ?g@s
        _:bs ?c ?d                 # ?g@s ?c ?d
        ?g ng:onPredicate _:bp 
        _:bp ?e ?f
        ?g ng:onObject _:bo 
        _:bo ?h ?i


    it would be awfully nice if we could streamline the annotation
    of terms, eg
    instead of
        :g1 { :alice :buys :Car }
        :g1 ng:onSubject _:b .
        _:b :age 18 .
    just write
        :g1 { :alice :buys :Car }
        :g1#subject :age 18 .
    but that would make querying quite a bit harder
    however, we coud at least standardize the naming of the intermediate node
    eg make it that node that we’d like it to be
        :g1 { :alice :buys :Car }
        :g1 ng:onSubject :g1#subject .
        :g1#subject :age 18 .
    (or a "query parameter" instead of a fragment identifier)
        :g1 { :alice :buys :Car }
        :g1 ng:onSubject :g1?term=subject .
        :g1?term=subject :age 18 .
    and let implementations find their way to optimize
    eg milleniumdb might use 3 of its 256 identifier bits reserved for special cases


##  where can annotations go

    a graph
    annotations on that graph 
        anywhere
            ?g ?p ?o
        from within the graph itself (let qualifications go there?)
            ?g { ?g ?p ?o }
        from the surrounding graph
            ?ng ng:includes ?g
            ?ng { ?g ?p ?o }
        from the surounding graph and its ancestors
            ?ng ng:includes* ?g
            ?ng { ?g ?p ?o }
    qualifications on that graph 
        anywhere
        from within the graph itself
        from the surrounding graph


##  where should annotations be placed

    it makes a difference for querying
        if an annotation is stored inside the annotated graph
        or outside, or somewhere else entirely
    it might also make a difference in meaning
        but that is a more intricate problem and should be defered
    but how to control where annotations are stored?
    eg:
        :s ©>[ :a :b ] :p :o . ©:g1>[ :c :d ]
        :g1 :x :y .
    one could place inlined annotations inside the graph
                    and separate annotations in the enclosing graph
        :g1 { :s :p :o .
              :g1 :c :d ;
                  ng:onSubject :g1?v=s .
              :g1?v=s :a :b . }
        :g2 { :g1 ng:nestedIn :g2 ;
                  :x :y . }
    but that would make authoring harder?
    but we could state that 
        preceding an iri with a © 
        makes that annotation go inline
        however, then all © identifiers must be proper iris
        however, that would probably be a good idea anyway      
        wouldn't this pose a problem when answering queries?
            no, because this only concerns disambiguation when parsing
            the index is not concerned 
           (ie no introspection of identifiers needed when querying)
    eg:
        :s ©>[ :a :b ] :p :o . ©:g1>[ :c :d ]
        ©:g1 :e :f .                           # :g1 preceded by ©
        :g1 :x :y .                            # :g1 not preceded by ©
    would map to
        :g1 { :s :p :o .
              :g1 :c :d ;
                  :e :f ;                      # annotation inline
                  ng:onSubject :g1?v=s .
              :g1?v=s :a :b . }
        :g2 { :g1 ng:nestedIn :g2 ;
                  :x :y . }                    # annotation not inline


#   annotated results

    we need to find a way to add annotations to results 
    even if they haven't explicitly been asked for
    or at least hint at their existance and make them retrievable
    in a second step, i.e. as an afterthought

    this should be possible by wrapping the main query into a subquery
    constructing a result set that documents the graphs in which these results where found
    and then document annotations to those graphs 
    as far as they concern the subquery results


