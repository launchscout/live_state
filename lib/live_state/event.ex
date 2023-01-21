defmodule LiveState.Event do
  defstruct name: "", detail: %{}

  @typedoc """
  Represents a CustomEvent to be returned from a reply and dispatched on the client.

  Fields:
  * name: becomes the name of the CustomEvent to be dispatched
  * detail: becomes the detail property (payload) of the CustomEvent. Not that because
  events will be serialized as JSON, everything here must implement `Jason.Encoder`
  """
  @type t :: %__MODULE__{name: String.t(), detail: map()}
end
