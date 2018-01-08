module Main exposing (..)

import Spec exposing (..)
import Steps exposing (..)
import Task
import Json.Encode as Json
import Ui.Native.Uid as Uid
import Date.Extra.Format exposing (isoDateFormat, format)
import Date
import Ext.Date
import Ui.DateRangePicker as DRP exposing (setCalendarValue, setValue, WhichDatePicker(..), disableWhich)
import Ui.DatePicker
import Html exposing (..)
import Html.Attributes exposing (class)


type alias Model =
    { simple : DRP.Model
    , oneDisabled : DRP.Model
    , withPreselectedDates : DRP.Model
    , readOnly : DRP.Model
    }


type Msg
    = Simple DRP.Msg
    | OneDisabled DRP.Msg
    | WithPreselectedDates DRP.Msg
    | ReadOnly DRP.Msg


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
        ({ simple = DRP.init ()
         , oneDisabled =
            disableWhich First (DRP.init ())
         , withPreselectedDates =
            setValue (setCalendarValue (\c -> { c | value = (Ext.Date.createDate 2018 5 20), date = (Ext.Date.createDate 2018 5 20) })) First (DRP.init ())
                |> setValue (setCalendarValue (\c -> { c | value = (Ext.Date.createDate 2018 5 28), date = (Ext.Date.createDate 2018 5 28) })) Second
         , readOnly =
            setValue (setCalendarValue (\c -> { c | readonly = True, value = (Ext.Date.createDate 2018 5 20), date = (Ext.Date.createDate 2018 5 20) })) First (DRP.init ())
                |> setValue (setCalendarValue (\c -> { c | readonly = True, value = (Ext.Date.createDate 2018 5 28), date = (Ext.Date.createDate 2018 5 28) })) Second
         }
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
    case msg_ of
        Simple msg ->
            let
                ( updatedModel, cmd ) =
                    DRP.update msg model.simple
            in
                ( { model | simple = updatedModel }, Cmd.none )

        OneDisabled msg ->
            let
                ( updatedModel, cmd ) =
                    DRP.update msg model.oneDisabled
            in
                ( { model | oneDisabled = updatedModel }, Cmd.none )

        WithPreselectedDates msg ->
            let
                ( updatedModel, cmd ) =
                    DRP.update msg model.withPreselectedDates
            in
                ( { model | withPreselectedDates = updatedModel }, Cmd.none )

        ReadOnly msg ->
            let
                ( updatedModel, cmd ) =
                    DRP.update msg model.readOnly
            in
                ( { model | readOnly = updatedModel }, Cmd.none )


uiSnapshot : String -> String -> Html Msg -> Html Msg
uiSnapshot title key ui =
    div [ class key ]
        [ text title
        , ui
        ]


view : Model -> Html.Html Msg
view model =
    div []
        [ uiSnapshot "Without Presets" "without-presets" (Html.map Simple (DRP.view "en_us" model.simple))
        , uiSnapshot "With One Disabled Date Picker" "one-disabled" (Html.map OneDisabled (DRP.view "en_us" model.oneDisabled))
        , uiSnapshot "With Preselected Dates" "preselected" (Html.map WithPreselectedDates (DRP.view "en_us" model.withPreselectedDates))
        , uiSnapshot "With A Readonly Date Picker" "readonly" (Html.map ReadOnly (DRP.view "en_us" model.readOnly))
        ]


specs : Node
specs =
    describe "Ui.DateRangePicker"
        [ it "displays two calendars"
            [ assert.elementPresent ".without-presets ui-picker:nth-child(1)"
            , assert.elementPresent ".without-presets ui-picker:nth-child(2)"
            ]
        , it "should be disableable"
            [ assert.elementPresent ".one-disabled ui-picker[disabled]"
            , assert.elementPresent ".one-disabled ui-picker"
            ]
        , it
            "should allow preselection of dates"
            [ assert.containsText { selector = ".preselected ui-picker:nth-child(1)", text = "2018-05-20" }
            , assert.containsText { selector = ".preselected ui-picker:nth-child(2)", text = "2018-05-28" }
            ]
        , it
            "should be able to set calendars to be read only"
            [ assert.elementPresent ".readonly ui-picker:nth-child(1) ui-calendar[readonly]"
            , assert.elementPresent ".readonly ui-picker:nth-child(2) ui-calendar[readonly]"
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
