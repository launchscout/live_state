defmodule LiveState.Test.Thing do
  defstruct [:foo, :bar]
end

defmodule LiveState.Test.OtherThing do
  @derive [{Jason.Encoder, except: [:wuzzle]}]

  defstruct [:bing, :baz, :wuzzle]
end

defmodule LiveState.Test.OnlyThing do
  @derive [{Jason.Encoder, only: [:baz, :wuzzle]}]

  defstruct [:bing, :baz, :wuzzle]
end
