the following is an attempt at the NNG syntax that supports
- graphs in subject, predicate and object positions
- autonomous graphs
- names prefixed to a graph, infixed as first element, or omitted
- explicitly marking a graph name via an `@` prefix

the only noteworthy constraints are that
- graphs in predicate position MUST be named and
- that name must be marked by an `@`

```turtle
graph names
    graphs are always named
    graph names can be
            - prefixed to a graph
                marking the name by a leading '@' is OPTIONAL
            - infixed as first element inside a graph
                marking the name by a leading '@' is MANDATORY
            - anonymous, not providing a name
                implicitly generating a naming blank node
    so we have the following graph types
            - prefix graph, 
                e.g.    :G { :s :p :o } :y :z .
                        @:G { :s :p :o } :y :z .
                        [] { :s :p :o } :y :z .
                        @[] { :s :p :o } :y :z .
            - infix graph 
                e.g.    { @:G  :s :p :o } :y :z .
                        { @[]  :s :p :o } :y :z .
            - anon graph
                e.g.    { :s :p :o } :y :z .
    the same examples can be made with graphs in object position
        and with graphs in both subject and object position.
    however,
    graphs in predicate position 
        - MUST be named and 
        - that name MUST be marked by an '@'
        - but see the outlier in the third example
                e.g.    :a @:X { :s :p :o } :c .
                        :a @[] { :s :p :o } :c .
                        :a @ { :s :p :o } :c .     # unambiguous, but hard to define
                        :a { @:X :s :p :o } :c .
                        :a { @[] :s :p :o } :c .
                but not :a { @ :s :p :o } :c .     # too ambiguous, therefore illegal

    we also differentiate between graphs that are
        - defined while being used as terms in statements
                (as in the examples above)
        - autonomous graphs, which are defined but not annotated in place
                those again can be named per prefix|infix|anon
                e.g.    :G { :s :p :o } .
                        @:G { :s :p :o } .
                        { @:G  :s :p :o } .
                        { :s :p :o } .              # this one may seem a bit extreme

graph semantics 
    declared per prepending ©, 
        only inside + at beginning of graph
                e.g.    :G { ©:APP :s :p :o } :y :z .
    multiple declarations are combined 
        (! not as presently defined the inner one overriding the outer one !)
                e.g.    :G "{ ©:CWA :s :p :o }" :y :z .
                        :G { ©:QUOTE ©:CWA :s :p :o } :y :z .
    there is no syntactic connection between naming and declaration of semantics
        other than if both occur inside a graph, the name precedes the semantics

parsing examples
        all starting from a new statement, 
        only showing the characters until the described decision is made

{                                           brace, so infix|anon graph as subject
{ :a                                        no @, so anon graph as subject
:a {                                        explicit graph as subject
                    
:a @                                        explicit graph as predicate
:a {                                        infix graph as predicate

:a :b {                                     infix|anon graph as object 
:a {:s :p :o} :b {                          infix|anon graph as object
:a {:s :p :o} {@:X :s :p :o} {              infix|anon graph as object
:a {:s :p :o} :b :c {                       explicit graph as object

{:s :p :o} :b {:s :p :o3} .                 anon graphs as subject and object
{:s :p :o} { @[] :s :p :o2} {:s :p :o3} .   anon graphs as subject and object
                                            and explicit graph as predicate
{:s :p :o} @{ :s :p :o2} {:s :p :o3} .      dito

```