port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


-- model


type alias Message =
    { username : String
    , message : String
    }


type alias Model =
    { username : String
    , message : String
    , messages : List Message
    }


initModel : Model
initModel =
    { username = ""
    , message = ""
    , messages = []
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NameInput username ->
            ( { model | username = username }, Cmd.none )

        MessageInput message ->
            ( { model | message = message }, Cmd.none )

        SaveMessage ->
            ( model, addMessage (Message model.username model.message) )

        MessageSaved key ->
            ( { model | message = "" }, Cmd.none )

        MessageAdded message ->
            let
                newMessages =
                    message :: model.messages
            in
                ( { model | messages = newMessages }, Cmd.none )



-- view


viewMessage : Message -> Html Msg
viewMessage message =
    li []
        [ text (message.username ++ ": ")
        , text message.message
        ]


viewMessages : List Message -> Html Msg
viewMessages messages =
    messages
        -- |> List.sortBy .id
        |> List.map viewMessage
        |> ul []


viewMessageForm : Model -> Html Msg
viewMessageForm model =
    Html.form [ onSubmit SaveMessage ]
        [ input [ type_ "text", onInput NameInput, value model.username ] []
        , input [ type_ "text", onInput MessageInput, value model.message ] []
        -- , text <| Maybe.withDefault "" model.error
        , button [ type_ "submit" ] [ text "Save" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Elm Chat!" ]
        , viewMessageForm model
        , viewMessages model.messages
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
