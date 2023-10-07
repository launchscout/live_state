defmodule LiveState.Test.BadInitChannel do
  @moduledoc false

  use LiveState.Channel, web_module: LiveState.Test.Web

  def init(_channel, _params, _socket) do
    {:error, "you stink"}
  end

end
