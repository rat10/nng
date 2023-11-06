# Serialization

The serialization of Semantic Graphs is defined as an extension to TriG. Its datatype is `application/sg`.


- graph annotation
-- anonymous
   []{:a :b :c} :x :y .
   [:x :y]{:a :b :c}       # property list
-- named
   :g1{:a :b :c} :x :y .
   :g1 :u :w .


- graph literals
[ seg:transcludesOpaquely ":a :b :c"^^rdf:ttl ] a :Nuisance .
:X seg:transcludesOpaquely ":a :b :c"^^rdf:ttl a :Necessity .
<.> seg:transcludesOpaquely ":a :b :c"^^rdf:ttl  
                          # '<.>' refering to local graph



	