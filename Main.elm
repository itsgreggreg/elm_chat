port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Dialog

-- model


type alias Message =
    { username : String
    , message : String
    , system : Bool
    }


type alias Model =
    { username : String
    , message : String
    , messages : List Message
    , showDialog : Bool
    }


initModel : Model
initModel =
    { username = ""
    , message = ""
    , messages = []
    , showDialog = True
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- update


type Msg
    = NameInput String
    | MessageInput String
    | SaveMessage
    | MessageSaved String
    | MessageAdded Message
    | Acknowledge


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput username ->
            ( { model | username = username }, Cmd.none )

        MessageInput message ->
            ( { model | message = message }, Cmd.none )

        SaveMessage ->
            ( model, addMessage (Message model.username model.message False) )

        MessageSaved key ->
            ( { model | message = "" }, Cmd.none )

        MessageAdded message ->
            let
                newMessages =
                    message :: model.messages
            in
                ( { model | messages = newMessages }, Cmd.none )

        Acknowledge ->
            let
              username_ = model.username |> String.trim
            in
              if String.length username_ < 2 then
                ( { model | username = username_} , Cmd.none )
              else
                ( { model | username = username_, showDialog = False }
                , addMessage (Message "" (username_ ++ " has joined the chat!") True))



-- view


viewMessage : Message -> Html Msg
viewMessage message =
    let
      nick = if (message.system) then
          ""
        else
          message.username ++ ": "
    in
      div [classList [("message", True),("system", (message.system == True))]]
          [ span [class "username"] [ text nick]
          , span [] [ text message.message]
          ]


viewMessages : List Message -> Html Msg
viewMessages messages =
    messages
        -- |> List.sortBy .id
        |> List.map viewMessage
        |> div [class "messages"]


viewMessageForm : Model -> Html Msg
viewMessageForm model =
    Html.form [ class "message-form", onSubmit SaveMessage ]
        [ span [] [ text (model.username ++ ": ")]
        , input [ type_ "text", onInput MessageInput, value model.message ] []
        -- , text <| Maybe.withDefault "" model.error
        , button [ type_ "submit" ] [ text "Send" ]
        ]

viewDialog : Model -> Html Msg
viewDialog model =
  Dialog.view
    (if model.showDialog then
        Just (dialogConfig model)
     else
        Nothing
    )

dialogConfig : Model -> Dialog.Config Msg
dialogConfig model =
    { closeMessage = Just Acknowledge
    , containerClass = Just "modal-container"
    , header = Just (h3 [] [ text "Please choose a nickname." ])
    , body = Just (text ("At least 2 non whitespace characters."))
    , footer =
        Just
            ( div []
              [Html.form [onSubmit Acknowledge]
                [ input [type_ "text", onInput NameInput, value model.username, autofocus True] []
                , button
                    [ class "btn btn-success"]
                    [ text "OK" ]
                ]
              ]
            )
    }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Elm Chat" ]
        , viewMessageForm model
        , viewMessages model.messages
        , viewDialog model
        ]


-- subscription


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Sub.none
    Sub.batch
        [ messageSaved MessageSaved
        , newMessage MessageAdded
        ]


port addMessage : Message -> Cmd msg


port messageSaved : (String -> msg) -> Sub msg


port newMessage : (Message -> msg) -> Sub msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
