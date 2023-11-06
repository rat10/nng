# Examples

TBD

## WG Use Cases
    https://github.com/w3c/rdf-ucr/wiki/Summary

## provenance on multiple triples (vs one graph)
## nesting different dimensions
    application administration
    data administration
    qualification
    composition
## property graph 
### object property annotation
		qualification
		administration
### object relationship annotation
			Alice buys Car
				age 18
				paymentMethod cash
				color blue
				source Bob
				source DataLake123
## RDFn
		separate named graphs for state 1, 2, 3 .. 
        resilience to updates and change
## OneGraph
## Superman
## DnS shortcut relation
## type vs token
## reification vs qualification





# PRIOR WORK

[TODO]  FROM HERE ON A LOT OF OUTDATED SYNTAX



### nested graphs

a simple triple with annotations
	id:1@{ :a :b :c } 
	id:1#s :d :e .
	id:1#o :f :g .
	id:1#t :h :i .

the same without explicit name
	{ :a :b :c } #s :d :e ;
                    #o :f :g ;
                    #t :h :i .

multiple triples, the whole graph annotated
	{ :a :b :c 
	  :d :e :f } :g :h .

multiple triples, each one annotated
	{ :a :b :c 
	  :d :e :f } #t :g :h .


some terms with specific identification semantics
	:a|M :b :c|A .
	id:1|A :d :e .
but that’s daring. better use proper brackets
	<M| :a> :b <C| :c> .
	<A| id:1> :d :e .
   that also opens the way to term-naming + annotation
	id:2@<:a> :b :c .
	id:2 :f :g .
   which is another way to express
	id:3 @{ :a :b :c }
	id:3#s :f :g .
   or, more succinct
	{ :a :b :c } #s :f :g .



### examples of relation to other prominent approaches
	
	n-ary relations
		quickly get quite involved and hard to use

	RDF reification
		provide an interesting but irritating semantics
		but are syntactically verbose
		
	Notation3 formulas
		provide a nice syntax, but a specialist semantics

	named graphs

	literal graphs

	singleton properties
		in nested graphs the un-annotated super-type is front and center, 
		annotations only become visible on demand. 
		in singProp however the property is rather opaque, 
		and therefore the detail clutters the view on the basic fact.

	RDF-star
		id:1@{ :a :b :c } :d :e .   # nested asserted triple instance
		{ :a :b :c } :d :e .        # anonymous asserted nested triple instance
		<< :a :b :c >> :d :e .      # quoted unasserted triple type
		id:1@<< :a :b :c >> :d :e   # quoted unasserted triple instance 
		{ OE | :a :b :c } :d :e .   # anonymous quoted unasserted nested triple instance


### RDF/pg - Improving Interoperability with Property Graphs


### Mapping an Involved Example to Triples
e.g. the introducing 10-line example

### update operation
and how it doesn't change the relation footprint

### quotation
superman, versioning, credentials, Pat's warrants

### reasoning
AZ's vision of reasoning over graphs as types

