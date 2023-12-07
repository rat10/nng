the additions to implement nested named graphs have grown to about 260 lines of code.
much of this has to do with interpreting the variant inclusion classes together with handling the dataset clause

berlinnew:spocq-seg james$ wc repository-streaming.diff
    180    1078   10867 repository-streaming.diff
berlinnew:spocq-seg james$ wc classes.diff
     64     271    2838 classes.diff
berlinnew:spocq-seg james$ wc bgp-versioned.diff
     18      43    1066 bgp-versioned.diff

repository-streaming is the core of the match/scan mechanism upon which the sparql processor is built.
notable about its changes is that they are solely to compute the set of graph identifiers which define the effective target graph.