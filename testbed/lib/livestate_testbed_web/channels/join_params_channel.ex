defmodule LivestateTestbedWeb.JoinParamsChannel do
  use LiveState.Channel, web_module: LivestateTestbedWeb

  def init(_channel, %{"api_key" => api_key}, _socket) do
    {:ok, %{result: api_key}}
  end

end
