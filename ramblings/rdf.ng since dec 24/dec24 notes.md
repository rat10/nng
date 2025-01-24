@base <http://example.org/> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:  <http://www.w3.org/2001/XMLSchema#> .
@prefix :     <http://rat.io/> .
@prefix ng:   <http://rdf.ng/> .

:s :p :o ;
   ng:onSub _:s ,
             :ooo ;
   ng:onPrd _:p ;
   ng:onObj _:o .
_:s :m _:n .
_:n :mm :nn .
_:p :u :v .
_:o :w :x ;
    :y :z .
:s2 :p2 _:b2 .
_:b2 :p3 _:b3 .


PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
PREFIX xsd:  <http://www.w3.org/2001/XMLSchema#> .
PREFIX :     <http://rat.io/> .
PREFIX ng:   <http://rdf.ng/> .

SELECT ?s ?p_alias ?o ?b ?c ?mm ?nn WHERE {

    # search for triples
    ?s ?p ?o

    # do not show term annotations
    # FILTER ( ?p NOT IN ( ng:onSub, ng:onPrd, ng:onObj ) )

    # do follow object bnodes 2 levels deep
    OPTIONAL {                  # only follow if object is blank
        FILTER (isBlank(?o))    # use || or && to add patterns
        ?o ?b ?c
        OPTIONAL {              # add one level of indirection
            FILTER (isBlank(?c))
            ?c ?mm ?nn
        }
    }
    
    # don't list level-2 triples independently
    FILTER ( !isBlank(?s) )     

    # define aliases for some properties
    BIND (
       IF ( ?p=ng:onSub, "onSubject" ,
          IF ( ?p=ng:onPrd, "onPredicate" ,
              IF ( ?p=ng:onObj, "onObject" , 
                    STR(?p) 
              )
          )                     # strange nesting construct
       ) AS ?p_alias 
    )
}


----------------------------------------------------------------------------------------------------------------------------------------------------
| s                  | p_alias            | o                   | b                  | c                 | mm                 | nn                 |
====================================================================================================================================================
| <http://rat.io/s2> | "http://rat.io/p2" | _:b0                | <http://rat.io/p3> | _:b1              |                    |                    |
| <http://rat.io/s>  | "onObject"         | _:b2                | <http://rat.io/y>  | <http://rat.io/z> |                    |                    |
| <http://rat.io/s>  | "onObject"         | _:b2                | <http://rat.io/w>  | <http://rat.io/x> |                    |                    |
| <http://rat.io/s>  | "onPredicate"      | _:b3                | <http://rat.io/u>  | <http://rat.io/v> |                    |                    |
| <http://rat.io/s>  | "onSubject"        | <http://rat.io/ooo> |                    |                   |                    |                    |
| <http://rat.io/s>  | "onSubject"        | _:b4                | <http://rat.io/m>  | _:b5              | <http://rat.io/mm> | <http://rat.io/nn> |
| <http://rat.io/s>  | "http://rat.io/p"  | <http://rat.io/o>   |                    |                   |                    |                    |
----------------------------------------------------------------------------------------------------------------------------------------------------
