:Alice {
    :Buying {
        :Car1 {
            :Alice :buys :Car .
        } :subject [ :age 22 ] ;
          :object [ :age 12 ;
                    :type :Sedan ] .
        :Car2 {
            :Alice :buys :Car .
        } :subject [ :age 42 ] ;
          :object [ :age 0 ;
                    :type :Coupe ] .
    } .
    :Loving {
        :Band1 {
            :Alice :loves :SuzieQuattro ;
        } :subject [ :age 12 ] .
    } .
    :Doing {
        :Sports1 {
            :Alice :plays :Tennis .
        } :subject [ :age 15 ] ;
          :predicate [ :level :Beginner ] .
    } .
} .