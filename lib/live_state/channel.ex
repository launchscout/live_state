defmodule LiveState.Channel do
  @moduledoc """
  To build a LiveState application, you'll first want to add a channel that implements this
  behaviour.
  """
  import Phoenix.Socket

  alias LiveState.Event

  @doc """
  Returns the initial application state. Called just after connection
  """
  @callback init(socket :: Socket.t()) :: {:ok, state :: term()}

  @doc """
  Receives an event an payload from the client and current state. Returns the new state along with (optionally)
  a single or list of `LiveState.Event` to dispatch to client
  """
  @callback handle_event(event_name :: binary(), payload :: term(), state :: term()) ::
              {:reply, reply :: %LiveState.Event{} | list(%LiveState.Event{}), new_state :: any()}
              | {:no_reply, new_state :: term}

  @doc """
  The key on assigns to hold application state. Defaults to `state`.
  """
  @callback state_key() :: atom()

  @doc """
  Receives pubsub message and current state. Returns new state
  """
  @callback handle_message(message :: term(), state :: term()) :: {:ok, term()} | {:error, any()}

  defmacro __using__(web_module: web_module) do
    quote do
      use unquote(web_module), :channel

      @behaviour unquote(__MODULE__)

      def join(_channel, _payload, socket) do
        send(self(), :after_join)
        {:ok, socket}
      end

      def handle_info(:after_join, socket) do
        {:ok, state} = init(socket)
        push(socket, "state:change", state)
        {:noreply, socket |> assign(state_key(), state)}
      end

      def handle_info(message, %{assigns: assigns} = socket) do
        {:ok, new_state} = handle_message(message, Map.get(assigns, state_key()))
        update_state(socket, new_state)
      end

      def handle_in("lvs_evt:" <> event_name, payload, %{assigns: assigns} = socket) do
        case handle_event(event_name, payload, Map.get(assigns, state_key())) do
          {:noreply, new_state} ->
            update_state(socket, new_state)

          {:reply, event_or_events, new_state} ->
            push_events(socket, event_or_events)
            update_state(socket, new_state)
        end
      end

      def state_key, do: :state

      def handle_message(_message, state), do: {:ok, state}

      defp update_state(socket, new_state) do
        push(socket, "state:change", new_state)
        {:noreply, socket |> assign(state_key(), new_state)}
      end

      defp push_events(socket, events) when is_list(events) do
        events |> Enum.map(&push_event(socket, &1))
      end

      defp push_events(socket, event), do: push_event(socket, event)

      defp push_event(socket, %Event{name: name, detail: detail}) do
        push(socket, name, detail)
      end

      defoverridable state_key: 0, handle_message: 2, handle_in: 3, handle_info: 2, join: 3
    end
  end
end
