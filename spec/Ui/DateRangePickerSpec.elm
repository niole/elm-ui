module Main exposing (..)

import Spec exposing (..)
import Steps exposing (..)
import Json.Encode as Json
import Ui.DateRangePicker
import Ui.DatePicker
import Html exposing (..)


type alias Model =
    { one : Ui.DateRangePicker.Model
    }


type Msg
    = One Ui.DateRangePicker.Msg


init : () -> Model
init _ =
    { one = Ui.DateRangePicker.init () }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
    case msg_ of
        One msg ->
            let
                ( updatedModel, cmd ) =
                    Ui.DateRangePicker.update msg model.one
            in
                ( { model | one = updatedModel }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ Html.map One (Ui.DateRangePicker.view "en_us" model.one)
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
