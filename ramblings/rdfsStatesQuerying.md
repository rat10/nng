#### Does having both `rdf:reifies` and `rdfs:states` increase querying complexity?

Assuming we have two properties, `rdf:reifies`and `rdfs:states` instead of only `rdf:reifies`, does querying get more complicated? `rdf:reifies`, as per the current semantics, refers to propositions, i.e. hypothetical statements, and takes strictly no stance w.r.t. those propositions actually occurring as triples in a graph or not. `rdfs:states` on the other hand implies the existence of the annotated triple, and takes care to ensure that existence by syntactic sugar and appropriate mappings, just short of proper entailment (and its meaning in the absence of the "entailed" triple is undefined, just like an incomplete rdf:List construct has no defined meaning). 

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
    { :Alice :buys ?o {| ?ap ?ao |} }
  OPTIONAL
    { << :Alice :buys ?o >> ?ap ?ao }
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
Interestingly, this IMHO looks less involved then the syntactic sugar in the preceding query.

Or if it's not important if the annotated proposition is asserted in a graph:
```ttl
SELECT ?o ?ap ?ao WHERE {
    _:r rdf:reifies <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
}
```
The last aspect is the easiest to compare to a more elaborate design with both `rdf:reifies` and `rdfs:states`, but the more involved ones are instructive: it may not come cheap to capture all nuances of a statement that may be asserted or not, and may have annotations or not. However, I may have gotten the queries wrong - please correct my use of OPTIONAL clauses if necessary.


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

Again, let's start with querying for facts and annotations on both propositions and facts with annotation syntax:
```ttl
SELECT ?o ?ap ?ao WHERE {
    :Alice :buys ?o .
  OPTIONAL
    { :Alice :buys ?o {| ?ap ?ao |} }
  OPTIONAL
    { << :Alice :buys ?o >> ?ap ?ao }
}
```
There is no difference, and it would have been very surprising if there was.

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

The most interesting question is probably if the simplest query from above gets more complicated, namely the query written under the assumption that it's not important if the annotated proposition is asserted in a graph:
```ttl
SELECT ?o ?ap ?ao WHERE {
    _:r _ .rs  <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
}
```

Or, when the result should include if (or how) the annotation refers to a triple or a proposition:
```ttl
SELECT ?o ?stated ?ap ?ao WHERE {
    _:r  ?stated <<( :Alice :buys ?o )>> ;
        ?ap ?ao .
}
```
IMO this is really only minimally more involved than the current proposal, but much more expressive. 

The current proposal would certainly require more effort to disambiguate annotations on propositions from those on triples.
TODO investigate/prove



I'm not the master SPARQLer, and I'm happy to get corrections. 
However, so far I can see no noteworthy added complexity in formulation nor execution of queries from adding `rdfs:states` and mapping the annotation syntax to it. However, the expressiveness of a solution with both properties is much higher, and it ensures the clear separation between propositions and triples that we already have in theory and that the annotation syntax and the illustrations for 1.2 Primer and Concepts drafts suggest. IMO we have a clear winner.



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










