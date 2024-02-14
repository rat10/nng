prefix : <http://example.org/> 
prefix nng: <http://nngraph.org/>

select ?graph ?who ?does ?what ?sp ?sv ?rp ?rv ?op ?ov
where { 
   graph ?graph { ?who ?does ?what } 
   OPTIONAL { ?graph  :subject  [ ?sp ?sv ] .}
   OPTIONAL { ?graph  :relation [ ?rp ?rv ] .}
   OPTIONAL { ?graph  :object   [ ?op ?ov ] .}
}

select ?graph
where { 
    graph :Buying {
    ?graph { :Alice ?a ?b }  
    OPTIONAL { ?graph  :subject  [ ?sp ?sv ] .}
    OPTIONAL { ?graph  :relation [ ?rp ?rv ] .}
    OPTIONAL { ?graph  :object   [ ?op ?ov ] .}
    }
}

select ?graph1 ?graph2 ?does ?what ?sp ?sv ?rp ?rv ?op ?ov
where { 
    graph :Alice {
        graph ?graph1 {
            graph ?graph2 { :Alice ?does ?what }  
            OPTIONAL { ?graph  :subject  [ ?sp ?sv ] .}
            OPTIONAL { ?graph  :relation [ ?rp ?rv ] .}
            OPTIONAL { ?graph  :object   [ ?op ?ov ] .}
        }
    }
}