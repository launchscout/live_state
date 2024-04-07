defmodule LiveState.MessageBuilder do
  
  alias LiveState.Encoder
  
  def update_state_message(old_state, new_state, version, opts \\ []) do
    old_state_encoded = Encoder.encode(old_state, opts)
    new_state_encoded = Encoder.encode(new_state, opts)
    {"state:patch", %{
      patch: JSONDiff.diff(old_state_encoded, new_state_encoded),
      version: version
    }}
  end

  def new_state_message(new_state, version, opts \\ []) do
    {"state:change", %{state: Encoder.encode(new_state, opts), version: version}}
  end
end
