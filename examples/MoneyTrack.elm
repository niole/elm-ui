module Main where

import StartApp
import Effects
import Signal exposing (forwardTo)
import Task
import List
import Storage.Local
import Html.Events exposing (onClick)
import Html exposing (div, text)
import Ext.Date
import List.Extra
import Native.Uid
import Date

import Ui.NumberPad
import Ui.Chooser
import Ui.DatePicker
import Ui.Container
import Ui.App
import Ui

import Debug exposing (log)

type Action
  = App Ui.App.Action
  | NumberPad Ui.NumberPad.Action
  | AccountChooser Ui.Chooser.Action
  | CategoryChooser Ui.Chooser.Action
  | DatePicker Ui.DatePicker.Action
  | Load
  | Save

{- Represents a transaction. -}
type alias Transaction =
  { id : String
  , amount : Int
  , comment : String
  , category : Category
  , date : Date.Date
  }

{- Represents a category. -}
type alias Category =
  { id : String
  , icon : String
  , name : String
  }

{- Represents an account. -}
type alias Account =
  { id : String
  , initialBalance: Int
  , name : String
  , icon : String
  , transactions : List Transaction
  }

accountBalance : Account -> Int
accountBalance account =
  let
    transactionBalance =
      List.map .amount account.transactions
        |> List.foldr (+) 0
  in
    account.initialBalance + transactionBalance

balance : List Account -> Int
balance accounts =
  List.map accountBalance accounts
    |> List.foldr (+) 0

initialCategories : List Category
initialCategories =
  [ { id = "0", name = "Bills", icon = "cash" }
  , { id = "1", name = "Transportation", icon = "android-bus" }
  , { id = "2", name = "Food", icon = "android-cart" }
  ]

updateChoosers model =
  let
    mapItem item =
      { value = item.id, label = item.name }

    categories =
      List.map mapItem model.categories

    accounts =
      List.map mapItem model.accounts
  in
    { model | categoryChooser = Ui.Chooser.updateData categories model.categoryChooser
            , accountChooser = Ui.Chooser.updateData accounts model.accountChooser }

init =
  ({ app = Ui.App.init
   , numberPad = Ui.NumberPad.init 0
   , categoryChooser = Ui.Chooser.init [] "Category..." ""
   , accountChooser = Ui.Chooser.init [] "Account..." ""
   , datePicker = Ui.DatePicker.init Ext.Date.now
   , data = ""
   , categories = initialCategories
   , accounts = [ { id = "0"
                  , initialBalance = 0
                  , name = "Bank Card"
                  , icon = ""
                  , transactions = []
                  }
                , { id = "1"
                  , initialBalance = 0
                  , name = "Cash"
                  , icon = ""
                  , transactions = []
                  }
                ]
   } |> updateChoosers, Effects.task (Task.succeed Load))

view address model =
  Ui.App.view (forwardTo address App) model.app
    [ dashboard address model
    , form address model ]

dashboard address model =
  div [] [text (toString (balance model.accounts))]

form address model =
  let
    numberPadView = { bottomLeft = div [] [Ui.icon "close" False []]
                    , bottomRight = div [onClick address Save] [Ui.icon "checkmark" False []]
                    }
  in
    div []
      [ Ui.panel []
        [ Ui.Container.view { align = "stretch"
                          , direction = "column"
                          , compact = False
                          } []
          [ Ui.inputGroup "Date" (Ui.DatePicker.view (forwardTo address DatePicker) model.datePicker)
          , Ui.inputGroup "Account" (Ui.Chooser.view (forwardTo address AccountChooser) model.accountChooser)
          , Ui.inputGroup "Category" (Ui.Chooser.view (forwardTo address CategoryChooser) model.categoryChooser)
          , Ui.NumberPad.view
              (forwardTo address NumberPad)
              numberPadView
              model.numberPad
          ]
        ]
      ]

update action model =
  case action of
    App act ->
      ({ model | app = Ui.App.update act model.app }, Effects.none)
    CategoryChooser act ->
      ({ model | categoryChooser = Ui.Chooser.update act model.categoryChooser }, Effects.none)
    AccountChooser act ->
      ({ model | accountChooser = Ui.Chooser.update act model.accountChooser }, Effects.none)
    DatePicker act ->
      ({ model | datePicker = Ui.DatePicker.update act model.datePicker }, Effects.none)
    NumberPad act ->
      ({ model | numberPad = Ui.NumberPad.update act model.numberPad }, Effects.none)
    Save ->
      let
        account' =
          case Ui.Chooser.getFirstSelected model.accountChooser of
            Just id ->
              List.Extra.find (\item -> item.id == id) model.accounts
            Nothing -> Nothing

        category' =
          case Ui.Chooser.getFirstSelected model.categoryChooser of
            Just id ->
              List.Extra.find (\item -> item.id == id) model.categories
            Nothing -> Nothing

        addTransaction account category item =
          let
            transaction = { id = Native.Uid.uid Nothing
                          , amount = model.numberPad.value
                          , date = model.datePicker.calendar.value
                          , category = category
                          , comment = ""
                          }
          in
            if account == item then
              { item | transactions = item.transactions ++ [transaction] }
            else
              item

        updatedAccount item =
          Maybe.map3 addTransaction account' category' (Just item)
            |> Maybe.withDefault item
      in
        ({ model | accounts = List.map updatedAccount model.accounts }, Effects.none)
    Load ->
      case (Storage.Local.getItem "moneytrack-data") of
        Ok data -> ({ model | data = data }, Effects.none)
        Err msg -> (model, Effects.none)

app =
  StartApp.start { init = init
                 , view = view
                 , update = update
                 , inputs = [] }

main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
