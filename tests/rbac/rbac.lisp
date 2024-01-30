;;;

(test-sparql "
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
where { 
  #values ?user { <http://example.org/user/User1> }
  graph :authorizations { _:auth acl:accessTo ?data ; acl:mode acl:Read ; acl:agent ?user }
  graph ?data { ?s ?p ?o }
}
"
              :dynamic-bindings '((?::|user|) <http://example.org/user/User1>)
             ; :dynamic-bindings '((?:|user|) <http://example.org/user/User2>)
             :repository-id "seg/test")

(expand-query "
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
where { 
  graph :authorizations { _:auth acl:accessTo ?data ; acl:mode acl:Read ; acl:agent ?user }
  graph ?data { ?s ?p ?o }
}
"
             :repository-id "seg/test" :agent (system-agent))


(test-sparql "
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
prefix nng: <http://nngraph.org/>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
FROM NAMED nng:embeddings
where { 
  graph :authorizations {
    _:auth acl:accessTo ?dataRoot ; acl:mode acl:Read ; acl:agent ?user .
    graph nng:embeddings { ?dataRoot nng:asserts* ?data . }
  }
  graph ?data { ?s ?p ?o }
}
"
              :dynamic-bindings '((?::|user|) <http://example.org/user/User1>)
             ; :dynamic-bindings '((?:|user|) <http://example.org/user/User2>)
             :repository-id "seg/test")

(test-sparql "
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
prefix nng: <http://nngraph.org/>
select ?user ?data
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
FROM NAMED nng:embeddings
where { 
  graph :authorizations {
    _:auth acl:accessTo ?dataRoot ; acl:mode acl:Read ; acl:agent ?user .
    graph nng:embeddings { ?dataRoot nng:asserts* ?data . }
  }
}
"
              :dynamic-bindings '((?::|user|) <http://example.org/user/User1>)
             ; :dynamic-bindings '((?:|user|) <http://example.org/user/User2>)
             :repository-id "seg/test")

(test-sparql "
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
prefix nng: <http://nngraph.org/>
select ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
FROM NAMED nng:embeddings
where { 
  graph :authorizations { ?s ?p ?o }
}
"
              :dynamic-bindings '((?::|user|) <http://example.org/user/User1>)
             ; :dynamic-bindings '((?:|user|) <http://example.org/user/User2>)
             :repository-id "seg/test")

(expand-query"
prefix : <http://example.org/>
prefix user: <http://example.org/user/>
prefix data: <http://example.org/data/>
prefix acl: <http://www.w3.org/ns/auth/acl#>
prefix nng: <http://nngraph.org/>
select ?user ?data ?s ?p ?o
FROM NAMED data:graph1
FROM NAMED data:graph2
FROM NAMED :authorizations
FROM NAMED nng:embeddings
where { 
  graph :authorizations {
    _:auth acl:accessTo ?dataRoot ; acl:mode acl:Read ; acl:agent ?user .
    graph nng:embeddings { ?dataRoot nng:asserts* ?data . }
  }
  graph ?data { ?s ?p ?o }
}
"
             :repository-id "seg/test" :agent (system-agent))