Dear Working Group,


as mentioned in last week's call, James and I have been working on a (named) graph based approach to annotations in RDF.  It's not quite at a state we would like it to be when presenting it to the WG, but now the time seems right, so we're throwing it in anyway. Please be gentle with the rough edges and occasional bugs and over-engineering.

The approach is based on the view that it doesn't make sense to have multiple modeling primitives that all cater (and compete) for the same use cases. Since we already have (named) graphs in RDF and since it's easier to accommodate a single statement in a grouping based approach than the other way round, we decided to explore an approach to annotations that is entirely graph based.

It approaches the problem space in a different way than the RDF-star proposal: it tries to satisfy mainstream expectations first, and only then extends the approach to more advanced use cases like verbatim quotation. Also it aims to meet common, application-based intuitions like a focus on statement occurrences instead of types.

To address some probable concerns right away: 
- the approach works *within* named graphs, so there's no need whatsoever to touch the theory or practice of SPARQL/RDF named graphs (but it can be extended to include named graphs if desired)
- the approach doesn't break with the set-based semantics of RDF, but nonetheless it is optimized for use cases with instance-based intuitions
- a mapping to standard RDF triples makes sure that the meaning of annotations is always well defined.

There's a much more detailed description available at [0] to which this short introduction will link in some places. That detailed text however is still a bit too long - sorry for that! - and also still suffers from some inconsistencies in the details. 
Also, a prototype implementation based on the Dydra graph database is available at https://observablehq.com/@datagenous/se-graph-workbook  - try it to see how things work! Caveat: it may not be operational at all times.
For (much) more background on meta modelling in RDF, but preceding the work on this proposal, there's also that tome "Between Facts and Knowledge - Issues of Representation on the Semantic Web" available at [1]. 

With that said, let's start.


THE BASICS

The central modelling primitive of the approach is a *nested graph*. Nested graphs are enclosed in curly braces, like RDF named graphs, but in contrast to those they are preceded by a pair of square brackets which enclose the name of the graph. 
As the moniker implies, nested graphs can be nested: inside default and named graphs in RDF dataset, but also inside each other - recursively, ad infinitum.

Take for example the following nested graph :X, in which other graphs are nested for annotation purposes:

    [:X]{
        []{
            []{:Alice :buys :Car} :purpose :Commuting ;
                                  :type :PickUp .
        }   :source :Dean ;
            :year 2015 .
        []{
            []{
                []{:Bob :likes :Car}#o :ownedBy :Alice .
                []{:Alice :buys :Car} :purpose :JoyRiding ;
                                      :type :Coupe 
                                      :year 2023 .
            } rdfs:comment "Alice's MGB" .
        } :source :Eric.
    }
    :X :ingestedFrom :DataLake_127

Only one of these graphs, ':X', is explicitly named, the other ones are named by blank nodes. This use of blank nodes is consistent with their use in n-ary relations: if they just serve structural purposes, there is no need to mint explicit names.

All nested graphs follow standard RDF semantics: they are asserted and referentially transparent. Their only immediate purpose is to facilitate structuring and annotating data. More specific semantics can be realized with graph literals, discussed below.

Statements contained in different nested graphs and at different levels of nesting all contribute equally to the meaning of the data. The statements from all nested graphs are projected into a "flattened" shared target space. 

Because of nesting the approach can accommodate annotations on single triples just as well as on sets of triples. The need to decide on which dimension of the data shall be organized in graphs is a property of SPARQL/RDF named graphs, but not of our proposal. Technically singleton graphs are  un-problematic anyway, and w.r.t. modelling nesting makes them also very practical.

The mapping to quad or named graph implementations is straightforward: on disc data structures are not actually nested but referenced via identifiers. Those identifiers are stored in the fourth position of a quad. Given proper indexing of that fourth column this approach is well-known to be performant. 



QUERYING

Querying nested graphs is in a standard use case not different from querying the same data without annotations. Including annotations in the query is straightforward as well. How to represent a query result set together with annotations is trickier, depending on the amount of detail requested. This is however not different from queries for e.g. a Concise Bounded Description in standard RDF. One would rather not request that in a CSV result set but in a CONSTRUCT query. That again is a viable option with nested graphs as well.

Querying the above data for all occurrences of ':Alice', as if we haven't heard and/or don't care about  nested graphs:

    SELECT ?s ?p ?o
    WHERE  { :Alice ?p ?o } 

will return two instances of ':Alice :buys :Car'


Querying the above data for all occurrences of ':Alice' but also the respective nested graphs in which they occur:

    SELECT ?g ?s ?p ?o
    WHERE  { GRAPH ?g {  :Alice ?p ?o } }
 
will again return two instances of ':Alice :buys :Car', this time however prepending ':Alice' with a  blank node referring to the respective nested graph.

