defmodule LiveState.Test.Endpoint do
  use Phoenix.Endpoint, otp_app: :live_state

  socket "/socket", LiveState.Test.UserSocket

  defoverridable url: 0, script_name: 0, config: 1, config: 2, static_path: 1
  def url(), do: "http://localhost:4000"
  def script_name(), do: []
  def static_path(path), do: "/static" <> path
  def config(:live_view), do: [signing_salt: "112345678212345678312345678412"]
  def config(:secret_key_base), do: String.duplicate("57689", 50)
  def config(:cache_static_manifest_latest), do: Process.get(:cache_static_manifest_latest)
  def config(:otp_app), do: :live_state
  def config(:pubsub_server), do: LiveState.Test.PubSub
  def config(:render_errors), do: [view: __MODULE__]
  def config(:static_url), do: [path: "/static"]
  def config(which), do: super(which)
  def config(which, default), do: super(which, default)
end
