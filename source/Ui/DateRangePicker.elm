module Ui.DateRangePicker exposing (..)

import Html exposing (..)
import Time
import Ui.DatePicker
import Ui.Helpers.Picker as Picker
import Ui.Calendar


type alias Model =
    { datePicker1 : Ui.DatePicker.Model
    , datePicker2 : Ui.DatePicker.Model
    }


{-| Msg is messaging that's been contextualized per date picker
-}
type Msg
    = Calendar1 Ui.DatePicker.Msg
    | Calendar2 Ui.DatePicker.Msg


init : () -> Model
init _ =
    { datePicker1 = Ui.DatePicker.init ()
    , datePicker2 = Ui.DatePicker.init ()
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Calendar1 calendarMsg ->
            let
                ( updatedModel, effect ) =
                    Ui.DatePicker.update calendarMsg model.datePicker1
            in
                ( { model | datePicker1 = updatedModel }, Cmd.map Calendar1 effect )

        Calendar2 calendarMsg ->
            let
                ( updatedModel, effect ) =
                    Ui.DatePicker.update calendarMsg model.datePicker2
            in
                ( { model | datePicker2 = updatedModel }, Cmd.map Calendar2 effect )


view : String -> Model -> Html Msg
view locale model =
    div []
        [ Html.map Calendar1 (Ui.DatePicker.view locale model.datePicker1)
        , Html.map Calendar2 (Ui.DatePicker.view locale model.datePicker2)
        ]
