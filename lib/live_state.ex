defmodule LiveState do
  @moduledoc """

  # LiveState

  LiveState is a library to manage application state for a non elixir hosted
  application. A LiveState application roughly follows the pattern of Event Driven Architecture. Rather than
  requests and reponses, in a LiveState application your client emits Events and receives changes to
  state (and possibly additional events). This allows your client code to concern itself only with
  how to render the appropriate state and dispatch the appropriate events.

  The application state must be serializable as JSON. Currently the entire state is returned on each event,
  but future versions will implement JSON patch to send efficient updates.

  ## Usage

  LiveState uses Phoenix Channels to implement communication from the client. To use it, you'll want to start
  with a channel that uses the `LiveState.Channel` behaviour.

  You'll also want to use a client library to connect to a LiveState application. Currently this
  exists for javascript in the [phx-live-state](https://github.com/gaslight/live-state)
  """
end
