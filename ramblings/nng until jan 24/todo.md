# re-shuffle

core
    abstract notion of embedding / import
    recursive transclusion 
    syntactic sugar
    semantics basic + quoted
    additions to rdf 1.1 datasets

annotation and contextualization
    statements vs graphs
    graphs for this or for that
    nested graphs

semantics                                               introduction
    semantics of identification                         the problem in general
        semantics of identification - named graphs      the problem w.r.t. rdf named graphs
    semantics of qualification                          a discussion
    semantics of data                                   configurable semantics
        semantics of data - vocabulary                  a vocab to configure semantics
        semantics of data - mechanics                   graph literals and processing instructions
        semantics of data - syntax sugar                special support for 3 kinds of citation

mapping
    nesting                                             mapping annotations
        quads
            nng
            n-quads
        triples
            rdf:value
            singleton property
            4D fluents
    semantics                                           mapping configurable semantics
            s-quads
            s-nng
            standard reification                        with subclasses of rdf:Statement

querying

examples



# let's say we re-design transclusion and inclusion

1) drop the concept of transclusion
    everything is *included* or even just *nested* now

2) nesting is defined on rdf 1.1 named graphs
    it "nests" them inside each other
        as we are well aware in RDF a graph is defined as a set of statements
        now imagine that it may contain not only statements but also other graphs

    that means they get imported 
        like the owl import mechanism imports ontologies
        (which is obviously different from just mentioning/annotating them by name)
    the semantics don't diverge from rdf
        neither does the naming semantics deviate from rdf datasets
        nor does the interpretation of included graphs deviate from standard rdf semantics


        import/inclusion/transclusion
            is recursive

        annotations on included graphs
            qualify them by adding more detail (strictly monotonic)

        example
            graph
            nesting in other graph
            annotating the inner graph
            result

3) the property is `nng:nestedIn` or just `nng:in`
        its domain and range is nested graph
        i.e. both nesting and nested graph are addressed as graph
            like FROM addresses an IRI as graph 

4) nesting can be performed recursively
        but it has no formal transitive semantics
        (very much like singleton properties "having" relation)
        (i should read Sowa for more examples)

5) syntactic sugar allows to omit to declare the nesting relation:
            :X { :Y { :s :p :o } }
        is syntactic sugar equivalent to
            :X { :X nng:in :Y }
            :Y { :s :p :o }

# configurable semantics

1) lets first be clear that here we talk about the semantics of the data
        not the semantics of graph naming (and identification in general)

2) included graphs follow standard rdf semantics: referentially transparent, asserted

3) however, there are other needs too: various forms of citation, but also CWO, UNA, lists as first class citizens, etc

4) accommodating these needs requires a semantic extension guaranteeing monotonicity
   we propose a combination of
        - specific syntax
        - specific processing instructions
        - mapping to regular syntaxes and systems

5) the mechanism is to *include as*: include as quote, include as report, include as youNameIt.the property is `nng:inAs...`, e.g. `nng:inAsQuote`