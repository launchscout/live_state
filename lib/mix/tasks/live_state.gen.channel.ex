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
    File.write!(Path.join(web_prefix, "channels/#{binding[:path]}_channel.ex"), channel_contents)

    Mix.shell().info("""

        Add the channel to your socket handler, for example:

        channel "#{binding[:singular]}", #{binding[:module]}Channel
    """)
  end

  @spec raise_with_help() :: no_return()
  defp raise_with_help do
    Mix.raise("""
    mix phx.gen.channel expects just the module name, following capitalization:

        mix phx.gen.channel Room

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

  defp paths do
    [".", :phoenix]
  end
end