Querying the above data for all occurrences of ':Alice', together with the source:

   SELECT ?g ?s ?p ?o ?gs
   WHERE { :Alice ?p ?o .
            ?g :source ?gs }

Modelling with nested graphs can reduce a lot of the n-ary relation clutter that standard RDF needs to express complex facts. However, navigating nested graphs with a follow-your-nose approach requires appropriate support. Without having the details all figured out already we assume that options should be provided that allow to specify the level of detail that a query should return. In addition to the above query which explicitly asks for the graph in which a result occurs we imagine some modifiers that allow to ask for more detail in a general way, e.g.
- 'with CONTEXT' to return for each result the nested graph in which it occurs
- 'with ANNOTATIONS' to return not only the reference to the graph of origin but also all attributes of that graph
- 'with CONTEXT RECURSIVELY' and  'with ANNOTATIONS RECURSIVELY', as above but following the nested structure to the root
How those increasingly complex results are to be rendered when returned as TSV or CSV is of course an interesting question. Invoking those options will most probably only make sense with very small result sets anyway. CONSTRUCTing a nested graph OTOH should without special effort provide quite readable results. Still, although the prospects are promising this area certainly needs more investigation.



FRAGMENT IDENTIFICATION

An important feature of this proposal is the ability to precisely address individual terms in a statement, or each statement in a graph, or the statement or graph itself [8]. The default arrangement is to leave the precise target undefined and assume that the context provided by vocabulary and application disambiguates the referent well enough. If however more precision is needed, a fragment identifier can provide it. This device has many applications:

    []{ :Alice :buys :House }#s :age 40 . 
        # Alice is 40 when buying a house
    []{ :Bob :knows :Judo }#p :beltColor :Brown .
        # there's always different kinds of 'knowing'
    []{ :Carol :created <https:paris.com>}#o seg:identifiedAs seg:Artifact .
        # Carol didn't create Paris, only its website
    []{ :A :b :C . :D :e :F }#t a seg:Triple .
        # '#t' addresses each triple 
    []{ :A :b :C . :D :e :F }#g a seg:Graph .
        # '#g' addresses the graph 

One useful application hinted at above is to disambiguate identification semantics, an long nagging problem of the semantic web [10]. Another application is modelling of property graphs in RDF where it can be useful to be able to address the edge of a relation independently from its nodes.



SEMANTICS

As already mentioned the semantics of nested graphs is straightforward: they are asserted and referentially transparent, just like any other standard RDF data. Other semantics can be realized via graph literals, discussed in the next section. The reasoning behind this design is that nested graphs are foremost needed as a modelling tool and should concentrate on facilitating modelling primitives with more expressivity, higher complexity and better usability than standard RDF n-ary relations. That in itself has over the last two decades proven to be a difficult enough task. Indeed, one could also say that many of the proposals brought forward in the last two decades did indeed try to shoehorn advanced modelling and special semantics into one and the same device, and they all failed to garner widespread adoption.

Another characteristic of the design of nested graphs is that they meet certain application-driven intuitions of regular users by implementing nested graphs as occurrences, not types. Since each nested graph is named, either automatically or explicitly, there can be no doubt to which nested graph an annotation belongs, even if there are multiple nested graphs with exactly the same content. Leaning graphs (even automatically, if they are named by blank nodes) is still possible, but it's the application that decides if such leaning is to be performed, not the underlying logical formalism. This design often meets practical intuitions much better than RDF's type-centric and integration focused approach. Yet, since the name is an inseparable part of each nested graph, the set theoretic base of RDF is well respected.

This can be observed when re-creating an example from the OneGraph paper [11]:

    []{:Alice :knows :Bob} :since 2020 ; 
                           :statedBy :NYTimes .
    []{:Alice :knows :Bob} :since 2021 ; 
                           :statedBy :TheGuardian .

Both nested graphs, although expressing the same statement, have different blank node identifiers, and this proposal is very strict about that: each time a nested graph is created it MUST get its own name. The advantage of this configuration is that no intermediate node is required to differentiate different occurrences, not from the start and also not in hindsight if an unexpected second occurrence needs to be dealt with.

Of course leaning and unification MAY be performed, but the intuition is that no occurrence is created without reason, and as long as we can't be sure otherwise, that reason is reason enough to keep those occurrences separate. Leaning doesn't need to be an explicit process - it can be implemented as a query, or materialized as a view that omits certain differentiating detail. In our opinion this is a more prudent approach than the type-focused "early unification" stance of RDF - which itself is understandable from RDF's focus on integration, but in practice often seems to do more harm than good (and e.g. in SPARQL is rather the exception than the norm).

