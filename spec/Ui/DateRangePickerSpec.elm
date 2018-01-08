module Main exposing (..)

import Spec exposing (..)
import Steps exposing (..)
import Task
import Json.Encode as Json
import Ui.Native.Uid as Uid
import Date.Extra.Format exposing (isoDateFormat, format)
import Date
import Ext.Date
import Ui.DateRangePicker
import Ui.DatePicker
import Ui.Calendar exposing (..)
import Html exposing (..)
import Ui.Helpers.Dropdown as Dropdown exposing (Dropdown)


type alias Model =
    { simple : Ui.DateRangePicker.Model
    , oneDisabled : Ui.DateRangePicker.Model
    , withPreselectedDates : Ui.DateRangePicker.Model
    , readOnly : Ui.DateRangePicker.Model
    }


type Msg
    = Simple Ui.DateRangePicker.Msg
    | OneDisabled Ui.DateRangePicker.Msg
    | WithPreselectedDates Ui.DateRangePicker.Msg
    | ReadOnly Ui.DateRangePicker.Msg


init : () -> Model
init _ =
    let
        firstDatePicker =
            Ui.DatePicker.init ()

        secondDatePicker =
            Ui.DatePicker.init ()

        firstCalendar =
            firstDatePicker.calendar

        secondCalendar =
            secondDatePicker.calendar
    in
        ({ simple = Ui.DateRangePicker.init ()
         , oneDisabled =
            { datePicker1 = { firstDatePicker | disabled = True }
            , datePicker2 = secondDatePicker
            }
         , withPreselectedDates =
            let
                updatedCalendar1 =
                    { firstCalendar | value = (Ext.Date.createDate 2018 5 20), date = (Ext.Date.createDate 2018 5 20) }

                updatedCalendar2 =
                    { secondCalendar | value = (Ext.Date.createDate 2018 5 28), date = (Ext.Date.createDate 2018 5 28) }
            in
                { datePicker1 = { firstDatePicker | calendar = updatedCalendar1 }
                , datePicker2 = { secondDatePicker | calendar = updatedCalendar2 }
                }
         , readOnly =
            let
                updatedCalendar1 =
                    { firstCalendar | readonly = True }

                updatedCalendar2 =
                    { secondCalendar | readonly = True }
            in
                { datePicker1 = { firstDatePicker | calendar = updatedCalendar1 }
                , datePicker2 = { secondDatePicker | calendar = updatedCalendar2 }
                }
         }
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
    case msg_ of
        Simple msg ->
            let
                ( updatedModel, cmd ) =
                    Ui.DateRangePicker.update msg model.simple
            in
                ( { model | simple = updatedModel }, Cmd.none )

        OneDisabled msg ->
            let
                ( updatedModel, cmd ) =
                    Ui.DateRangePicker.update msg model.oneDisabled
            in
                ( { model | oneDisabled = updatedModel }, Cmd.none )

        WithPreselectedDates msg ->
            let
                ( updatedModel, cmd ) =
                    Ui.DateRangePicker.update msg model.withPreselectedDates
            in
                ( { model | withPreselectedDates = updatedModel }, Cmd.none )

        ReadOnly msg ->
            let
                ( updatedModel, cmd ) =
                    Ui.DateRangePicker.update msg model.readOnly
            in
                ( { model | readOnly = updatedModel }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ Html.map Simple (Ui.DateRangePicker.view "en_us" model.simple)
        , Html.map OneDisabled (Ui.DateRangePicker.view "en_us" model.oneDisabled)
        , Html.map WithPreselectedDates (Ui.DateRangePicker.view "en_us" model.withPreselectedDates)
        , Html.map ReadOnly (Ui.DateRangePicker.view "en_us" model.readOnly)
        ]


specs : Node
specs =
    describe "Ui.DateRangePicker"
        [ it "displays two calendars"
            [ assert.elementPresent "ui-picker:nth-child(1)"
            , assert.elementPresent "ui-picker:nth-child(2)"
            ]
        ]


main =
    runWithProgram
        { subscriptions = \_ -> Sub.none
        , update = update
        , init = init
        , view = view
        }
        specs
