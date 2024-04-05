defmodule LiveState.Test.Thing do
  defstruct [:foo, :bar]
end

defimpl LiveState.Encoder, for: LiveState.Test.Thing do
  def encode(%LiveState.Test.Thing{foo: foo}) do
    %{foo: foo}
  end
end

defmodule LiveState.Test.OtherThing do
  @derive [{LiveState.Encoder, except: [:wuzzle]}]

  defstruct [:bing, :baz, :wuzzle]
end

defmodule LiveState.Test.OnlyThing do
  @derive [{LiveState.Encoder, only: [:baz, :wuzzle]}]

  defstruct [:bing, :baz, :wuzzle]
end
