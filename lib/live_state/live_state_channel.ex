defmodule LiveState.LiveStateChannel do
  import Phoenix.Socket

  @callback init(socket :: Socket.t()) :: {:ok, state :: term()}
  @callback handle_event(event_name :: binary(), payload :: term(), state :: term()) ::
              {:reply, result :: term, new_state :: any()} | {:no_reply, new_state :: term}
  @callback state_key() :: atom()

  defmacro __using__(web_module: web_module) do
    quote do

      use unquote(web_module), :channel

      @behaviour unquote(__MODULE__)

      def join(_channel, _payload, socket) do
        IO.inspect(socket)
        send(self(), :after_join)
        {:ok, socket}
      end

      def handle_info(:after_join, socket) do
        {:ok, state} = init(socket)
        push(socket, "state:change", state)
        {:noreply, socket |> assign(state_key(), state)}
      end

      def handle_in("lvs_evt:" <> event_name, payload, %{assigns: assigns} = socket) do
        case handle_event(event_name, payload, Map.get(assigns, state_key())) do
          {:noreply, new_state} ->
            push(socket, "state:change", new_state)
            {:noreply, socket |> assign(state_key(), new_state)}
        end
      end
    end
  end
end
