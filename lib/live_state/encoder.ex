defprotocol LiveState.Encoder do
  @fallback_to_any true
  def encode(data)
end

defimpl LiveState.Encoder, for: Any do
  alias LiveState.Encoder

  def encode(data) do
    data
  end

  defmacro __deriving__(module, _struct, options) do
    quote do
      defimpl LiveState.Encoder, for: unquote(module) do
        case unquote(options) do
          [] ->
            def encode(data) do
              Map.from_struct(data) |> Encoder.encode()
            end

          [{:except, except}] ->
            def encode(data) do
              except = Keyword.get(unquote(options), :except)
              Map.from_struct(data) |> Map.drop(except) |> Encoder.encode()
            end

          [{:only, only}] ->
            def encode(data) do
              only = Keyword.get(unquote(options), :only)
              Map.from_struct(data) |> Map.take(only) |> Encoder.encode()
            end

          _ ->
            raise ArgumentError, "invalid options for deriving LiveState.Encoder"
        end
      end
    end
  end
end

defimpl LiveState.Encoder, for: Map do
  alias LiveState.Encoder

  def encode(map) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      Map.put(acc, k, Encoder.encode(v))
    end)
  end
end

defimpl LiveState.Encoder, for: List do
  alias LiveState.Encoder

  def encode(list) do
    Enum.map(list, &Encoder.encode/1)
  end
end
