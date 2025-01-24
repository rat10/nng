The aim is to annotate statements, but also their constituents - subject, predicate and object - individually, and also blocks of statements - [property lists], (lists), and {arbitrary sets of statements, i.e. graphs}. 
To that end a concise syntax would be beneficial, if not essential.

From now on annotation will be referred to as context (a term both loved and hated ;-) This proposal rotates around one character that serves to mark both appearance and attribution of a context. That character is `©` (Option G on MacOS, ALT 0169 on Windows) and could be read as `contextualization of [NODE] as [NAME] with [ATTRIBUTES]`.


To indicate an appearance of a context for a block level element the character `©` is always used directly after that block level element, i.e. after a `.`, `;`, `,`, `)`, `]` or `}` (more on `{...}` below):

:s :p :o . ©               # not yet complete, developing the example

To indicate a context for a single term the character `©` is added right after that term:

:s :p :o © . ©             # not yet complete, developing the example

In any case, i.e. indicating block level contextualization as well as term contextualization, the indicating `©` is followed by a `>` sign to dismabiguate its appearance from where its attributes are described:

:s :p :o ©> . ©>           # not yet complete, developing the example


If the indicator is explicitly identified, that ID has to follow immediatly after the `©`character. 
[TODO specification of naming]
That ID can be a simple name, i.e. just a string literal, and in that case is mapped to an rdfs:label on a blank node represented by the `©` character (just like `[...]` represent a blank node). Those labels are local and when merging graphs they may be "standardized apart". However, they aren’t as ephemeral as blank node labels and are guaranteed to be stable over consecutive reloads or queries.
[TODO no doubts there are limits to this rather loosely defined arrangement, but what are those limits precisely? how can this be made more precise?].

:s :p :o ©A> . ©B>         # from now on all examples are COMPLETE

[© might also, optionally, be equipped with a namespace in the head of a document. in that case `©:abc` would expand to a full IRI. alternatively (but not also) name spaced and full IRIs can be used as IDs, e.g. `©ex:abc` and `©http://ex.org/abc`]

If the context is to be attributed in place, that describing property list has to be enclosed by a pair of square brackets `[...]`, following the `©...>` or `©>` immediately, without intermediate whitespace:

:s :p :o ©A>[:c :d] . ©B>[:e :f; :g :h]

If the description is immediately provided an ID can be omitted:

:s :p :o ©>[:c :d] . ©>[:e :f; :g :h]


Attribution can either happen in place - as in the preceding example - or by using the ID as subject or object of other statements. In that case the trailing `>` has to be omitted, thereby disambiguating appearance and attribution. Combinations of in-place and out-of-line annotations are possible as well.

:s :p :o ©A> . ©B>[:e :f]
©A :c :d .                 # contextualizing the object
©B :g :h .                 # contextualizing the whole triple


Contextualizing compositional statements follows the same rules:

:s :p :o1 , ©1>
     :o2 ©2> , ©3>
     :o3 . ©>[ :a :b ]
©1 :c :d .
©2 :e :f , :g .
©3 :h :i .


Contextualizing blocks needs to differentiate between the block and the last statement

:s :p [ :o :q ;
       :r :t ©4> . ©5> ] ©6> .    # problem with punctuation marks
©4 :j :k .                        # annotates :t
©5 :l :m .                        # annotates [ :r :t ]
©6 :n :o .                        # annotates [ :o :q ; :r :t ]

TODO annotating Collections in turtle is more difficult than blankNodePropertyLists

TODO are nested annotations annotated as well?
    e.g. does ©6 include ©4 and ©5 ?
    … shouldn’t. that should require explicit reference
      e.g. another ©>, or an enclosing graph

TODO proper names for annotations?
    or at least a defined way to transform these pseudo nominals into proper IRIs

TODO annotating statements?
    can it be done after the punctuation mark?
    i.e. is the ©> indicator sufficient to disambiguate
         an indication from a description
    or does it need braces?