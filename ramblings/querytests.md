# querying over different graphs


## example data

```turtle
    :Alice {
        :Buying {
            :Car1 {
                :Alice :buys :Car .
            } :subject [ :age 22 ] ;
            :object [ :age 12 ;
                      :type :Sedan ;
                      :reason :Ambition ] .
            :Car2 {
                :Alice :buys :Car .
            } :subject [ :age 42 ] ;
              :object [ :age 0 ;
                        :type :Coupe ] ;
              :relation [ :reason :Fun ].
        } .
        :Loving {
            :Band1 {
                :Alice :loves :SuzieQuattro ;
            } :subject [ :age 12 ] .
        } :reason :Fun .
        :Doing {
            :Sports1 {
                :Alice :plays :Tennis .
            } :subject [ :age 15 ] ;
              :predicate [ :level :Beginner ] .
        } :reason :Ambition .
    } .
```


berlinnew:bgp-provenance james$ curl_graph_store_get
curl -s -f -H Accept: application/n-quads -X GET -u :eSIIxfVi29v2lfiyzUAB https://dydra.com:8443/seg/test/service?user_id=-bash

##### without :reason :Fun|:Ambition

<urn:dydra:default> <http://nngraph.org/asserts> <http://example.org/Alice> <http://nngraph.org/embeddings> .

<http://example.org/Alice>      <http://nngraph.org/asserts>    <http://example.org/Buying>                         <http://nngraph.org/embeddings> .
<http://example.org/Buying>     <http://nngraph.org/asserts>    <http://example.org/Car1>                           <http://nngraph.org/embeddings> .
<http://example.org/Buying>     <http://nngraph.org/asserts>    <http://example.org/Car2>                           <http://nngraph.org/embeddings> .


<http://example.org/Alice>      <http://example.org/buys>       <http://example.org/Car>                            <http://example.org/Car1> .
<http://example.org/Car1>       <http://example.org/subject>    _:o-50                                              <http://example.org/Buying> .
_:o-50                          <http://example.org/age>        "22"^^<http://www.w3.org/2001/XMLSchema#integer>    <http://example.org/Buying> .
<http://example.org/Car1>       <http://example.org/object>     _:o-51                                              <http://example.org/Buying> .
_:o-51                          <http://example.org/type>       <http://example.org/Sedan>                          <http://example.org/Buying> .
_:o-51                          <http://example.org/age>        "12"^^<http://www.w3.org/2001/XMLSchema#integer>    <http://example.org/Buying> .

<http://example.org/Alice>      <http://example.org/buys>       <http://example.org/Car>                            <http://example.org/Car2> .
<http://example.org/Car2>       <http://example.org/subject>    _:o-52                                              <http://example.org/Buying> .
_:o-52                          <http://example.org/age>        "42"^^<http://www.w3.org/2001/XMLSchema#integer>    <http://example.org/Buying> .
<http://example.org/Car2>       <http://example.org/object>     _:o-53                                              <http://example.org/Buying> .
_:o-53                          <http://example.org/type>       <http://example.org/Coupe>                          <http://example.org/Buying> .
_:o-53                          <http://example.org/age>        "0"^^<http://www.w3.org/2001/XMLSchema#integer>     <http://example.org/Buying> .


<http://example.org/Alice>      <http://nngraph.org/asserts>    <http://example.org/Loving>                         <http://nngraph.org/embeddings> .
<http://example.org/Loving>     <http://nngraph.org/asserts>    <http://example.org/Band1>                          <http://nngraph.org/embeddings> .

<http://example.org/Band1>      <http://example.org/subject>    _:o-56 <http://example.org/Loving> .
_:o-56                          <http://example.org/age>        "12"^^<http://www.w3.org/2001/XMLSchema#integer>    <http://example.org/Loving> .
<http://example.org/Alice>      <http://example.org/loves>      <http://example.org/SuzieQuattro>                   <http://example.org/Band1> .


<http://example.org/Alice>      <http://nngraph.org/asserts>    <http://example.org/Doing>                          <http://nngraph.org/embeddings> .
<http://example.org/Doing>      <http://nngraph.org/asserts>    <http://example.org/Sports1>                        <http://nngraph.org/embeddings> .

<http://example.org/Alice>      <http://example.org/plays>      <http://example.org/Tennis>                         <http://example.org/Sports1> .
<http://example.org/Sports1>    <http://example.org/subject>    _:o-59                                              <http://example.org/Doing> .
_:o-59                          <http://example.org/age>        "15"^^<http://www.w3.org/2001/XMLSchema#integer>    <http://example.org/Doing> .
<http://example.org/Sports1>    <http://example.org/predicate>  _:o-60                                              <http://example.org/Doing> .
_:o-60                          <http://example.org/level>      <http://example.org/Beginner>                       <http://example.org/Doing> .



## some lowdown attempt at a query

```sparql
    select ?g ?does ?age
    where 
        ?g { :Alice ?does ?x }
        ?g ?property [ :age ?age ]
        ?age < 16 
```


## proper queries

berlinnew:bgp-provenance james$ bash bgp-provenance.sh
curl -s -f -H Accept: application/n-quads -X GET -u :eSIIxfVi29v2lfiyzUAB https://dydra.com:8443/seg/test/service?user_id=bgp-provenance.sh

prefix : <http://example.org/>  prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select *
#from included nng:Assertion
where {    graph ?g { ?action { { :Alice ?does ?what } :object [ :age ?age ] . } }
}
action,age,does,g,what


prefix : <http://example.org/>  prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select *
#from included nng:Assertion
where {    
    graph ?g { :Alice ?does ?what }
    ?g ?role ?subject . 
    ?subject :age ?age  .
    filter (?age < 16)
}
age,does,g,role,subject,what
0,http://example.org/buys,http://example.org/Car2,http://example.org/object,_:o-53,http://example.org/Car
12,http://example.org/buys,http://example.org/Car1,http://example.org/object,_:o-51,http://example.org/Car
12,http://example.org/loves,http://example.org/Band1,http://example.org/subject,_:o-56,http://example.org/SuzieQuattro
15,http://example.org/plays,http://example.org/Sports1,http://example.org/subject,_:o-59,http://example.org/Tennis


prefix : <http://example.org/>  prefix nng: <http://nngraph.org/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select *
#from included nng:Assertion
where {    
    graph ?g { :Alice ?does ?what }
    ?g ?role [ :age ?age ] .
    filter (?age < 16)
}
age,does,g,role,what



berlinnew:bgp-provenance james$