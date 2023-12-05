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
      nng:nested :Example .
} :says :Zarathustra  ,
  :source :Source_1 .


Notes: 
- THIS is important to improve *locality* of annotations
- nng:nested is inherited, it applies to all inner graphs as well
  (but only to graphs, not individual statements or nodes)


Queries:

1) who *says* ':Dog :eats :Fish .' ?
    > :Alice                            # give me only the result(s) from the THIS level
    > :Alice :Bob :Carol :Zarathustra   # give me results on all levels of nesting
    > :Alice :Bob                       # give me results from the first n=2 levels of nesting
                                        # nesting level count starts with THIS

2) who *believes* ':Dog :eats :Fish .' ?
    >                                   # give me only the result(s) from the THIS level
    > :Ben :Curt                        # give me results on all levels of nesting
    > :Ben                              # give me results from the first n=2 levels of nesting
                                        # nesting level count starts with THIS

3) in which graph(s) occurs ':Goat :has ?o' ?
    >                                   # give me only results annotated with THIS
    > :Y                                # give me only the nearest graph
    > :Y :Z                             # give me all enclosing graphs (Olaf's case 3)
                                        # BUT not the DEFAULT graph, because :Z is not nested 
                                        #   in the default graph
                                        #   would you agree?
                                        #   or does that run counter your implementation?

4) what believes Curt ?
    > :Y

5) which graphs are of type :Example ?
    > :Y :X _:Report1                   # _:Report1 referring to Beatrice' claim

6) give me all types
    > :Example _:b1                     # the value space of fragment identifiers nng:domain
                                        # and nng:nested is interpreted as class
                                        # _:b1 refers to the dog named "Dodger"

7) give me all types including from included graph literals
    > :Example, :Star

