
            one thing to keep in mind is that nested graph and term graph mechanisms are in many ways orthogonal.
            i have adopted nested semantic constraints for terms as well, but terms are unrelated to target graph construction mechanism which served nested graphs.
            their interpretation is implemented in how a bgp is compiled into joins.
            nested graph interpretation is implemented through target graph construction.

        that doesn't sound right.

        the following term graph :Y nested in :X

        { :X |  :a :b :c .
            { :Y | :s :p :o . } .
        }

    there is no term graph in that example.
    :y is a nested graph.

    * (pprint-sse (parse-sparql "
        prefix : <http://example.org/> 
        prefix nng: <http://nngraph.org> 
        select *
        where { 
            :X { :a :b :c  .  
                :Y  { :s :p :o . }  .  
            } .  
        } 
    "))
    (select
        (bgp 
            (bgp 
                (graph <http://example.org/X>)
                (bgp 
                    (graph <http://nngraph.org/embeddings>)
                    (triple ??PARENT <http://nngraph.org/asserts> <http://example.org/X>)
                )
                (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                (bgp 
                    (graph <http://example.org/Y>)
                    (bgp 
                        (graph <http://nngraph.org/embeddings>)
                        (triple <http://example.org/X> <http://nngraph.org/asserts> <http://example.org/Y>)
                    )
                    (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
                )
            )
        )
    *)
    *

    the term graph syntax for :Y fails - see below.

that's not right. 
   :Y  { :s :p :o . }  .  
is syntactic sugar for 
   :Y  { :s :p :o . } nng:nestedIn THIS .  
that the former parses, but the latter not (and also no other variant of 
   :Y  { :s :p :o . } :d :e .  
) is not following any pattern inherent to the nng proposal. i don't understand what you did, and maybe it makes sense in the context of query parsing/processing, but it results in something different than nng.

        could just as well be written as

        { :X |  :a :b :c .
            :Y nng:nestedIn :X .
        }
        { :Y | :s :p :o . }

    in

    { :X |  :a :b { :Y | :s :p :o . } . }

    :y is a term graph.
    that is, it is a term in a statement.
    by virtue of the statement's context, :y is _also_ nested.

i would put it differently:
- the object of the statement in :X is :Y 
- :Y is a graph and nested in :X 
- therefore the statement contained in :Y is also contained in :X 

the expanded mapping above, omitting any syntactic sugar, makes that clear. 
one could add
  nng:nestedIn rdfs:subpropertyOf [ owl:inverseOf owl:imports ].

        (modulo that i'm to lazy to look up how nng:nestedIn is named in the docs, but you get what i mean)

        likewise

        { :Z |  :a :b :c .
                { :Y | :s :p :o . }  :d :e .
        }


    * (pprint-sse (parse-sparql "
        prefix : <http://example.org/> 
        prefix nng: <http://nngraph.org> 
        select * 
        where  {  
            :a :b :c .  
            { :Y | :s :p :o . }  :d :e . 
        }  
    "))
    (select
        (bgp 
            (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
            (triple <http://example.org/Y> <http://example.org/d> <http://example.org/e>)
            (bgp 
                (graph <http://example.org/Y>)
                (bgp 
                    (graph <http://nngraph.org/embeddings>)
                    (triple ??PARENT <http://nngraph.org/asserts> <http://example.org/Y>)
                )
                (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
            )
        )


    (pprint-sse (parse-sparql "
        prefix : <http://example.org/> 
        prefix nng: <http://nngraph.org> 
        select * 
        where  { :X | 
            :a :b :c .  
            { :Y | :s :p :o . }  :d :e . 
        }  
    "))
    ;; fails because :X is not a term graph and does not permit that syntax

i see that it fails, but to me this suggests a shortcoming of the parser, or of the way the bgp's are constructed. "because :X is not a term graph and does not permit that syntax" is a description, but not a valid argument.

    debugger invoked on a ORG.DATAGRAPH.SPOCQ.EVALUATION:MESSAGE-SYNTAX-ERROR in thread
    #<THREAD "main thread" RUNNING {1001060103}>:
    While processing, an error was signaled: Invalid message received :
    failed to parse after '|' at offset 86 on line 1.
    prefix : <http://example.org/> prefix nng: <http://nngraph.org> select * where  { :X | :a :b :c .  { :Y | :s :p :o . }  :d :e . }  

    (pprint-sse (parse-sparql "
        prefix : <http://example.org/> 
        prefix nng: <http://nngraph.org> 
        select * 
        where  { 
            :X { :a :b :c .  
                { :Y | :s :p :o . }  :d :e . 
            } 
        } 
    "))
    * (pprint-sse (parse-sparql "
        prefix : <http://example.org/> 
        prefix nng: <http://nngraph.org> 
        select * 
        where  { 
            :X { :a :b :c .  
                { :Y | :s :p :o . }  :d :e . 
            } 
        } 
    "))
    (select
        (bgp 
            (bgp 
                (graph <http://example.org/X>)
                (bgp 
                    (graph <http://nngraph.org/embeddings>)
                    (triple ??PARENT <http://nngraph.org/asserts> <http://example.org/X>)
                )
                (triple <http://example.org/a> <http://example.org/b> <http://example.org/c>)
                (triple <http://example.org/Y> <http://example.org/d> <http://example.org/e>)
                (bgp 
                    (graph <http://example.org/Y>)
                    (bgp 
                        (graph <http://nngraph.org/embeddings>)
                        (triple <http://example.org/X> <http://nngraph.org/asserts> <http://example.org/Y>)
                    )
                    (triple <http://example.org/s> <http://example.org/p> <http://example.org/o>)
                )
            )
        )
    *)

but then dragging the :Y in front of the curly braces again doesn't parse
  prefix : <http://example.org/> 
  prefix nng: <http://nngraph.org> 
  select * 
  where  { 
      :X { :a :b :c .  
           :Y {  :s :p :o . }  :d :e . 
      } 
  } 
  >> queryResult = updateResult ? await postQuery(segQueryText) : ""
that seems broken. i don't see the logic in this. imo nobody can be bothered to remember when to use which syntax when.


        could just as well be written as

        { :X |  :a :b :c .
            :Y nng:nestedIn :X ;
                :d :e .
        }
        { :Y | :s :p :o . }

    as indicated by the second parse result, above.


        i see no reason to treat the two cases differently.

    the patterns which match term v/s nested graphs _are_ different.
    in the nested case, there is a simple join of the respective content.
    in the term case, there is a join of the name and the annotation.

no, there is something wrong here although i can't precisely say what.
in theory the case is very clear: nesting a graph per an inlining notation - i.e. authoring and nesting it at the same time - is the same kind of activity no matter in what position if the statement it is done.
a nested graph occuring in object position (what you call term graph) is mapped in the same way outlined above for a nested graph in subject position (what we both call nested graph). an according variant of the example above:

    :X { :a :b :c .  
         :d :e :Y { :s :p :o . } . 
    } 

is mapped to 

    :X {  
        :a :b :c .
        :d :e :Y .
        :Y nng:nestedIn :X .
    }
    :Y { :s :p :o . }

also a standalone statement graph

    :X { :a :b :c .  
         :Y {  :s :p :o . } . 
    } 

is mapped following the same pattern

    :X {  
        :a :b :c .
        :Y nng:nestedIn :X .
    }
    :Y { :s :p :o . }

this is very straightforward and an implementation shouldn't handle those different cases in categorically different ways. imo that can only lead into problems down the road. i can only assume that either you got lured into some early optimization.


        the only difference is that the nested graph is either authored "in place" or as a separate named graph.

    the term graph is either authored "in place" or as a separate named graph.
    a graph which is just nested is authored in place only.

that makes no sense to me. to clarify: a nested graph in object position is in my parlance annotated just as is a nested graph in subject position. i do even consider a standalone statement graph as annotated, namely by the fact that it is nested inside another graph. on the basis of that intuition i can make no sense of your preceding paragraph.

        the latter reflects storage and named graphs conventions, the former is NNG syntactic sugar.

    a graph which is just nested requires nng syntax.

that makes no sense to me either as obviously all the "graph terms" and "nested graphs" and "standalone/statement graphs" do use the nng syntax of curly braces and some sort of naming syntax (currently predominantly the pipe delimiter between name and data)


        however, maybe you mean something entirely different with "term graphs". you constantly lose me with the terminology. please explain!

    the distinction, above, between nested and terms graphs has not change in my terminology.
    with the word "nested", rather than "embedded" i thought i was consistent with your terminology.

well, i'm horrible at memorizing vocabulary, even if i have designed it myself. but i'm even worse when what the terms refer to doesn't or shouldn't exist in my intuition.

        maybe that will also help me understand the above
            their interpretation is implemented in how a bgp is compiled into joins.
            nested graph interpretation is implemented through target graph construction.


