(in-package :spocq.i)

;; add a graph term to the rdf vocabulary

* (eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (name '("IRI" "blankNode" "Graph"))
    (export (intern name '"rdf") "rdf")))


;; introduce the modified grammar

* (load "patches/ssf-sparql-1-0-6-update-query.lisp")


;; single '{ }' embedding conflicts with sparql bgp syntax

* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  {  :s :p :o . 
    { :a :b :c . 
      { :e :f :g } 
} 
} 
}"))
(select
 (bgp
   {<http://x.org/e> <http://x.org/f> <http://x.org/g>}
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>}
   {<http://x.org/s> <http://x.org/p> <http://x.org/o>})
 COMMON-LISP:NIL)


;; double works

* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  { { :s :p :o . 
    { { :a :b :c . 
      { { :e :f :g } } } } } }
}"))
(select
    (bgp
        {<http://x.org/s> <http://x.org/p> <http://x.org/o>}
        {<_:graph-2> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph 
            (bgp 
                (triple <http://x.org/a> <http://x.org/b> <http://x.org/c>) 
                (triple <_:graph-1> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph 
                    (bgp 
                        (triple <http://x.org/e> <http://x.org/f> <http://x.org/g>))
                )
            )
        }
    )
 COMMON-LISP:NIL)


* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  :a :b :c .
}"))
(select
 (bgp
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>})
 COMMON-LISP:NIL)


* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  :a :b :c .
  { { :e :f :g } }
}")
(select
 (bgp
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>}
   {<_:graph-1> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/e> <http://x.org/f> <http://x.org/g>))})
 COMMON-LISP:NIL)


* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  :a :b :c .
  { :aGraph { :e :f :g } }
}"))
(select
 (bgp
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>}
   {<http://x.org/aGraph> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/e> <http://x.org/f> <http://x.org/g>))})





* (spocq.i::pprint-sse  (parse-sparql "
prefix : <http://x.org/>
select *
where {
{ :SomeNamedGraph {       #            an RDF 1.1 named graph
    :s :p :o .            # _:id.1
    :a :b :c .            # _:id.1
    { :d :e :f }          # _:id.2     a nested and annotated anonymous singleton graph
         :g :h .          # _:id.1
    {{ :i :k :l ;          # _:id.3     recursive nesting
         :m :n .          # _:id.3
      { :o :p :q }        # _:id.4     the same statement twice
           :r :s .        # _:id.3
      { :o :p :q }        # _:id.5
           :t :u ;        # _:id.3
           :v :w . }}      # _:id.3
   # {{ :x :y :z }}          # _:id.6     nested but not annotated graph
} }
}"))
(select
 (bgp
   {<http://x.org/SomeNamedGraph> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/s> <http://x.org/p> <http://x.org/o>) (triple <http://x.org/a> <http://x.org/b> <http://x.org/c>) (triple (bgp (triple <http://x.org/d> <http://x.org/e> <http://x.org/f>)) <http://x.org/g> <http://x.org/h>) (triple <_:graph-1> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/i> <http://x.org/k> <http://x.org/l>) (triple <http://x.org/i> <http://x.org/m> <http://x.org/n>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/r> <http://x.org/s>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/t> <http://x.org/u>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/v> <http://x.org/w>))))})
 COMMON-LISP:NIL)


;; some this do not work
;; this does to bgp syntax ambiguity

* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  { :g { :a :b :c } }
}"))
(select
 (bgp
   {<http://x.org/g> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/a> <http://x.org/b> <http://x.org/c>))})
 COMMON-LISP:NIL)
* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  { { :a :b :c } }
}"))
(select
 (bgp
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>})
 COMMON-LISP:NIL)


;; rdf star syntax is also permitted for statement terms

* (spocq.i::pprint-sse (parse-sparql "
prefix : <http://x.org/>
select *
where {
  :a :b :c .
  << :e :f :g >> :m :n
}"))
(select
 (bgp
   {<http://x.org/a> <http://x.org/b> <http://x.org/c>}
   {(bgp (triple <http://x.org/e> <http://x.org/f> <http://x.org/g>)) <http://x.org/m> <http://x.org/n>})
 COMMON-LISP:NIL)


;; a trailing graph fails to parse

* (spocq.i::pprint-sse  (parse-sparql "
prefix : <http://x.org/>
select *
where {
{ :SomeNamedGraph {       #            an RDF 1.1 named graph
    :s :p :o .            # _:id.1
    :a :b :c .            # _:id.1
    { :d :e :f }          # _:id.2     a nested and annotated anonymous singleton graph
         :g :h .          # _:id.1
    {{ :i :k :l ;          # _:id.3     recursive nesting
         :m :n .          # _:id.3
      { :o :p :q }        # _:id.4     the same statement twice
           :r :s .        # _:id.3
      { :o :p :q }        # _:id.5
           :t :u ;        # _:id.3
           :v :w . }}      # _:id.3
    {{ :x :y :z }}          # _:id.6     nested but not annotated graph
} }
}"))
(select
 (bgp
   {<http://x.org/SomeNamedGraph> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/s> <http://x.org/p> <http://x.org/o>) (triple <http://x.org/a> <http://x.org/b> <http://x.org/c>) (triple (bgp (triple <http://x.org/d> <http://x.org/e> <http://x.org/f>)) <http://x.org/g> <http://x.org/h>) (triple <_:graph-1> |http://www.w3.org/1999/02/22-rdf-syntax-ns#|:Graph (bgp (triple <http://x.org/i> <http://x.org/k> <http://x.org/l>) (triple <http://x.org/i> <http://x.org/m> <http://x.org/n>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/r> <http://x.org/s>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/t> <http://x.org/u>) (triple (bgp (triple <http://x.org/o> <http://x.org/p> <http://x.org/q>)) <http://x.org/v> <http://x.org/w>))))})
 COMMON-LISP:NIL)

debugger invoked on a ORG.DATAGRAPH.SPOCQ.EVALUATION:MESSAGE-SYNTAX-ERROR in thread
#<THREAD "main thread" RUNNING {1001088103}>:
  While processing, an error was signaled: Invalid message received :
failed to parse after '{' at offset 606 on line 29.


