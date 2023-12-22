### quad references : graph-level metadata

this example addresses the concern in https://github.com/w3c/rdf-ucr/issues/18,
"Representing triple origin information during Federated SPARQL querying",
which relates to "@Graph-level metadata" (https://w3c.github.io/rdf-star/UCR/rdf-star-ucr.html#graphmetadacombination).

it is possible to represent the annotation through nested graphs

      :x  { :s :p :o .  :y { : s :p :o }  } :federatedSource "http://some-source"
