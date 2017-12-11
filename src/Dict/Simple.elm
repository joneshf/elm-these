module Dict.Simple
    exposing
        ( merge
        )

{-|

@docs merge

-}

import Dict
import Dict exposing (Dict)
import These exposing (These(This, That, These))


{-| The definition of [Dict.merge](http://package.elm-lang.org/packages/elm-lang/core/latest/Dict#merge)
leaves something to be desired.

We provide a simpler version here that takes one function for the merging.
You can handle all the cases in your one supplied function.
If you use the functions from [These](http://package.elm-lang.org/packages/joneshf/elm-these/latest/These),
you can probably inline it.

The version in core requires you to write three separate functions to work with it.
The reason it does this is because there's no "inclusive-or" abstraction in core.
So, we're forced to deal with this more complex function.

---

Fun fact:

The core [Dict.merge](http://package.elm-lang.org/packages/elm-lang/core/latest/Dict#merge)
actually encodes [These](http://package.elm-lang.org/packages/joneshf/elm-these/latest/These)
with a [Boehm-Berarducci](http://okmij.org/ftp/tagless-final/course/Boehm-Berarducci.html) encoding.

It's basically Church encoding, but typed.
-}
merge :
    (comparable -> These a b -> result -> result)
    -> Dict comparable a
    -> Dict comparable b
    -> result
    -> result
merge f =
    Dict.merge
        (\x -> f x << This)
        (\x y -> f x << These y)
        (\x -> f x << That)
