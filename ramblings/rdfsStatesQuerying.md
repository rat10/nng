#### Does having both `rdf:reifies` and `rdfs:states` increase querying complexity?

Assuming we have two properties, `rdf:reifies`and `rdfs:states` instead of only `rdf:reifies`. Does then querying get more complicated? `rdf:reifies`, as per the current semantics, refers to propositions, i.e. hypothetical statements, and takes strictly no stance w.r.t. those propositions actually occurring as triples in a graph or not. `rdfs:states` on the other hand implies the existence of the annotated triple, and takes care to ensure that existence by syntactic sugar and appropriate mappings, just short of proper entailment (and its meaning in the absence of the "entailed" triple is undefined, just like an incomplete rdf:List construct has no defined meaning). 

For example, Alice, suffering from a long commute, was faced with the decision to either buy a car or resettle closer to her work place. She did the former:
```ttl
:Alice :buys :Car {| :reason :LongCommute |} .
<< :Alice :buys :House >> :reason :ShortCommute . 
```
In N-Triples with only `rdf:reifies` that translates to 
```ttl
:Alice :buys :Car.
_:r rdf:reifies <<( :Alice :buys :Car )>> .
_:r :reason :LongCommute .
_:p rdf:reifies <<( :Alice :buys :House )>> .
_:p :reason :ShortCommute .
```

Querying for facts and eventual (i.e. optional) annotations on both propositions and facts with annotation syntax:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL
    { :Alice :buys ?o {| ?ap ?ao |} . }
  OPTIONAL
    { << :Alice :buys ?o >> ?ap ?ao . }
}
```

Alternatively, if one is aware of the underlying N-Triples structure:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL {
    _:r rdf:reifies <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
    }
}
```

Or, when the interest is focused on triples that are asserted in a graph and optionally their annotations:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL {
     :Alice :buys ?o .
    _:r rdf:reifies <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
    }
}
```

The last aspect seems to be the easiest to compare to a more elaborate design with both `rdf:reifies` and `rdfs:states`.
The more involved ones are instructive: it may not come cheap to capture all nuances of a statement that may be asserted or not, and may have annotations or not. However, I may have gotten the queries wrong - please correct my use of OPTIONAL clauses if necessary.


Now let's compare this to a design that offers both `rdf:reifies` and `rdfs:states`, as described in the introduction to this comment (and in the opening comment of this topic). In the example the syntactic sugar version remains unchanged, but the N-Triples representation differs:
```ttl
:Alice :buys :Car {| :reason :LongCommute |} .
<< :Alice :buys :House >> :reason :ShortCommute . 
```
In N-Triples with only `rdf:reifies` that translates to 
```ttl
:Alice :buys :Car.
_:s rdfs:states<<( :Alice :buys :Car )>> .
_:s :reason :LongCommute .
_:r rdf:reifies <<( :Alice :buys :House )>> .
_:r :reason :ShortCommute .
``` 

Again, let's start with querying for facts and annotations on both propositions and facts, and lets use annotation syntax:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL
    { :Alice :buys ?o {| ?ap ?ao |} }
  OPTIONAL
    { << :Alice :buys ?o >> ?ap ?ao }
}
```
There is no difference, and that's by design: the annotation syntax remains unchanged.

Alternatively, if one is aware of the underlying N-Triples structure:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL {
    _:r _:rs <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
    }
}
```
As can be seen it is very easy to query for both `rdf:reifies` and `rdfs:states`, or any other relation for that matter. Instead of the blank node `_:rs` one could also use a path expression `rdf:reifies|rdfs:states` if more properties than `rdf:reifies` and `rdfs:states` are expected to refer to triple terms and are to be excluded from the result.

The most interesting question is probably if the last query from above gets more complicated, namely the query written under the assumption that only facts and optionally their annotations should be returned, but mere annotated proposition should not:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL {
    _:r rdfs:states  <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
}
```
This is actually a tad easier than the with a design that doesn't provide `rdfs:states`. This was actually surprising to me at first, but after a little thinking it seems natural.

One might also use a variable in place of `rdf:reifies` and `rdfs:states`to return if the annotation refers to a triple or a proposition:
```ttl
SELECT ?o ?stated ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL {
    _:r  ?stated <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
}
```
I'm not the master SPARQLer, and I'm happy to get corrections. 

However, so far I can see no noteworthy added complexity in formulation nor execution of queries from adding `rdfs:states` and mapping the annotation syntax to it, rather to the contrary. IMO we have a clear winner.



<hr>

When jotting this down I stumbled over another aspect: what if the annotated triple is undisputed, but the annotation itself is of questionable certainty. It seems to me that the current design can't disambiguate between confirmed and unconfirmed annotations on a triple in the graph, whereas the combination of `rdf:reifies` and `rdfs:states`can. Or am I reading too much into this?

E.g., assuming that we want to express that Alice bought a car for commuting to work, but we are not sure about how much she payed:

```ttl
:Alice :buys :Car {| :purpose :Commuting |} .
<< :Alice :buys :Car >> :price 20000 .
```
In N-Triples with both `rdf:reifies`and `rdfs:states` that becomes 
```
:Alice :buys :Car .
_:s rdfs:states <<( :Alice :buys :Car )>> .
_:s :purpose :Commuting .
_:r rdf:reifies  <<( :Alice :buys :Car )>> .
_:r :price 20000 .
```

Querying for all facts about what Alice buys, annotated or not:
```ttl
SELECT ?o ?ap ?ao WHERE {
    {:Alice :buys ?o . }
  OPTIONAL
    { :Alice :buys ?o {| ?ap ?ao |} }
}
```
Querying for all facts and propositions about what Alice buys, annotated or not:
```ttl
SELECT ?o ?ap ?ao WHERE {
    {:Alice :buys ?o . }
  OPTIONAL
    { :Alice :buys ?o {| ?ap ?ao |} }
  OPTIONAL
    { << :Alice :buys ?o  >> :ap :ao . }
}
```
Alternatively, if one is aware of the underlying N-Triples structure:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL 
    { _:b _:rs <<( :Alice :buys ?o )>> ;      # _:rs stands in for rdf:reifies and rdfs:states
        ?ap ?ao . }
}
```










