# MONOTONICITY

An observation about monotonicity, and please forgive (and correct) me if I got it totally wrong. 

The logic that defines meaning in RDF is monotonic: no triple can influence the meaning of another triple. I see how that is important in an open world environment like the semantic web. IIUC it also the most straightforward way for a logic to operate (so good for scalability, easy to understand etc). 

However, the concept seems rather abstract to me and not properly reflect what is actually happening.

first a really simple example:
    :Alice :age 18 .
this is not monotonic as Alice is not always 18. workaround: 
    :Alice :born 2001 ;
           :age ... // your favorite wild construct here
maybe SPARQL provides a way to calculate Alice's age from the current data and her birth year but RDF certainly doesn't. most knowledge we have and cherish doesn't hold forever and everywhere. most of the facts on the Semantic Web don't qualify as universal truth. yet we get by, with out-of-band means. the spec expressly states that RDF is not a temporal logic. 
we also get by with conflicting opinions encoded as statements. say:
    :Car :color :Red .
    :Car :color :White .
those two statements contradict each other but they don't comment on or rule into each other. they are monotonic. applications have to deal with such contradictions, e.g. keep them apart or delete one viewpoint when need arises. that's application territory (again: out-of-band, RDF provides no semantically sound means).


OTOH
    { :Car :color :Red } :is :False
