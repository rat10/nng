# a mail with a TODO list
# probably from around the meltdown in jan/feb 2024


TODO	include and transclude

	add vocab to nngraph.org

	semantics
		combining different semantics must go for a union of constraints
		same for eg []"{ :APP | s p o }"
		     this means REPORT _and_ APP, not APP _insteadOf_ REPORT

statement graph can be 
	term graph or 
	named graph

autonomous graph  # maybe RIP
	Y { s p o } .   


{name|class class| spo} {abc} {xyz} . (recorded/reported/…) term graphs   (( class overrides syntax ))
				                      
:Y { s p o } .     		named autonomous graph # maybe RIP
{ :X | s p o } y z .      	(recorded/reported/…) named term graph - the only one that is part of a statement
#  { s p o }                    implicitly named graph with bnode
[:x CLASS ] { s p o } .         still a named graph, but with semantics class reference
[CLASS] { s p o } .             bnode named graph with semantics     
[ :X CLASS,CLASS2,…] { s p o } .
<:X>{ s p o }

:X { THIS semantics APP .
     s p o }




# ############################################
# ALWAYS LABEL
# NO AUTONOMOUS GRAPH
# SEMANTICS INSIDE GRAPH

:X { :APP | s p o }  :y   :Z { u v w } . 
[] "{ s p o }"  :y   [] { u v w } .
:X { s p o } .
_:b1 { x y z }

:X :y :Z { u v w } . 

:X { s p o .}  :Z { u v w .}   :Z { u v w .} . 



#

<< id:1 | s p o>> is there .
s p o  {|  is here |}
->
id:1 occurrenceOf <<( s p o )>>
_:b2 occurrenceOf <<( s p o )>>
id:1 is there .
_:b2 is here .
s p o.





# more notes

GraphLiteral -> RDFLiteral
 "GraphLiteral"     ;; see graphLiterals.md

literals will NOT RIP

transcludes -> asserts ??
includes is not a good abstraction/word

two options
include a graph as nested
include the statements of that graph into the current graph 
but forget about the originating graph 
	-> that’s owl:imports

===


X "{
  THIS includes { s p o.  }   # respects enclosing semantics
}"
—>
X "{ s p o }"

---

TriG                          # we DUMP this -> No we DON'T
Y {
  Z quotes "a b c"^^rdfgraph  #  doesn’t scale in a useful way 
                              #  -> oh it does (it just doesn’t nest, 
                              #  but that’s okay, as long as they are not nested)
  Y transcludes B             #  this doesn’t cretae a new subgraph  
  d e f
}
B { u v w }

->

NNG (TriG)                    #  our NORMAL
Y {
  Z  << a b c >>              #  [Z Quote] "a b c"^^rdfgraph
  B { u v w }
  d e f
  { q y z }
}
{ s p o }
w x y 

->

DYDRA impl.                   #  our TriG VEHICLE

w x y
Y { d e f }
Z { a b c }
_:b1 { q y z }
[] { s p o }
embeddings {  Y quotes Z ;
                asserts _:b1 }


OTHER impl                    #  other people’s shit
Y { d e f .
   THIS quotes Z 
}
Z { a b c }