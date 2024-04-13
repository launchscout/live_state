defprotocol LiveState.Encoder do
  @moduledoc """
  Allows customization of the representation of a given type
  as the state in a `LiveState.Channel`. It is called *before* serialization
  and json diffing.
  """
  @fallback_to_any true
  def encode(data, opts \\ [])
end

defimpl LiveState.Encoder, for: Any do
  alias LiveState.Encoder

  def encode(data, opts) do
    case data do
      %{__meta__: _meta} = data when is_struct(data) -> Map.from_struct(data) |> Encoder.encode(opts)
      data -> data
    end
  end

  defmacro __deriving__(module, _struct, options) do
    quote do
      defimpl LiveState.Encoder, for: unquote(module) do
        case unquote(options) do
          [] ->
            def encode(data, opts \\ []) do
              Map.from_struct(data) |> Encoder.encode(opts)
            end

          [{:except, except}] ->
            def encode(data, opts \\ []) do
              except = Keyword.get(unquote(options), :except)
              Map.from_struct(data) |> Map.drop(except) |> Encoder.encode(opts)
            end

          [{:only, only}] ->
            def encode(data, opts \\ []) do
              only = Keyword.get(unquote(options), :only)
              Map.from_struct(data) |> Map.take(only) |> Encoder.encode(opts)
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

  def encode(map, opts \\ []) do
    ignore_keys = Keyword.get(opts, :ignore_keys, [])
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      if !(k in ignore_keys) do
        Map.put(acc, k, Encoder.encode(v, opts))
      else
        acc
      end
    end)
  end
end

defimpl LiveState.Encoder, for: DateTime do
  def encode(date, _opts), do: DateTime.to_iso8601(date)
end

defimpl LiveState.Encoder, for: Date do
  def encode(date, _opts), do: Date.to_iso8601(date)
end

defimpl LiveState.Encoder, for: List do
  alias LiveState.Encoder

  def encode(list, opts \\ []) do
    Enum.map(list, &Encoder.encode(&1, opts))
  end
end
