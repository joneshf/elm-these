# elm-these

A library providing "inclusive-or" as opposed to [Result a b][]'s "exclusive-or".

If you interpret [Result a b][] as suggesting the computation may either fail or succeed (exclusively),
then [These a b][] may fail, succeed, or do both at the same time.

There are a few ways to interpret the both case:

* You can think of a computation that has a non-fatal error.
* You can think of a computation that went as far as it could before erroring.
* You can think of a computation that keeps track of errors as it completes.

Pretty open to interpretation here.

Another way you can think of [These a b][] is saying that we want to handle `a` kind of data, `b` kind of data, or both `a` and `b` kind of data at the same time.
This is particularly useful when it comes to displaying UI's.

## Example

Cribbed from: [Basic behavioral composition][]

Let's say you want to design a button with three different views:

1. A button with only a label.
1. A button with only an icon.
1. A button with both a label and an icon.

These are the three distinctions between otherwise similar buttons.
Some commonalities between all buttons are:

* Msg can be one of `Button`, `Reset`, or `Submit`.
* Design can be either `Primary` or `Secondary`.
...

Let's try and model this.
Let's say labels have a string to show.
Let's say icons have a class to apply.

```elm
type Msg
  = Button
  | Reset
  | Submit

type Design
  = Primary
  | Secondary

type Icon
  = Icon String

type Label
  = Label String

type alias Button =
  { model : These Label Icon
  , msg : Msg
  , design : Design
  }
```

When we want to display the view we can take a monolithic approach and do it all in one function,
or we can split it up into small modular functions.
Let's look at both so we can judge for ourselves which we like best.

## Monolithic view

```elm
view : Button -> Html Msg
view { design, model, msg } =
  case model of
    This (Label label) ->
      button
        [ class (String.toLower (toString design)
        , onClick msg
        ]
        [ text label
        ]

    That (Icon glyph) ->
      button
        [ class (String.toLower (toString design)
        , onClick msg
        ]
        [ span [class glyph] []
        ]

    These (Label label) (Icon glyph) ->
      button
        [ class (String.toLower (toString design)
        , onClick msg
        ]
        [ span [class glyph] []
        , text label
        ]
```

## Modular views

```elm
view : Button -> Html Msg
view button =
  button.model
    |> These.mergeWith (++) (singleton << viewLabel) (singleton << viewIcon)
    |> viewButton button

viewButton : Button -> List (Html Msg) -> Html Msg
viewButton { design, msg } children =
  button
    [ class (String.toLower (toString design)
    , onClick msg
    ]
    children

viewIcon : Icon -> Html msg
viewIcon (Icon glyph) =
  span [class glyph] []

viewLabel : Label -> Html msg
viewLabel (Label label) =
  text label

singleton : a -> List a
singleton x =
  [x]
```

These are just two ways to decompose the problem.
There are many other ways.
Which you prefer is up to you. :)

[Basic behavioral composition]:  https://groups.google.com/d/msg/elm-discuss/VBSYiMnftzQ/FyEVQxS_BAAJ
[Result a b]: http://package.elm-lang.org/packages/elm-lang/core/latest/Result#Result
[These a b]: http://package.elm-lang.org/packages/joneshf/elm-these/latest/These#These
