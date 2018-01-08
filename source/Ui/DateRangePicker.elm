module Ui.DateRangePicker exposing (WhichDatePicker(..), Model, Msg, init, update, view, onSecondDatePickerChange, onFirstDatePickerChange, setCalendarValue, setValue, closeWhichOnSelect, disableWhich, disable)

import Html exposing (..)
import Time
import Ui.Container
import Ui.DatePicker
import Ui.Calendar


type alias Model =
    { datePicker1 : Ui.DatePicker.Model
    , datePicker2 : Ui.DatePicker.Model
    }


type WhichDatePicker
    = First
    | Second


{-| Msg is messaging that's been contextualized per date picker
-}
type Msg
    = DatePicker1 Ui.DatePicker.Msg
    | DatePicker2 Ui.DatePicker.Msg


init : () -> Model
init _ =
    { datePicker1 = Ui.DatePicker.init ()
    , datePicker2 = Ui.DatePicker.init ()
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DatePicker1 calendarMsg ->
            let
                ( updatedModel, effect ) =
                    Ui.DatePicker.update calendarMsg model.datePicker1
            in
                ( { model | datePicker1 = updatedModel }, Cmd.map DatePicker1 effect )

        DatePicker2 calendarMsg ->
            let
                ( updatedModel, effect ) =
                    Ui.DatePicker.update calendarMsg model.datePicker2
            in
                ( { model | datePicker2 = updatedModel }, Cmd.map DatePicker2 effect )


view : String -> Model -> Html Msg
view locale model =
    Ui.Container.row []
        [ Html.map DatePicker1 (Ui.DatePicker.view locale model.datePicker1)
        , Html.map DatePicker2 (Ui.DatePicker.view locale model.datePicker2)
        ]


{-| Subscribe to the changes of an individual date picker.

e.g.

subscriptions =
Ui.DateRangePicker.onSecondDatePickerChange DateRangePickerChanged datePicker

-}
onSecondDatePickerChange : (Time.Time -> msg) -> Model -> Sub msg
onSecondDatePickerChange msg model =
    Ui.DatePicker.onChange msg model.datePicker2


onFirstDatePickerChange : (Time.Time -> msg) -> Model -> Sub msg
onFirstDatePickerChange msg model =
    Ui.DatePicker.onChange msg model.datePicker1



{--
Helpful setters
-}


setCalendarValue : (Ui.Calendar.Model -> Ui.Calendar.Model) -> Ui.DatePicker.Model -> Ui.DatePicker.Model
setCalendarValue setter picker =
    { picker | calendar = setter picker.calendar }


setValue : (Ui.DatePicker.Model -> Ui.DatePicker.Model) -> WhichDatePicker -> Model -> Model
setValue updater which picker =
    case which of
        First ->
            { datePicker2 = picker.datePicker2
            , datePicker1 = updater picker.datePicker1
            }

        Second ->
            { datePicker2 = updater picker.datePicker2
            , datePicker1 = picker.datePicker1
            }


closeWhichOnSelect : Bool -> WhichDatePicker -> Model -> Model
closeWhichOnSelect value which model =
    setValue (\d -> Ui.DatePicker.closeOnSelect value d) which model


disableWhich : WhichDatePicker -> Model -> Model
disableWhich which picker =
    setValue (\d -> { d | disabled = True }) which picker


disable : Model -> Model
disable picker =
    let
        disabler =
            (\d -> { d | disabled = True })
    in
        setValue disabler First picker
            |> setValue disabler Second
