(in-package :spocq.i)

(defmacro select (&rest args)
  "make the result form execute without results.
  this, in order to make the transcript executable."
  (declare (ignore args))
  (values))
(import '(pprint-sse spocq.i::parse-sparql) :sparql-1-0-4) ;; to support work in that package

;; add a graph term to the rdf vocabulary

#+(or) ;; now in build
(eval-when (:compile-toplevel :load-toplevel :execute)
  (dolist (name '("IRI" "blankNode" "Graph"))
    (export (intern name '"rdf") "rdf"))

  ;; introduce the modified grammar
  (load "patches/ssf-sparql-1-0-6-update-query.lisp"))

*build-revision*
"SEG@e9853d2584aeae248c077309c116ae5e61c1ed58"
*build-timestamp*
"20230828T121753"


;;; parse the simplest query with a bgp match in order to demonstrate the result

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :a :b :c .
}"))
(select (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)) *)

#+(or) (send-response-message :test
                              (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :a :b :c .
}")
                              *trace-output*
                              mime:application/sparql-query+sse)

;;; the goal is to provide a simple way to express graph embedding, transclusion, reference, etc.
;;; on one hand, this suggests to use the '{ }' forms sparql and turtle both already use to group statements and statement patterns.
;;; on the other hand, sparql not only uses them to distinguish bgp arguments to explicit algebra operators,
;;; but also to suggest schematic aspects of the data.
;;; in order to distinguish embedding, those forms must involve additional syntactic features.


;;; nested simple '{ }' statement groups always equate to joins.
;;; their parsed result unrolls them into a single BGP and leaves it to the compiler
;;; to factor and order them into an effective execution plan.
;;; interleaved operators distinguish the respective groups as distinct arguments.

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  {  :s :p :o . 
    { :a :b :c . 
      { :e :f :g } 
} 
} 
}"))
(select
 (bgp (triple <http://example.org/e> <http://example.org/f> <http://example.org/g>)
      (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
      (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  { :a :b :c . } .
  { :e :f :g . :h :i :j }
}"))
(select
 (bgp (triple <http://example.org/e> <http://example.org/f> <http://example.org/g>)
      (triple <http://example.org/h> <http://example.org/i> <http://example.org/j>)
      (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  { :a :b :c . }
  union
  { :e :f :g . :h :i :j }
}"))
(select
 (union (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))
        (bgp (triple <http://example.org/e> <http://example.org/f> <http://example.org/g>)
             (triple <http://example.org/h> <http://example.org/i> <http://example.org/j>)))
 *)


;;; a statement group is combined with a GRAPH keyword to constrain its active query graph.
;;; the constrained group combines with other groups in the same was as a simple group
;;; with no additional keyword, the combination expresses a JOIN operation.

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o .
  GRAPH :g { :a :b :c . }
}"))
(select
 (join
  (graph <http://example.org/g> (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
  (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)))
 *)


;;; additional braces always yield a JOIN expression. succeeding '.' is optional

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  { GRAPH :g { :a :b :c . } }
}"))
(select
 (join
  (graph <http://example.org/g> (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
  (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  { GRAPH :g { :a :b :c . } . }
}"))
(select
 (join
  (graph <http://example.org/g> (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
  (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)))
 *)

;;; for other operations additional braces are required to distinguish the operators arguments

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  { :s :p :o . }
  OPTIONAL
  { GRAPH :g { :a :b :c . } }
}"))
(select
 (leftjoin (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))
           (graph <http://example.org/g>
                  (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))))
 *)


;;; addiional braces with a graph form yields the joins

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  { :l :m :n .
    GRAPH :g { :a :b :c . } .
  }
}"))
(select
 (join
  (join
   (graph <http://example.org/g> (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
   (bgp (triple <http://example.org/l> <http://example.org/m> <http://example.org/n>)))
  (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)))
 *)


;;; the absence of a GRAPH keyword and presence of a graph term prefix
;;; indicates an embedded graph rather than a constrained group

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  :g { :a :b :c . } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  :g { :a :b :c . :e :d :f . } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <http://example.org/e> <http://example.org/d> <http://example.org/f>))))
 *)

;;; the graph term may be a variable

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  ?g { :a :b :c . :e :d :f . } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple ?g
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <http://example.org/e> <http://example.org/d> <http://example.org/f>))))
 (?g))

;;; an initial anonymous blank node is permitted to indicate a non-distinguished variable

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  [] { :a :b :c . :e :d :f . } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:graph-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <http://example.org/e> <http://example.org/d> <http://example.org/f>))))
 *)


;;; the graph term can be an uri reference,
;;; but the identity needs to be defined

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  <http://example.org/g?arg1=1#fragment> { :a :b :c . :e :d :f . } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g?arg1=1#fragment>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <http://example.org/e> <http://example.org/d> <http://example.org/f>))))
 *)


;;; statements may be reordered

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  :g { :a :b :c . } .
  :d :e :f
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))))
 *)


;;; annotations are permitted

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  :g { :a :b :c . } :d :e
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
      (triple <http://example.org/g> <http://example.org/d> <http://example.org/e>))
 *)


;;; additional braces do not affect the nesting

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  { :g { :a :b :c . }}
}"))
(select
 (bgp (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
      (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))
 *)


;;; a nested statement group reduces to the single bgp - as above, but with the nested graph

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o . 
  { :l :m :n .
    :g { :a :b :c . } .
  }
}"))
(select
 (bgp (triple <http://example.org/l> <http://example.org/m> <http://example.org/n>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))
      (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))
 *)



;;; join v/s recursive anonymous graph
(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    { :i :k :l } .
}"))
(select
 (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
      (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))
 *)

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    [] { :i :k :l } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:graph-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>))))
 *)

