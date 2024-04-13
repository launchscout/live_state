defmodule LiveState.Test.Thing do
  @moduledoc false
  defstruct [:foo, :bar]
end

defimpl LiveState.Encoder, for: LiveState.Test.Thing do
  @moduledoc false
  def encode(%LiveState.Test.Thing{foo: foo}, []) do
    %{foo: foo}
  end
end

defmodule LiveState.Test.OtherThing do
  @moduledoc false
  @derive [{LiveState.Encoder, except: [:wuzzle, :__meta__]}]

  defstruct [:bing, :baz, :wuzzle, :__meta__]
end

defmodule LiveState.Test.OnlyThing do
  @moduledoc false
  @derive [{LiveState.Encoder, only: [:baz, :wuzzle]}]

  defstruct [:bing, :baz, :wuzzle]
end

defmodule LiveState.Test.FakeSchema do
  @moduledoc false
  use Ecto.Schema

  schema "fake_table" do
    field :foo, :string
    field :name, :string
    field :birth_date, :utc_datetime
    timestamps()
  end
end
