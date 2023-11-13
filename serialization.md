```
 _____ ___  ____   ___  
|_   _/ _ \|  _ \ / _ \ 
  | || | | | | | | | | |
  | || |_| | |_| | |_| |
  |_| \___/|____/ \___/ 
                        

```

# Serialization

The serialization of Nested Named Graphs is defined as an extension to TriG. Its datatype is `application/nng`.


- graph annotation
-- anonymous
   []{:a :b :c} :x :y .
   [:x :y]{:a :b :c}       # property list
-- named
   :g1 {:a :b :c} 
       :x :y .             # defining and annotating a graph in one sweep
   :f :m :n .
   :g1 :u :w .             # annotating the graph independent from its definition

[TODO] do we still support property lists?
       or dow we reserve the [] syntax for either
       - blank node names
       or
       - semantics declarations, eg
         [APP]{ s p o }


- graph literals
[ nng:quotes ":a :b :c"^^nng:GraphLiteral ] a :Nuisance .
:X nng:quotes ":a :b :c"^^nng:GraphLiteral a :Necessity .
THIS nng:quotes ":a :b :c"^^nng:GraphLiteral  
                          # 'THIS' referring to the local graph



	