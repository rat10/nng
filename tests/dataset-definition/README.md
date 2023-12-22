### dataset definitions with remote resources

this example addresses the concern in https://github.com/w3c/rdf-ucr/issues/16,
"RDF-star for labelled property graphs".

this example describes how to define a sparql dataset which

    "just take[s] data stored in the default graph of database X and move[s]
     it into a named graph inside Y."

a definition accomplishes this by spefifing the appropriate content type in the
remote resource designators.
for example

    https://somewhere.org/repository/sparql?from-named=https://somewhere-else.org/repository/service?default.trig
