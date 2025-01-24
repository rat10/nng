DYDRA


inter-graph paths
t	the path in this line
		{ graph ?container2 {:g ng:in+ ?container . } }
	has to cross named graphs. i thought that’s not possible?!
j	container2 is a graph
	container is a statement object.
	if they do not have to be the same value, 
		if paths in general can span graphs, then this path can span graphs.
	to permit inter-graph paths is egregiously non-conformant, 
		but we can disable the capability.
		i consider the recommendation to be anachronistic in this regard



look at the page which is linked for a given view.
	if the query executes, the sse should be available through the drop-down inspect menu.
	if it doesn't execute, you will have to ask for the media type in a curl request.
i just checked and the web interface confuses sse with sparql algebra.
	both selections in the inspect menu yield algebra
in order to get sse, you have to include it in the url
	for example
   https://dydra.com/james/foaf/predicates.rqa?accept=application/sparql-query%2Bsse
if you use curl, you can use application/sparql-query+sse as the accept header.
   curl -H "Accept: application/sparql-query+sse" https://dydra.com/account/repository/view



extend is the algebra operator for the bind expression.
it means to extend the solutions to which it applies with the given binding.




from the inspection menu in a view result page, look at the two execution process displays
   https://dydra.com/test/foaf/allNames.srxj?accept=application/VND.DYDRA.SPARQL-RESULTS-EXECUTION%2BJSON
   https://dydra.com/test/foaf/allNames.srtj?accept=application/VND.DYDRA.SPARQL-RESULTS-TRACE%2BJSON
what else would you want to see there?
would it help to, for example, provide one page of solutions for each of the operators?