;;; recursive named graph
(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :g { :i :k :l } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>))))
 *)


;;; the presence of the graph prefix distinguishes named embedded graph from one which is
;;; embedded as an anonymous subject or object formulae

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :g { :i :k :l } :m :n .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <http://example.org/g> <http://example.org/m> <http://example.org/n>))
 *)

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
     { :i :k :l } :m :n .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:formula-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <_:formula-1> <http://example.org/m> <http://example.org/n>))
 *)

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :m :n { :i :k :l }.
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/m> <http://example.org/n> <_:formula-1>)
      (triple <_:formula-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>))))
 *)


(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    { :i :k :l . :x :y :z } :m1 :o1 ; :m2 :n2 .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:formula-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
                   (triple <http://example.org/x> <http://example.org/y> <http://example.org/z>)))
      (triple <_:formula-1> <http://example.org/m1> <http://example.org/o1>)
      (triple <_:formula-1> <http://example.org/m2> <http://example.org/n2>))
 *)


;;; but a named subject or object statement term becomes an annotated included graph
;;; rather than a subject or object embedded graph

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :g { :i :k :l } :m :n .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <http://example.org/g> <http://example.org/m> <http://example.org/n>))
 *)


;;; as object
(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :m :n :g { :i :k :l . :x :y :z } .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/m> <http://example.org/n> <http://example.org/g>)
      (triple <http://example.org/g>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
                   (triple <http://example.org/x> <http://example.org/y> <http://example.org/z>))))
 *)


;;; rdf star syntax is also permitted for statement terms
;;; they are recognized as anonymous embedded formula with the single statement
;;; no name is permitted

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o .
  << :i :k :l  >> :m :n .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:graph-star-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <_:graph-star-1> <http://example.org/m> <http://example.org/n>))
 *)


(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o .
  :m :n << :i :k :l >> .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/m> <http://example.org/n> <_:graph-star-1>)
      (triple <_:graph-star-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>))))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o  .
  << :i :k :l >> :n  << :x :y :z >>.
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:graph-star-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <_:graph-star-1> <http://example.org/n> <_:graph-star-2>)
      (triple <_:graph-star-2>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/x> <http://example.org/y> <http://example.org/z>))))
 *)

(pprint-sse (parse-sparql "
prefix : <http://example.org/>
select *
where {
  :s :p :o  .
  << :i :k :l >> :n  << :x :y << :a :b :c >> >>.
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <_:graph-star-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <_:graph-star-1> <http://example.org/n> <_:graph-star-3>)
      (triple <_:graph-star-3>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/x>
                           <http://example.org/y>
                           (triple <_:graph-star-2>
                                   <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                                   (bgp (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)))))))
 *)


