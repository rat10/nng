
# inclusion 1, from your last mail

prefix : <http://ex.org/>  
prefix nng: <http://nng.org/>
[]{:s :p :o .
  [:MyG nng:Quote] { :a :b :c }  
       :q :w .
}

## wrong (workbook)

_:b9                <http://nng.org/quotes>         <http://ex.org/MyG> _:b9 .
<http://ex.org/s>   <http://ex.org/p>               <http://ex.org/o>   _:b9 .
<http://ex.org/MyG> <http://ex.org/q>               <http://ex.org/w>   _:b9 .
<http://ex.org/a>   <http://ex.org/b>               <http://ex.org/c>   <http://ex.org/MyG> .
<urn:dydra:default> <http://nng.org/transcludes>    _:b9 .

## right

there is no right, because configurable semantics is only defined on included graph literals, but not on transcluded nested graphs (which always have standard semantics)


# inclusion 2, also from your last mail

prefix : <http://ex.org/>  
prefix nng: <http://nng.org/>

[]{:s :p :o .
  [] {" :a :b :c "}  
       :q :w .
}

## wrong (workbook)

<http://ex.org/s>    <http://ex.org/p>            <http://ex.org/o>                _:b29 .
_:b30                <http://ex.org/q>            <http://ex.org/w>                _:b29 .
_:b29                <http://nng.org/includes>    _:b30                            _:b29 .
<http://ex.org/a>    <http://ex.org/b>            <http://ex.org/c>                _:b30 .
<urn:dydra:default>  <http://nng.org/transcludes> _:b29 .

## right
               
<http://ex.org/s>    <http://ex.org/p>            <http://ex.org/o>                _:b29 .
_:b30                <http://nng.org/records>      ":a :b :c"^^nng:GraphLiteral    _:b29 .
_:b30                <http://ex.org/q>            <http://ex.org/w>                _:b29 .

### herleitung: the following snippets are all equivalent

:Bob :claims [ nng:includes ":s :p :o. :a :b :c"^^nng:GraphLiteral 
               nng:semantics nng:App ] 

:Bob :claims [nng:APP]":s :p :o. :a :b :c"^^nng:GraphLiteral

:Bob :claims [ nng:apps ":s :p :o. :a :b :c"^^nng:GraphLiteral ]
    # inventing a property nng:apps analogous to nng:quotes|reports|etc

:Bob :claims _:b1 .
_:b1 nng:apps ":s :p :o. :a :b :c"^^nng:GraphLiteral . 

### implementation detail
    # you might do the following to store graph literals as proper graphs
    # (and maybe you have a better idea)
    # but this shouldn't be visible to users
    # and not be shared in serializations

<http://ex.org/s>    <http://ex.org/p>            <http://ex.org/o>                _:b29 .
_:b30                <http://ex.org/q>            <http://ex.org/w>                _:b29 .
_:b30                <http://nng.org/records>     _:Record_1                       _:b29 .
<http://ex.org/a>    <http://ex.org/b>            <http://ex.org/c>                _:Record_1 .

