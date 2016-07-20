effect module NetworkConnection
    where { subscription = MySub }
    exposing
        ( Connection(..)
        , isConnected
        , isDisconnected
        , connection
        , connectionChanges
        )

{-| This package helps you keep track of whether the user's browser is connected
to the internet. It will allow you to manage activity that should only be
performed when a connection is available and resume and resynchronize once the
connection resumes.

# Network connection
@docs Connection, connection, isConnected, isDisconnected

# Changes
@docs connectionChanges
-}

import Process
import Platform exposing (Router)
import Task exposing (Task)
import Native.NetworkConnection


{-| Value describing whether the browser is connected to the internet.
-}
type Connection
    = Online
    | Offline


connectedToConnection : Bool -> Connection
connectedToConnection isConnected =
    if isConnected then
        Online
    else
        Offline


{-| Get whether the internet is available.
-}
isConnected : Task x Bool
isConnected =
    Native.NetworkConnection.isConnected


{-| Get whether the internet is unavailable.
-}
isDisconnected : Task x Bool
isDisconnected =
    Task.map not isConnected


{-| Get the current network connection status.
-}
connection : Task x Connection
connection =
    Task.map connectedToConnection isConnected


{-| Subscribe to connection changes.
-}
connectionChanges : (Connection -> msg) -> Sub msg
connectionChanges tagger =
    subscription (Tagger tagger)


onConnectionChange : (Bool -> Task Never ()) -> Task x Never
onConnectionChange =
    Native.NetworkConnection.onConnectionChange


type MySub msg
    = Tagger (Connection -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap func (Tagger tagger) =
    Tagger (tagger >> func)


type alias State msg =
    { subs : List (MySub msg)
    , processId : Maybe Process.Id
    }


init : Task Never (State msg)
init =
    Task.succeed <| State [] Nothing


onEffects : Router msg Bool -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs state =
    case ( newSubs, state.processId ) of
        ( [], Just processId ) ->
            Process.kill processId
                |> Task.map (\_ -> State [] Nothing)

        ( _ :: _, Nothing ) ->
            Process.spawn (onConnectionChange (Platform.sendToSelf router))
                |> Task.map (Just >> State newSubs)

        ( _, _ ) ->
            Task.succeed <| { state | subs = newSubs }


onSelfMsg : Router msg Bool -> Bool -> State msg -> Task Never (State msg)
onSelfMsg router isConnected state =
    state.subs
        |> List.map (\(Tagger tagger) -> Platform.sendToApp router (tagger (connectedToConnection isConnected)))
        |> Task.sequence
        |> Task.map (\_ -> state)
