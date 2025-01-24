the basic mechanism now works:

the following document

curl -X PUT https://seg/test/service -H "Content-Type: application/trig" <<EOF
prefix : <http://example.org/> 
prefix nng: <http://nested-named-graph.org/>
[]{ :nestedSubject :nestedPredicate "default nested anonymous object" }
[nng:NestedGraph]{ :nestedSubject :nestedPredicate "explicit nested anonymous object" }
[nng:Quote]{ :quotedSubject :quotedPredicate "o" }
[nng:Report]{ :reportSubject :reportPredicate "o" }
[nng:Record]{ :recordSubject :recordPredicate "o" }
[nng:GraphLiteral]{ :literalSubject :literalPredicate "o" }
EOF

is to be stored as

root@de17 /opt/spocq # dydra-export -o application/n-quads seg/test
<http://example.org/nestedSubject>   <http://example.org/nestedPredicate>          "default nested anonymous object"   _:b16 .
<http://example.org/nestedSubject>   <http://example.org/nestedPredicate>          "explicit nested anonymous object"  _:graph-18 .
<http://example.org/quotedSubject>   <http://example.org/quotedPredicate>          "o"                                 _:graph-19 .
<http://example.org/reportSubject>   <http://example.org/reportPredicate>          "o"                                 _:graph-20 .
<http://example.org/recordSubject>   <http://example.org/recordPredicate>          "o"                                 _:graph-21 .
<http://example.org/literalSubject>  <http://example.org/literalPredicate>         "o"                                 _:graph-22 .
<urn:dydra:default>                  <http://nested-named-graph.org/transcludes>  _:b16                                <http://nested-named-graph.org/embeddings> .
<urn:dydra:default>                  <http://nested-named-graph.org/transcludes>  _:graph-18                           <http://nested-named-graph.org/embeddings> .
<urn:dydra:default>                  <http://nested-named-graph.org/quotes>       _:graph-19                           <http://nested-named-graph.org/embeddings> .
<urn:dydra:default>                  <http://nested-named-graph.org/reports>      _:graph-20                           <http://nested-named-graph.org/embeddings> .
<urn:dydra:default>                  <http://nested-named-graph.org/records>      _:graph-21                           <http://nested-named-graph.org/embeddings> .
<urn:dydra:default>                  <http://nested-named-graph.org/includes>     _:graph-22                           <http://nested-named-graph.org/embeddings> .
<http://example.org/defaultSubject>  <http://example.org/defaultPredicate>         "default object" .

[nb. the parser does not yet put the graph relations in a special graph.]

simple cases of sparql with both FROM and FROM INCLUDED produce the intended results.
the first variants include the graphs of the respective type in the effective default graph.
the second variants make them available by transclusion from the dataset's default graph.

