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
   :g1{:a :b :c} :x :y .
   :g1 :u :w .

[TODO] do we still support property lists?
       or dow we reserve the [] syntax for either
       - blank node names
       or
       - semantics declarations, eg
         [APP]{ s p o }


- graph literals
[ nng:quotes ":a :b :c"^^nng:Graph ] a :Nuisance .
:X nng:quotes ":a :b :c"^^nng:Graph a :Necessity .
THIS nng:quotes ":a :b :c"^^nng:Graph  
                          # 'THIS' referring to local graph



	