is not allowed. it's non-monotonic 
(and also not valid RDF 1.x syntax but let's ignore that for the moment)
However
    { :Car :color :Red } :statedBy :Thomas
is generally considered okay as it simple adds some provenance information, i.e. only metadata.
that is a questionable point of view as the distinction between data and metadata is always application specific. granted _most_ applications consider provenance as metadata but to some it is very important and practically core data (Hayden: "We kill people based on metadata")
in fact that arrangement/consensus/common practice is only a flimsy compromise between those that want to keep the semantics clean and simple and those that want at least the most basic use cases supported

what would actually make a statement _false_, except explicitly assigning it that value like in the example above? calling it a lie, not trustworthy, proven to be false
then there's also the usual suspects from the realm of paradoxes:
    :Thomas a :Liar .
suddenly the innocent source attribution above is not so innocent anymore [0]. 
but isn't anything else just description, adding further detail, thereby narrowing down on the possible worlds that fit the description, ergo the whole point of this endeavour? 


calling something a lie and stating provenance are rather worn-out examples at what i consider the fringes of the problem space. what i find much more interesting is qualification of statements, akin to n-ary relations with a primary player, or Property Graph style modelling, e.g.
    {:Alice :buys :Car } :on :Friday ; 
                         :for :FunRiding;
                         :with :Cash .
according to the expressed intent of its authors the spec makes such qualifications illegal, because non-monotonic. they would change the meaning of the statement. but do they really? don't they just provide further details, thereby narrowing down the possible worlds in which this statement is true? that would be the most normal thing to do. take the following example:
    :Alice :buys [ 
                    rdf:value :Car ;
                    :on :Friday ; 
                    :for :FunRiding;
                    :with :Cash
                ]
i consider this the exact same assertion modulo the fact that rdf:value deplorably has only non-normative semantics. it is definitely perfectly legal.

consider another example:
    :Alice :hairColor :Brown .
:Alice is an identifier and supposed to be monotonic: "a single URI reference can be taken to have the same meaning wherever it occurs" [1]. IMHO asserting that the color of ALice's hair is brown changes the meaning of :Alice. this is now a more specific :Alice than it was before. if one doesn't agree that the meaning of :ALice isn't changed by that assertion then what about the following construct:
    [ rdf:value :Alice ; :hairColor :Brown ]
i think there is no appreciable difference in meaning between the two constructs and adding the hair color information definitely changed the meaning of the existential.

now let's take this one step further:
    [ rdf:value :Alice , :hairColor :Brown; :age 18 ]
        :buys [ rdf:value :Car ; :color :Red ; :age 21 ]
again this is legal RDF and its meaning is well-defined. but nobody models like that because it is quite unreadable. it could however with the same meaning, but much more readable, be expressed as an annotated statement. let's extend the {...} syntax by a statement identifier and by refrences to terms in that statement:
    { :Alice :buys :Car }@id:1
    id:1#subject :hairColor :Brown; :age 18 .
    id:1#object :color :Red ; :age 21 .
if only we could have blank nodes in predicate position then we could also describe the following in ordinary RDF:
    id:1#predicate :paymentMethod :Cash . 
there are qualifications that rather belong to the whole statement than the predicate
    id:1 :on :Friday ; 
         :for :FunRiding ;
         :source :Thomas .
i'm leaving open the question if the source attribute refers to the triple itself (as a piece of code, created in a kind of speech act) or if it refers to the interpretation (what the triple is about, its meaning). that is HTTPRange-14 territory and may be discussed another time
         

so, to re-capitulate: what is the problem of qualifying a statement with further detail about the statement itself (as a piece of code), what it refers to, its subject, its predicate and its object?
or, in contrast: what makes the tedious, blank node heavy equivalent using existentials okay?

Also I claim that in practice the Semantic Web is largely non-monotonic because the identifiers are used in non-monotonic ways. If we would really follow the concept to the letter we’d have to replace most nodes with blank nodes, adding a pointer to the "main" value and further qualifying attributes because very few things are actually universally true. But doing so would destroy the concept of easy navigation from node A to node B to node C - as they’d all be blank nodes… Monotonicity is an ideal that in practice is largely un-achievable if we also want to be succinct and usable.


And now please forgive me that I subtly change the topic towards the future of the Semantic Web in general and RDF-star in particular with a rant, but the argument "Monotonicity" was recently brought forward to justify the design (and limitations) of RDF-star. However that was on Twitter and that 140 characters medium IMHO is the least suitable environment to discuss issues of meta-modeling on the Semantic Web (as you can probably tell by the length of this mail alone, ahem). So, the rant:
The Semantic Web is inherently non-monotonic because it only offers out-of-band means to manage conflicts. What? Yes: if you want something to be useful but deny it the necessary instruments it will either collapse (which thankfully the Semantic Web didn't) or it will find other means, and that's what the Semantic Web in practice does: it isn't self-contained but needs out-of-band means like application logic to manage contradictions and necessary or suitable constraints. 
We really need a mechanism to qualify and relate statements and graphs, specify semantics on demand, to close worlds locally. And we’ve known this for 20 years. I’ve recently looked into papers from around 2004 when RDF 1.0 was standardized. This problem has been alluded to, solutions have been demanded, reminded, promised, deemed indispensable, sketched - literally decades ago [2]. And where are we now? Very pragmatically not one step further. This maybe is a failure of leadership, e.g. of how the RDF 1.1 WG was set up and then managed. But when I read proposals from that time I'm tempted to agree with the pragmatists that a solid understanding had not yet been developed (although Pat Hayes' BLogic talk from ISWC 2009 provided a pretty good basis). It is really a hard problem. But there is also a problem of lack of ambition on a broader scale: the Semantic Web is tackling issues of knowledge representation that are indeed very hard, with the most simplistic of mechanisms. It does solve 80% of use cases - which is great - but thinks it can ignore the missing 20% (which are of course the hardest work, as always) and get away with it. Nope. 

I suspect that either we do semantics correctly, and fully, or application specific solutions will prevail. It is just too hard and too frustrating to navigate the shallows of RDF semantics, where well-defined formalisms gradually morph into mere intuitions and application-specific anarchy. Look at the example above about provenance annotation: the generally accepted solution is purely pragmatic but it is not sound. To successfully master those areas with confidence one has to be a pretty darn good semanticist, or not stray from the beaten paths or just hope for the best. That is not a sustainable value proposition in the long run. So giving up is not an option.

This is a problem that goes well beyond what the currently en vogue RDF-star proposal could possibly tackle. RDF-star is just the spacer.gif of the Semantic Web, one more band aid (with a formal semantics, but a completely bizarre and unproven one [3]). IMO we need some equivalent to what CSS did for HTML, a true breakthrough in expressivity: a well designed mechanism to establish locally closed worlds in which for example qualification of statements (or graphs) is well-defined. 
In the traditional open world of RDF those qualified statements (or graphs) would then indeed translate to the blank-node-heavy constructs sketched above, akin to Assembler code, so it would need a good surface syntax (nested graphs with proper identifiers and configurable semantics, I assume). But on the positive side it would also be correct and not the dangerous mix of open world theory and de-facto out-of-band localized practice that we have today. Everything less amounts to bricolage and hapless hand-waving. I think that after 20 years of coping we should be able to do better. 

CSS did what it had to do and proposed what was by no means a trivial upgrade, targeting a bunch of web-developer turned graphics designers. But it did succeed and it reigns supreme today because people are not stupid and not lazy when they are convinced of the need [4]. RDF-star is getting into triple stores all over the place although it is neither easy to implement nor well thought out. There is an immense desire to get this topic finally resolved and off the table. We _can_ do something big… Currently work is under way to set up a two-year W3C Working Group to standardize RDF-star and make it RDF 1.2 or even RDF 2.0. IMO that is a recipe for another wasted decade and maybe finally the way into well-deserved decay and irrelevance. Instead set up a two year WG to think big, to make bold proposals, encourage people to pick up and finish old works or completely new approaches. Set the WG up as a two year incubator of discussions what we really want, not as a task force to figure out what we minimally could get by with. Make it clear that we urgently need to develop criteria and a proper understanding of the problem space. Make it clear that big proposals are welcomed, not frowned upon. Make those discussions as public as possible. Then decide, and standardize.


Thomas







[0] imagine we had used RDF-star instead of that made-up {...} syntax:
    :Car :is :Red .
    << :Car :is :Red >> :statedBy :Thomas .
    :Thomas a :Liar .
is RDF-star introducing paradoxes into RDF?
the same could be asked for RDF reification but that refers to occurrences whereas RDF-star quoted triples refer to the type
(according to the proposed semantics of RDF-star the quoted triple << :Car :is :Red >> refers to an entity in the universe of discourse, namely the interpretation of the statement that some car is red, but only when those exact terms :Car, :is and :Red are used. so e.g. no co-reference with :Automobile etc. but in our case this is exactly the triple that has been stated. and the quoted triple refers to any triple of that type (not to occurrences as RDF reification does)) 
but i disgress

[1] from RDF 1.0 Semantics (https://www.w3.org/TR/rdf-mt). unfortunately the RDF 1.1 Semantics deleted much of the IMHO very helpful discussions of the semantics that 1.0 provided. i suppose they are still valid though.

[2] see for example especially the very last paragraph from this discussion of the merits of monotonicity by Pat Hayes: https://lists.w3.org/Archives/Public/www-rdf-logic/2001Jul/0067.html

[3] Correction: actually it is proven to not be followed by anyone. I see people jumping on RDF-star and showcasing it with examples that clearly don’t properly reflect the proposed semantics (actually all examples I’ve seen are quite incorrect, including those from RDF-star editors). I see people arguing in favor of RDF-star with arguments that don’t hold anywhere on the Semantic Web. I see people questioning RDF-star with arguments that don’t hold anywhere on the Semantic Web. Lots and lots of works have been brought forward in this area so I can definitely understand the desire to get done with and believe in the promises of RDF-star. But such a simplistic proposal just can't cover the needs. Most of those works where hoping for and targeting very simple solutions, the one genius idea, the missing bit. I actually see very little true engagement for a sound and solid solution, for a grand design - partly because it’s hard indeed but partly also because nobody believes in our ability to pull off something really good, "stores won't implement it", "users won't accept it" etc. And that’s a shame. 

[4] You can probably tell that I was a passionate web designer back then.


