module Ui.Checkbox exposing
  ( Model, Msg, init, onChange, update, view, render, viewToggle
  , renderToggle, viewRadio, renderRadio, setValue )

{-| Checkbox component with three different views (checkbox, radio, toggle).

# Model
@docs Model, Msg, init, update

# Events
@docs onChange

# Views
@docs view, render

# View Variations
@docs viewRadio, viewToggle, renderRadio, renderToggle

# Functions
@docs setValue
-}

import Html.Attributes exposing (attribute)
import Html.Events.Extra exposing (onKeys)
import Html.Events exposing (onClick)
import Html exposing (node)
import Html.Lazy

import Ui.Helpers.Emitter as Emitter
import Ui.Native.Uid as Uid
import Ui


{-| Representation of a checkbox:
  - **disabled** - Whether or not the checkbox is disabled
  - **readonly** - Whether or not the checkbox is readonly
  - **value** - Whether or not the checkbox is checked
  - **uid** - The unique identifier of the checkbox
-}
type alias Model =
  { disabled : Bool
  , readonly : Bool
  , value : Bool
  , uid : String
  }


{-| Messages that a checkbox can receive.
-}
type Msg
  = Toggle


{-| Initiaizes a checkbox with the given value.

    checkbox = Ui.Checkbox.init ()
-}
init : () -> Model
init _ =
  { uid = Uid.uid ()
  , disabled = False
  , readonly = False
  , value = False
  }


{-| Subscribe to the changes of a checkbox.

    Ui.Calendar.onChange CheckboxChanged checkbox
-}
onChange : (Bool -> a) -> Model -> Sub a
onChange msg model =
  Emitter.listenBool model.uid msg


{-| Updates a checkbox.

    Ui.Checkbox.update msg checkbox
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    Toggle ->
      let
        value =
          not model.value
      in
        ( { model | value = value }, Emitter.sendBool model.uid value )


{-| Lazily renders a checkbox.

    Ui.Checkbox.view checkbox
-}
view : Model -> Html.Html Msg
view model =
  Html.Lazy.lazy render model


{-| Renders a checkbox.

    Ui.Checkbox.render checkbox
-}
render : Model -> Html.Html Msg
render model =
  node
    "ui-checkbox"
    (attributes model)
    [ Ui.icon "checkmark" False [] ]


{-| Lazily renders a checkbox as a radio.

    Ui.Checkbox.viewRadio checkbox
-}
viewRadio : Model -> Html.Html Msg
viewRadio model =
  Html.Lazy.lazy renderRadio model


{-| Renders a checkbox as a radio.

    Ui.Checkbox.renderRadio checkbox
-}
renderRadio : Model -> Html.Html Msg
renderRadio model =
  node
    "ui-checkbox-radio"
    (attributes model)
    [ node "ui-checkbox-radio-circle" [] []
    ]


{-| Lazily renders a checkbox as a toggle.

    Ui.Checkbox.viewToggle checkbox
-}
viewToggle : Model -> Html.Html Msg
viewToggle model =
  Html.Lazy.lazy renderToggle model


{-| Renders a checkbox as a toggle.

    Ui.Checkbox.renderToggle checkbox
-}
renderToggle : Model -> Html.Html Msg
renderToggle model =
  node
    "ui-checkbox-toggle"
    (attributes model)
    [ node "ui-checkbox-toggle-bg" [] []
    , node "ui-checkbox-toggle-handle" [] []
    ]


{-| Sets the value of a checkbox to the given one.

    Ui.Checkbox.setValue False checkbox
-}
setValue : Bool -> Model -> Model
setValue value model =
  { model | value = value }


{-| Returns attributes for a checkbox.
-}
attributes : Model -> List (Html.Attribute Msg)
attributes model =
  let
    disabled =
      if model.disabled then
        [ attribute "disabled" "" ]
      else
        []

    readonly =
      if model.readonly then
        [ attribute "readonly" "" ]
      else
        []

    checked =
      if model.value then
        [ attribute "checked" "" ]
      else
        []

    actions =
      Ui.enabledActions
        model
        [ onClick Toggle
        , onKeys True
            [ ( 13, Toggle )
            , ( 32, Toggle )
            ]
        ]
  in
    [ Ui.tabIndex model
    , disabled
    , readonly
    , checked
    , actions
    ]
    |> List.concat
