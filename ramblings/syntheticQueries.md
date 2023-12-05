# Synthetic Queries

To demonstrate querying with nested graphs take the following example NNG:

```turtle
:Z {
    :Y {
        :X { 
            :Dog :eats :Fish .
            THIS :says :Alice ;
                 nng:domain [ :name "Dodger" ]
        } :says :Bob ;
          :believes :Ben .
        :Goat :has :Ideas .
        :Beatrice :claims [] {" :Jake :knows :Larry . 
                                :Larry a :Star . "} .
    } :says :Carol ;
      :believes :Curt ;
      nng:tree :Example .
} :says :Zarathustra  ,
  :source :Source_1 .
```
<!--
:Z {
    :Y {
        :X { 
            :Dog :eats :Fish .
            THIS :says :Alice ;
                 nng:domain [ :name "Dodger"]
        } :says :Bob ;
          :believes :Ben .
>       :W {
>           :Dog :eats :Fish .
>           THIS nng:domain [ :name "Daisy"]
>       } :says :Bart .
        :Goat :has :Ideas .
        :Beatrice :claims [] "{:Jake :knows :Larry . :Larry a :Star .}" .
    } :says :Carol ;
      :believes :Curt ;
      nng:tree :Example .
} :says :Zarathustra  ,
  :source :Source_1 .
-->
<!--
Notes: 
- THIS is important to improve *locality* of annotations
- nng:nested is inherited, it applies to all inner graphs as well
  (but only to graphs, not individual statements or nodes)
-->

> Note
>
> The [fragment identifier](fragmentIdentifiers.md) `nng:tree` is not implemented yet. Its purpose is to annotate a graph and all nested graphs recursively. 

In the following some example queries are given, together with different versions of expected results and the respective query. A complete documentation of Dydra's implementation of the queries and their results plus some comments is available in the [query shell script](tests/syntheticQueries.sh).

Prefix declarations are always
```sparql
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
```

## 1) who *says* ':Dog :eats :Fish .' ?
Expected results are:
```
> :Alice                            # give me only the result(s) from the THIS level
> :Alice :Bob :Carol :Zarathustra   # give me results on all levels of nesting
> :Alice :Bob                       # give me results from the first n=2 levels of nesting
                                    # nesting level count starts with THIS
```
Respective queries are:

### give me only the result(s) from the THIS level
```sparql
select ?who
from included nng:NestedGraph
where {
  { :Dog :eats :Fish . } :says ?who .
}
```
See [query shell script](tests/syntheticQueries.sh) line  ff.


### give me results on all levels of nesting
```sparql
select ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
  { graph ?venue { ?root :says ?orator } }
}
```
See [query shell script](tests/syntheticQueries.sh) starting from line 104 ff, ending in line 163 ff.



### give me results from the first n=2 levels of nesting
nesting level count starts with THIS
```sparql
select ?what ?root ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes{0,1} ?what . } }
  { graph ?root { ?about :says ?orator } }
}
```
See [query shell script](tests/syntheticQueries.sh) line 183 ff.

For the complete example see [query shell script](tests/syntheticQueries.sh) line 39 ff.


## 2) who *believes* ':Dog :eats :Fish .' ?
Expected results are:
```
>                                   # give me only the result(s) from the THIS level
> :Ben :Curt                        # give me results on all levels of nesting
> :Ben                              # give me results from the first n=2 levels of nesting
                                    # nesting level count starts with THIS
```
Respective queries are:

### give me only the result(s) from the THIS level
```sparql

[TODO]
```

### give me results on all levels of nesting
```sparql

select ?orator
from named all
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
  { graph ?venue { ?root :believes ?orator } }
}

```
See [query shell script](tests/syntheticQueries.sh) line 213 ff.

### give me results from the first n=2 levels of nesting
nesting level count starts with THIS
```sparql

select ?orator
from included nng:NestedGraph
where {
  { graph ?what { :Dog :eats :Fish . } }
  { graph ?venue { ?what :believes ?orator } }
}
```
See [query shell script](tests/syntheticQueries.sh) line 246 ff.

For the complete example see [query shell script](tests/syntheticQueries.sh) line 206 ff.


## 3) in which graph(s) occurs ':Goat :has ?o' ?
Expected results are:
```
>                                   # give me only results annotated with THIS
> :Y                                # give me only the nearest graph
> :Y :Z                             # give me all enclosing graphs (Olaf's case 3)
                                    # BUT not the DEFAULT graph, because :Z is not nested 
                                    #   in the default graph
```
Respective queries are:

### give me only results annotated with THIS
```sparql

select ?what
where {
  { graph ?what { :Goat :has ?o . ?what ?annotated ?with} }
}
```
See [query shell script](tests/syntheticQueries.sh) line 274 ff.

### give me only the nearest graph
```sparql

select ?what
where {
  { graph ?what { :Goat :has ?o . } }
}
```
See [query shell script](tests/syntheticQueries.sh) line 288 ff.

### give me all enclosing graphs but NOT the DEFAULT graph
```sparql

select distinct ?what ?root
where {
  { graph ?what { :Goat :has ?o . } }
  { graph nng:embeddings { ?root nng:transcludes* ?what . } }
}
```
See [query shell script](tests/syntheticQueries.sh) line 302 ff.


For the complete example see [query shell script](tests/syntheticQueries.sh) line 264 ff.


## 4) what does Curt believe?
Expected results are:
```
> :Y
```
Respective queries are:
```sparql
[TODO] 
```


## 5) which graphs are of type :Example ?
Expected results are:
```
> :Y :X _:Report1                   # _:Report1 referring to Beatrice' claim
```
Respective queries are:
```sparql
[TODO] 
```


## 6) give me all types
Expected results are:
```
> :Example _:b1                     # the value space of fragment identifiers nng:domain
                                    # and nng:tree is interpreted as class
                                    # _:b1 refers to the dog named "Dodger"
```
Respective queries are:
```sparql
[TODO] 
```


## 7) give me all types including from included graph literals
```
    > :Example, :Star
```
Respective queries are:
```sparql
[TODO] 
```