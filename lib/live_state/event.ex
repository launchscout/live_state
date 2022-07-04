defmodule LiveState.Event do
  @moduledoc """
  Represents a CustomEvent to be returned from a reply and dispatched on the client.
  """
  defstruct name: "", detail: %{}
end