* (loop for class in '("Quote" "Report" "Record" "NestedGraph" "GraphLiteral")
 collect (list class
               (spocq.i::test-sparql (format nil "
prefix : <http://example.org/>  prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from nng:~a
where { ?s ?p ?o }" class)
                                     :repository-id "seg/test")))
(("Quote"
 ((<http://example.org/quotedSubject> <http://example.org/quotedPredicate>
   "o")))
("Report"
 ((<http://example.org/reportSubject> <http://example.org/reportPredicate>
   "o")))
("Record"
 ((<http://example.org/recordSubject> <http://example.org/recordPredicate>
   "o")))
("NestedGraph"
 ((<http://example.org/nestedSubject> <http://example.org/nestedPredicate>
   "default nested anonymous object")
  (<http://example.org/nestedSubject> <http://example.org/nestedPredicate>
   "explicit nested anonymous object")))
("GraphLiteral"
 ((<http://example.org/literalSubject> <http://example.org/literalPredicate>
   "o"))))
* (loop for class in '("Quote" "Report" "Record" "NestedGraph" "GraphLiteral")
 ;;for i below 1
 collect (list class
               (spocq.i::test-sparql (format nil "
prefix : <http://example.org/>  prefix nng: <http://nested-named-graph.org/>
select ?s ?p ?o
from included nng:~a
where { ?s ?p ?o }" class)
                                     :repository-id "seg/test")))
(("Quote"
 ((<http://example.org/quotedSubject> <http://example.org/quotedPredicate>
   "o")
  (<http://example.org/defaultSubject> <http://example.org/defaultPredicate>
   "default object")))
("Report"
 ((<http://example.org/reportSubject> <http://example.org/reportPredicate>
   "o")
  (<http://example.org/defaultSubject> <http://example.org/defaultPredicate>
   "default object")))
("Record"
 ((<http://example.org/recordSubject> <http://example.org/recordPredicate>
   "o")
  (<http://example.org/defaultSubject> <http://example.org/defaultPredicate>
   "default object")))
("NestedGraph"
 ((<http://example.org/nestedSubject> <http://example.org/nestedPredicate>
   "default nested anonymous object")
  (<http://example.org/nestedSubject> <http://example.org/nestedPredicate>
   "explicit nested anonymous object")
  (<http://example.org/defaultSubject> <http://example.org/defaultPredicate>
   "default object")))
("GraphLiteral"
 ((<http://example.org/literalSubject> <http://example.org/literalPredicate>
   "o")
  (<http://example.org/defaultSubject> <http://example.org/defaultPredicate>
   "default object"))))



---
james anderson | james@dydra.com | https://dydra.com





# included graphs 26.11.23 22:10

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
 :s :p :o  .
 << :h :i :j >> :k :l , :m  .
"))
(
(triple <http://example.org/s>      <http://example.org/p>                          <http://example.org/o>)
(quad   <http://example.org/h>      <http://example.org/i>                          <http://example.org/j>      <_:graph-star-17>)
(triple <_:graph-star-17>           <http://example.org/k>                          <http://example.org/l>)
(triple <_:graph-star-17>           <http://example.org/k>                          <http://example.org/m>)
(quad   <urn:dydra:default>         <http://nested-named-graph.org/transcludes>     <_:graph-star-17>           <http://nested-named-graph.org/embeddings>)
)

(pprint-sse (parse-trig-star "
prefix : <http://example.org/>
 :s :p :o  .
 << :h :i :j >> :k :l , :m  .
"))
(
(triple <http://example.org/s>  <http://example.org/p>                          <http://example.org/o>)
(quad   <http://example.org/h>  <http://example.org/i>                          <http://example.org/j>      <_:graph-star-17>)
(triple <_:graph-star-17>       <http://example.org/k>                          <http://example.org/l>)
(triple <_:graph-star-17>       <http://example.org/k>                          <http://example.org/m>)
(quad   <urn:dydra:default>     <http://nested-named-graph.org/transcludes>     <_:graph-star-17>           <http://nested-named-graph.org/embeddings>)
)

# included graphs 27.11.23 00:16
* (pprint-sse (parse-trig-star "
prefix : <http://example.org/>
 :s :p :o  .
 :g { << :h :i :j >> :k :l , :m  . }
"))
(
(triple <http://example.org/s>  <http://example.org/p>                          <http://example.org/o>)
(quad   <urn:dydra:default>     <http://nested-named-graph.org/transcludes>     <http://example.org/g>  <http://nested-named-graph.org/embeddings>)
(quad   <http://example.org/h>  <http://example.org/i>                          <http://example.org/j>  <_:graph-star-20>)
(quad   <_:graph-star-20>       <http://example.org/k>                          <http://example.org/l>  <http://example.org/g>)
(quad   <_:graph-star-20>       <http://example.org/k>                          <http://example.org/m>  <http://example.org/g>)
(quad   <http://example.org/g>  <http://nested-named-graph.org/quotes>          <_:graph-star-20>       <http://nested-named-graph.org/embeddings>)
(quad   <http://example.org/h>  <http://example.org/i> <http://example.org/j>   <_:graph-star-20>))