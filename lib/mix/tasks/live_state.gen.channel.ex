defmodule Mix.Tasks.LiveState.Gen.Channel do
  @shortdoc "Generates a Phoenix channel"

  @moduledoc """
  Generates a Livestate channel.

      $ mix live_state.gen.channel Todo

  Accepts the module name for the channel

  The generated files will contain:

  For a regular application:

    * a channel in `lib/my_app_web/channels`
    * a channel test in `test/my_app_web/channels`
  """
  use Mix.Task
  alias Mix.Tasks.Phx.Gen

  @doc false
  def run(args) do
    [channel_name] = validate_args!(args)
    context_app = Mix.Phoenix.context_app()
    web_prefix = Mix.Phoenix.web_path(context_app)
    binding = Mix.Phoenix.inflect(channel_name)
    binding = Keyword.put(binding, :module, "#{binding[:web_module]}.#{binding[:scoped]}")

    Mix.Phoenix.check_module_name_availability!(binding[:module] <> "Channel")

    channel_contents = EEx.eval_file(Path.join(__DIR__, "../../../templates/channel.ex"), binding)
    File.mkdir_p!(Path.join(web_prefix, "channels"))
    File.write!(Path.join(web_prefix, "channels/#{binding[:path]}_channel.ex"), channel_contents)

    live_state_socket_path = Mix.Phoenix.web_path(context_app, "channels/live_state_socket.ex")

    if File.exists?(live_state_socket_path) do
      Mix.shell().info("""

      Add the channel to your `#{live_state_socket_path}` handler, for example:

          channel "#{binding[:singular]}:lobby", #{binding[:module]}Channel
      """)
    else
      Mix.shell().info("""

      The default socket handler - #{binding[:web_module]}.LiveStateSocket - was not found.
      """)

      if Mix.shell().yes?("Do you want to create it?") do
        Gen.Socket.run(~w(LiveState --from-channel #{channel_name}))
      else
        Mix.shell().info("""

        To create it, please run the mix task:

            mix phx.gen.socket LiveState

        Then add the channel to the newly created file, at `#{live_state_socket_path}`:

            channel "#{binding[:singular]}:lobby", #{binding[:module]}Channel
        """)
      end
    end

  end

  @spec raise_with_help() :: no_return()
  defp raise_with_help do
    Mix.raise("""
    mix live_state.gen.channel expects just the module name, following capitalization:

        mix live_state.gen.channel Todo

    """)
  end

  defp validate_args!(args) do
    unless length(args) == 1 and args |> hd() |> valid_name?() do
      raise_with_help()
    end

    args
  end

  defp valid_name?(name) do
    name =~ ~r/^[A-Z]\w*(\.[A-Z]\w*)*$/
  end

end