;;; complex nesting forms

(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
:SomeNamedGraph {       #            an RDF 1.1 named graph
    :s :p :o .            # _:id.1
    :a :b :c .            # _:id.1
     { :d :e :f }          # _:id.2     a nested and annotated anonymous singleton graph
         :g :h .          # _:id.1
    :g1 { :i :k :l ;      # _:id.3     recursive nesting
         :m :n .          # _:id.3
       { :o :p :q }        # _:id.4     the same statement twice
           :r :s .        # _:id.3
       { :o :p :q }        # _:id.5
           :t :u ;        # _:id.3
           :v :w . } .    # _:id.3
     [] { :x :y :z }  .     # _:id.6     nested but not annotated graph
    :d :f :g .
} .
}"))
(select
 (bgp (triple <http://example.org/SomeNamedGraph>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
                   (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <_:formula-1>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)))
                   (triple <_:formula-1> <http://example.org/g> <http://example.org/h>)
                   (triple <http://example.org/g1>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
                                (triple <http://example.org/i> <http://example.org/m> <http://example.org/n>)
                                (triple <_:formula-2>
                                        <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                                        (bgp (triple <http://example.org/o> <http://example.org/p> <http://example.org/q>)))
                                (triple <_:formula-2> <http://example.org/r> <http://example.org/s>)
                                (triple <_:formula-3>
                                        <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                                        (bgp (triple <http://example.org/o> <http://example.org/p> <http://example.org/q>)))
                                (triple <_:formula-3> <http://example.org/t> <http://example.org/u>)
                                (triple <_:formula-3> <http://example.org/v> <http://example.org/w>)))
                   (triple <_:graph-4>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/x> <http://example.org/y> <http://example.org/z>)))
                   (triple <http://example.org/d> <http://example.org/f> <http://example.org/g>))))
 *)


(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
:SomeNamedGraph {       #            an RDF 1.1 named graph
    :s :p :o .
    :a :b :c .
    :g1 { :i :k :l } .
    :g2 { :i :k :l  . :g3 { :m :n :o} } .
     { :d :e :f } :g :h .
    :g3 { :m :n :o } :p :q .
    :d :f :g .
} .
}"))
(select
 (bgp (triple <http://example.org/SomeNamedGraph>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
                   (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                   (triple <http://example.org/g1>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
                   (triple <http://example.org/g2>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
                                (triple <http://example.org/g3>
                                        <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                                        (bgp (triple <http://example.org/m> <http://example.org/n> <http://example.org/o>)))))
                   (triple <_:formula-1>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)))
                   (triple <_:formula-1> <http://example.org/g> <http://example.org/h>)
                   (triple <http://example.org/g3>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/m> <http://example.org/n> <http://example.org/o>)))
                   (triple <http://example.org/g3> <http://example.org/p> <http://example.org/q>)
                   (triple <http://example.org/d> <http://example.org/f> <http://example.org/g>))))
 *)


(pprint-sse  (parse-sparql "
prefix : <http://example.org/>
select *
where {
    :s :p :o .
    :a :b :c .
    :g1 { :i :k :l } .
    :g2 { :i :k :l  . :g3 { :m :n :o} } .
    { :d :e :f } :g :h .
    :g3 { :m :n :o } :p :q .
    :d :f :g .
}"))
(select
 (bgp (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
      (triple <http://example.org/d> <http://example.org/f> <http://example.org/g>)
      (triple <http://example.org/g3>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/m> <http://example.org/n> <http://example.org/o>)))
      (triple <http://example.org/g3> <http://example.org/p> <http://example.org/q>)
      (triple <_:formula-1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)))
      (triple <_:formula-1> <http://example.org/g> <http://example.org/h>)
      (triple <http://example.org/g2>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)
                   (triple <http://example.org/g3>
                           <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
                           (bgp (triple <http://example.org/m> <http://example.org/n> <http://example.org/o>)))))
      (triple <http://example.org/g1>
              <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph>
              (bgp (triple <http://example.org/i> <http://example.org/k> <http://example.org/l>)))
      (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))
 *)



;;; trig-star

;;; simple
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :a :b :c . 
"))
((triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))

;;; !!! annotation not unrolled
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :a :b :c {| :d :e |} .
"))
((triple <http://example.org/a>
         <http://example.org/b>
         (:ANNOTATION ((<http://example.org/d> (<http://example.org/e>))) <http://example.org/c>)))

(pprint-sse (parse-trig-star "
BASE <http://example.org/>
  PREFIX : <#>
  :G {
    _:a :name :Alice {| :statedBy :bob |} 
  }"))
((quad <_:a> <http://example.org/#name>
       (:ANNOTATION ((<http://example.org/#statedBy> (<http://example.org/#bob>))) <http://example.org/#Alice>)
       <http://example.org/#G>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :a :b :c . 
  :d :e :f .
  :s :p :o .
"))
((triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
 (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  [ :b :c ] :e :f .
"))
((triple <_:bnpl-5> <http://example.org/b> <http://example.org/c>)
 (triple <_:bnpl-5> <http://example.org/e> <http://example.org/f>))

;;; default graph with toplevel { }
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o .
  { :a :b :c }
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :a :b :c ; :d :e , :f }
"))
((triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (triple <http://example.org/a> <http://example.org/d> <http://example.org/e>)
 (triple <http://example.org/a> <http://example.org/d> <http://example.org/f>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :a :b :c . :d :e :f } 
"))
((triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :a :b :c . :d :e :f } 
  :g { :d :e :f }
"))
((triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <urn:dydra:default>)
 (quad <http://example.org/d> <http://example.org/e> <http://example.org/f> <http://example.org/g>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :a :b :c . :d :e :f } 
  :g { :d :e :f ; :h :i }
"))
((triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <urn:dydra:default>)
 (quad <http://example.org/d> <http://example.org/e> <http://example.org/f> <http://example.org/g>)
 (quad <http://example.org/d> <http://example.org/h> <http://example.org/i> <http://example.org/g>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o  .
  << :h :i :j >> :k :l , :m  .
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (triple <_:graph-star-2> <http://example.org/k> <http://example.org/l>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-2> <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <_:graph-star-2>)
 (triple <_:graph-star-2> <http://example.org/k> <http://example.org/m>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-2> <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <_:graph-star-2>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o  .
  << :h :i :j >> :k  << :l :m :n >>.
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (triple <_:graph-star-13> <http://example.org/k> <_:graph-star-14>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-13> <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <_:graph-star-13>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-14> <urn:dydra:default>)
 (quad <http://example.org/l> <http://example.org/m> <http://example.org/n> <_:graph-star-14>))

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o  .
  << :h :i :j >> :m  << :x :y << :a :b :c >> >>.
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (triple <_:graph-star-16> <http://example.org/m> <_:graph-star-18>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-16> <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <_:graph-star-16>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-18> <urn:dydra:default>)
 (quad <http://example.org/x> <http://example.org/y> <_:graph-star-17> <_:graph-star-18>)
 (quad <_:graph-star-18> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-star-17> <_:graph-star-18>)
 (quad <http://example.org/a> <http://example.org/b> <http://example.org/c> <_:graph-star-17>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o  .
  :g { :i :k :l } :n  :o .
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <urn:dydra:default>)
 (quad <http://example.org/i> <http://example.org/k> <http://example.org/l> <http://example.org/g>)
 (triple <http://example.org/g> <http://example.org/n> <http://example.org/o>))


;;; all in the default graph
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :s :p :o .
  { :a :b :c . :d :e :f } 
  { :d :e :f . :h :i :j }
"))
((triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
 (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (triple <http://example.org/h> <http://example.org/i> <http://example.org/j>)
 (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>))

;;; one default and one nested graph
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :s :p :o . { :h :i :j } }
"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-2> <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <_:graph-2>)
 (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))

;;; then, named with a reference
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  { :d :e :f . :g { :h :i :j } }
"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <urn:dydra:default>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <http://example.org/g>)
 (triple <http://example.org/d> <http://example.org/e> <http://example.org/f>))

;;; then nested named
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
  :g1 { :d :e :f . :g2 { :h :i :j } }
"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g1>
       <urn:dydra:default>)
 (quad <http://example.org/g1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g2>
       <http://example.org/g1>)
 (quad <http://example.org/h> <http://example.org/i> <http://example.org/j> <http://example.org/g2>)
 (quad <http://example.org/d> <http://example.org/e> <http://example.org/f> <http://example.org/g1>))

;;; !!! missing reference
(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
:s { :s :p :o  .
   :a :b :c .
   :g { :i :k :l } :n :o
   }
"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/s>
       <urn:dydra:default>)
 (quad <http://example.org/s> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <http://example.org/s>)
 (quad <http://example.org/i> <http://example.org/k> <http://example.org/l> <http://example.org/g>)
 (quad <http://example.org/g> <http://example.org/n> <http://example.org/o> <http://example.org/s>)
 (quad <http://example.org/a> <http://example.org/b> <http://example.org/c> <http://example.org/s>)
 (quad <http://example.org/s> <http://example.org/p> <http://example.org/o> <http://example.org/s>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
{ :s :p :o  .
  :a :b :c .
  :g { :i :k :l } :n :o .
  :x :y :z}
"))
((triple <http://example.org/x> <http://example.org/y> <http://example.org/z>)
 (quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/g>
       <urn:dydra:default>)
 (quad <http://example.org/i> <http://example.org/k> <http://example.org/l> <http://example.org/g>)
 (triple <http://example.org/g> <http://example.org/n> <http://example.org/o>)
 (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
 (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
:SomeNamedGraph {       #            an RDF 1.1 named graph
    :s :p :o .          # _:id.1
    :a :b :c .          # _:id.1
    :x { :d :e :f }     # _:id.2     a nested and annotated anonymous singleton graph
       :g :h .          # _:id.1
     { :i :k :l  ;      # _:id.3     recursive nesting
          :m :n .       # _:id.3
       { :o :p :q }     # _:id.4     the same statement twice
       :r :s .          # _:id.3
       { :o :p :q }     # _:id.5
       :t :u ;          # _:id.3
       :v :w            # _:id.3
     }
     { :x :y :z }       # _:id.6     nested but not annotated graph
    :d :f :g 
}"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/SomeNamedGraph>
       <urn:dydra:default>)
 (quad <http://example.org/d> <http://example.org/f> <http://example.org/g> <http://example.org/SomeNamedGraph>)
 (quad <http://example.org/SomeNamedGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-8>
       <http://example.org/SomeNamedGraph>)
 (quad <http://example.org/x> <http://example.org/y> <http://example.org/z> <_:graph-8>)
 (quad <http://example.org/SomeNamedGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-7>
       <http://example.org/SomeNamedGraph>)
 (quad <_:graph-7> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-6> <_:graph-7>)
 (quad <http://example.org/o> <http://example.org/p> <http://example.org/q> <_:graph-6>)
 (quad <_:graph-6> <http://example.org/t> <http://example.org/u> <_:graph-7>)
 (quad <_:graph-6> <http://example.org/v> <http://example.org/w> <_:graph-7>)
 (quad <_:graph-7> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-4> <_:graph-7>)
 (quad <http://example.org/o> <http://example.org/p> <http://example.org/q> <_:graph-4>)
 (quad <_:graph-4> <http://example.org/r> <http://example.org/s> <_:graph-7>)
 (quad <http://example.org/i> <http://example.org/k> <http://example.org/l> <_:graph-7>)
 (quad <http://example.org/i> <http://example.org/m> <http://example.org/n> <_:graph-7>)
 (quad <http://example.org/SomeNamedGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/x>
       <http://example.org/SomeNamedGraph>)
 (quad <http://example.org/d> <http://example.org/e> <http://example.org/f> <http://example.org/x>)
 (quad <http://example.org/x> <http://example.org/g> <http://example.org/h> <http://example.org/SomeNamedGraph>)
 (quad <http://example.org/a> <http://example.org/b> <http://example.org/c> <http://example.org/SomeNamedGraph>)
 (quad <http://example.org/s> <http://example.org/p> <http://example.org/o> <http://example.org/SomeNamedGraph>))


(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
:SomeGraph {              #            an RDF 1.1 named graph
    :s :p :o .            # _:id.1
    :a :b :c .            # _:id.1
    :ssg1 { :d :e :f }    # _:id.2     a nested and annotated anonymous singleton graph
          :g :h .         # _:id.1
    :ssg2 { :i :k :l  ;   # _:id.3     recursive nesting
               :m :n .    # _:id.3
            { :o :p :q }  # _:id.4     the same statement twice
            :r :s .       # _:id.3
            { :o :p :q }  # _:id.5
            :t :u ;       # _:id.3
            :v :w         # _:id.3
          }
    { :x :y :z }          # _:id.6     nested but not annotated graph
    :d :f :g 
}"))
((quad <urn:dydra:default> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/SomeGraph>
       <urn:dydra:default>)
 (quad <http://example.org/d> <http://example.org/f> <http://example.org/g> <http://example.org/SomeGraph>)
 (quad <http://example.org/SomeGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-14>
       <http://example.org/SomeGraph>)
 (quad <http://example.org/x> <http://example.org/y> <http://example.org/z> <_:graph-14>)
 (quad <http://example.org/SomeGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/ssg2>
       <http://example.org/SomeGraph>)
 (quad <http://example.org/ssg2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-13>
       <http://example.org/ssg2>)
 (quad <http://example.org/o> <http://example.org/p> <http://example.org/q> <_:graph-13>)
 (quad <_:graph-13> <http://example.org/t> <http://example.org/u> <http://example.org/ssg2>)
 (quad <_:graph-13> <http://example.org/v> <http://example.org/w> <http://example.org/ssg2>)
 (quad <http://example.org/ssg2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <_:graph-11>
       <http://example.org/ssg2>)
 (quad <http://example.org/o> <http://example.org/p> <http://example.org/q> <_:graph-11>)
 (quad <_:graph-11> <http://example.org/r> <http://example.org/s> <http://example.org/ssg2>)
 (quad <http://example.org/i> <http://example.org/k> <http://example.org/l> <http://example.org/ssg2>)
 (quad <http://example.org/i> <http://example.org/m> <http://example.org/n> <http://example.org/ssg2>)
 (quad <http://example.org/SomeGraph> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Graph> <http://example.org/ssg1>
       <http://example.org/SomeGraph>)
 (quad <http://example.org/d> <http://example.org/e> <http://example.org/f> <http://example.org/ssg1>)
 (quad <http://example.org/ssg1> <http://example.org/g> <http://example.org/h> <http://example.org/SomeGraph>)
 (quad <http://example.org/a> <http://example.org/b> <http://example.org/c> <http://example.org/SomeGraph>)
 (quad <http://example.org/s> <http://example.org/p> <http://example.org/o> <http://example.org/SomeGraph>))


