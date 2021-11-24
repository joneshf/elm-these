module These exposing
    ( These(..)
    , these, mapThis, mapThat, mapBoth
    , mergeWith, merge
    , align
    )

{-| A type that may be an `a`, a `b`, or both an `a` and a `b` at once.

@docs These


# Mapping

@docs these, mapThis, mapThat, mapBoth


# Collapsing / Transforming

@docs mergeWith, merge


# Collections

@docs align

-}


{-| This type is very closely related to [Result a b](http://package.elm-lang.org/packages/elm-lang/core/latest/Result#Result).

While [Result a b](http://package.elm-lang.org/packages/elm-lang/core/latest/Result#Result)
models exclusive-or, this type models inclusive-or.

-}
type These a b
    = This a
    | That b
    | These a b


{-| Replace any `a`s with `c`s.

    mapThis negate (This 1) == This -1

    mapThis negate (That "hello") == That "hello"

    mapThis negate (These 1 "hello") == These -1 "hello"

-}
mapThis : (a -> c) -> These a b -> These c b
mapThis f =
    mapBoth f identity


{-| Replace any `b`s with `c`s

    mapThat String.reverse (This 1) == This 1

    mapThat String.reverse (That "hello") == That "olleh"

    mapThat String.reverse (These 1 "hello") == These 1 "olleh"

-}
mapThat : (b -> c) -> These a b -> These a c
mapThat f =
    mapBoth identity f


{-| Replace any `a`s with `c`s and replace any `b`s with `d`s.

    mapBoth negate String.reverse (This 1) == This -1

    mapBoth negate String.reverse (That "hello") == That "olleh"

    mapBoth negate String.reverse (These 1 "hello") == These -1 "olleh"

-}
mapBoth : (a -> c) -> (b -> d) -> These a b -> These c d
mapBoth f g =
    these (This << f) (That << g) (\a b -> These (f a) (g b))


{-| Destroy the structure of a [These a b](#These).

The first two functions are applied to the `This a` and `That b` values, respectively.
The third function is applied to the `These a b` value.

    these String.fromInt String.reverse (String.fromInt >> identity) (This 1) == "1"

    these String.fromInt String.reverse (String.fromInt >> identity) (That "hello") == "olloh"

    these String.fromInt String.reverse (String.fromInt >> identity) (These 1 "hello") == "1hello"

-}
these : (a -> c) -> (b -> c) -> (a -> b -> c) -> These a b -> c
these f g h t =
    case t of
        This a ->
            f a

        That b ->
            g b

        These a b ->
            h a b


{-| A version of [mergeWith](#mergeWith) that does not modify the `This a` or `That a` values.

    merge (+) (This 1) == 1

    merge (+) (That 2) == 2

    merge (+) (These 1 2) == 3

-}
merge : (a -> a -> a) -> These a a -> a
merge =
    these identity identity


{-| Similar to [these](#these).

The difference is that in the `These a b` case
we apply the second and third functions and merge the results with the first function.

    mergeWith (++) String.fromInt String.reverse (This 1) == "1"

    mergeWith (++) String.fromInt String.reverse (That "hello") == "olloh"

    mergeWith (++) String.fromInt String.reverse (These 1 "hello") == "1olloh"

-}
mergeWith : (c -> c -> c) -> (a -> c) -> (b -> c) -> These a b -> c
mergeWith f g h =
    these g h (\x y -> f (g x) (h y))


{-| Similar to [List.Extra.zip](http://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#zip)
except the resulting list is the length of the longer list.

We can also think of this from a relational algebra perspective (or SQL if that's your thing).
We view each list as a relation (table) where the primary key is its index in the list.
Then [List.Extra.zip](http://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#zip)
can be viewed as a natural join (inner join),
and [align](#align) can be viewed as a full outer join.

    align [ 1, 2 ] [ "foo", "bar" ] == [ These 1 "foo", These 2 "bar" ]

    align [ 1 ] [ "foo", "bar" ] == [ These 1 "foo", That "bar" ]

    align [ 1, 2 ] [ "foo" ] == [ These 1 "foo", This 2 ]

-}
align : List a -> List b -> List (These a b)
align =
    align_ []


align_ : List (These a b) -> List a -> List b -> List (These a b)
align_ acc xss yss =
    case ( xss, yss ) of
        ( [], [] ) ->
            List.reverse acc

        ( x :: xs, [] ) ->
            align_ (This x :: acc) xs []

        ( [], y :: ys ) ->
            align_ (That y :: acc) [] ys

        ( x :: xs, y :: ys ) ->
            align_ (These x y :: acc) xs ys
