all about :A
23.2.2025

Distinct
    (   Project
        (   OrderBy
            (   Join
                (   Union
                    (   Extend
                        (   Extend
                            (   Extend
                                (   Graph
                                    (?graph, BGP( ?graph ?prop ?val)), 
                                    ?target, 
                                    ?graph
                                ),
                                ?source,
                                ?graph
                            ),
                            ?means,
                            <http://rdf.ng/DirectSelf>
                        ),
                        Union
                        (   Filter
                            (   (?prop != <http://rdf.ng/in>),
                                Extend
                                (   Extend
                                    (   Extend
                                        (   Graph(?nesting, BGP( ?graph ?prop ?val)),
                                            ?target,
                                            ?graph
                                        ),
                                        ?source,
                                        ?nesting
                                    ),
                                    ?means,
                                    <http://rdf.ng/DirectNesting>
                                )
                            ),
                            Union
                            (   Filter
                                (   ! exists((bgp, (triple, ?graph, <http://rdf.ng/in>*, ?extraGraph))) ,
                                    Extend
                                    (   Extend
                                        (   Extend
                                            (   Graph(?extraGraph, BGP( ?graph ?prop ?val)),
                                                ?target,
                                                ?graph
                                            ),
                                            ?source,
                                            ?extraGraph
                                        ),
                                        ?means,
                                        <http://rdf.ng/DirectExternal>
                                    )
                                ),
                                Union
                                (   Extend
                                    (   Extend
                                        (   Extend
                                            (   Graph(?nesting, BGP( ?nesting ?prop ?val)),
                                                ?target,
                                                ?nesting
                                            ),
                                            ?source,
                                            ?nesting
                                        ),
                                        ?means,
                                        <http://rdf.ng/InheritSelf>
                                    ),
                                    Union
                                    (   Filter
                                        (   
                                            (   ?nesting != ?outerNesting) 
                                                && exists((bgp, (triple, ?nesting, <http://rdf.ng/in>+, ?outerNesting)))  
                                                && (?prop != <http://rdf.ng/in>),
                                            Extend
                                            (   Extend
                                                (   Extend
                                                    (   Graph(?outerNesting, BGP( ?nesting ?prop ?val)),
                                                        ?target,
                                                        ?nesting
                                                    ),
                                                    ?source,
                                                    ?outerNesting
                                                ),
                                                ?means,
                                                <http://rdf.ng/InheritNesting>
                                            )
                                        ),
                                        Filter
                                        (   ! exists((bgp, (triple, ?nesting, <http://rdf.ng/in>*, ?extraGraph))) ,
                                            Extend
                                            (   Extend
                                                (   Extend
                                                    (   Graph
                                                        (   ?extraGraph, BGP( ?nesting ?prop ?val)),
                                                        ?target,
                                                        ?nesting
                                                    ),
                                                    ?source,
                                                    ?extraGraph
                                                ),
                                                ?means,
                                                <http://rdf.ng/InheritExternal>
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    Project
                    (   Graph
                        (   <urn:dydra:all>,
                            Join(BGP( ?graph <http://rdf.ng/in>* ?path . ?path <http://rdf.ng/in>+ ?nesting),
                            ToMultiSet({{(?graph, <http://rat.io/A>)}})
                            )
                        ),
                        {?graph, ?nesting}
                    )
                ), 
                (?graph ?means ?target ?source ?prop ?val)
            ),
            {?graph, ?prop, ?val, ?target, ?source, ?means}
        )
    )