Another issue discussed in the WG is the problem of changes to data and queries when new detail is added as annotation [12] (in fact that problem also concern n-ary relations in standard RDF). If there is a main statement to which additional detail is to be added, then nested graphs can provide the desired continuity in data structures and queries. Since any statement in any nested graph is projected into the root level of the target graph, adding an annotation doesn't change what's already there, even if a nested graph has to be created. A query inquiring if Alice knows Bob will get the correct answer, no matter if the statement exists in the data without annotation, with annotation, with annotation on that annotation, etc. 



CONFIGURABLE SEMANTICS

RDF is a very simplistic formalism and provides little support for use cases that need to deviate from the standard semantics. One cow path that practitioners have created is to re/mis-use RDF standard reification to document statements without actually stating (and thereby endorsing) them. Another configuration that has been pursued by approaches like Notation3 and RDF-star per the CG semantics proposal is a semantics that allows to control entailments by defaulting to referential opacity.

This approach picks up the proposal of graph literals, literals datatyped as RDF data (see [4]), to implement such non-standard semantics. That way no mainstream application of RDF has to bother about semantic subtleties that most users don't care about, but to advanced applications those mechanisms are within easy reach.

The most common use case, documenting statements without stating them, is even supported by specific syntactic sugar, a combination of nested graph curly braces (indicating referential transparency) with quotation marks (indicating citation):

    :Bob :claims []{":Moon :madeOf :Cheese"} . 

Other use cases are supported via a base mechanism that transcludes graph literals, and where the semantics of the transcluded graph can be freely configured. To that end the proposal provides a vocabulary defining various aspects of semantics and possible profiles combining them to accommodate application specific use cases [5], although its purpose is rather to illustrate possible applications than to be the actual solution to this complex area. The syntax however is pretty straightforward:

    :X seg:transcludes [ rdf:value ":Moon :madeOf :Cheese"^^nng:ttl ;
                         seg:semantics seg:Citation ]
    :Bob :claims :X .

To address the well-known "Superman-problem", even more syntactic sugar is being pondered, albeit not tested enough just yet [6]. In the following example only the term referring to Superman is referentially opaque, with the intent to block e.g. owl:sameAs entailments between Superman and ClarkKent, whereas references to Louis Lane and the concept of love follow the standard semantics of referential transparency, just as they should:

    :LouisLane :loves [OPA]":Superman" .




MAPPING TO STANDARD RDF

Three different mappings to RDF are investigated - based on the rdf:value property, the singleton properties approach and named graphs - and each has its strengths and weaknesses (see [9] for a detailed discussion). The singleton properties approach provides an interesting middle ground as it is less verbose than the rdf:value approach, but doesn't require an extension of the RDF 1.0 model and syntax as the named graph approach. It can also be easily extended to support fragment identification. The following example about Alice buying a house when *she* is 40 years old provides an idea: 

    []{:Alice :buys :House }#s :age 40 .

using the singleton properties approach is mapping to:

    :Alice :buys :House .
    :Alice :buys_1 :House .
    :buys_1 seg:aspectOf :buys ;
            seg:domain [ 
                :age 40 ] .



RDF DATASETS

SPARQL/RDF named graphs are very important in practice, but have proven to be quite difficult to standardize in the past. This proposal is completely backwards compatible because it doesn't need to touch named graphs in any way. The example query above doesn't use a FROM or FROM NAMED clause. Nested graphs can be stored inside named graphs as well as the default graph of a dataset. Any uses of named graphs work as before.

However, the RDF 1.1 WG Note "On Semantics of RDF Datasets" [2] already hints at the possibility to express  semantic fixing via some dedicated vocabulary. This proposal includes such a vocabulary [3] to define the semantics of named graphs per graph or for the whole dataset, so that in extremis an environment can be defined in which the only difference between named and nested graphs is syntactic, as the former reside on the root level of a dataset and their names are not enclosed in square brackets. On the other hand, if no such vocabulary is used, named graphs remain untouched and behave in any application or vendor specific way desired.






[0] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72
[1] https://gitlab.com/rat10/between-facts-and-knowledge/-/blob/main/Between_Facts_and_Knowledge_1.0.2.pdf
[2] http://www.w3.org/TR/rdf11-datasets/
[3] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#named-graph-vocabulary
[4] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#graph-literals
[5] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#configurable-semantics
[6] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#term-semantics-syntactic-sugar
[7] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#querying
[8] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#fragment-identification
[9] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#mapping-to-standard-rdf
[10] https://gist.github.com/rat10/eaa109ab56b4d77d29e3a826291f8e72#disambiguating-identification-semantics
[11] https://content.iospress.com/articles/semantic-web/sw223273
[12] https://lists.w3.org/Archives/Public/public-rdf-star-wg/2022Nov/0016.html