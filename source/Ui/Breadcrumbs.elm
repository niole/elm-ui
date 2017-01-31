module Ui.Breadcrumbs exposing (..)

{-| This module provides a view for rendering breadcrumbs.

@docs view
-}

import Html.Attributes exposing (attribute)
import Html exposing (node)

import Ui.Styles.Breadcrumbs exposing (defaultStyle)
import Ui.Styles
import Ui.Link

import Maybe

{-| Renders breadcrumbs.

    Ui.Breadcrumbs.view
      (text "|")
      [ { contents = [ text "Home" ]
        , target = Nothing
        , msg = Just Home
        , url = Just "/"
        }
      , { contents = [ text "Posts" ]
        , target = Nothing
        , msg = Just Posts
        , url = Just "/posts"
        }
      , { contents = [ text "Github" ]
        , target = Just "_blank"
        , msg = Just Github
        , url = Just "www.github.com"
        }
      ]
-}
view : Html.Html msg -> List (Ui.Link.Model msg) -> Html.Html msg
view separator items =
  let
    renderedItems =
      items
        |> List.map renderItem
        |> List.intersperse (node "ui-breadcrumb-separator" [] [ separator ])

    renderItem item =
      let
        attributes =
          case ( item.url, item.msg ) of
            ( Nothing, Nothing ) ->
              []
            _ ->
              [ attribute "clickable" "" ]
      in
        node "ui-breadcrumb" attributes [ Ui.Link.view item ]
  in
    node "ui-breadcrumbs" (Ui.Styles.apply defaultStyle) renderedItems