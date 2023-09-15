defmodule Mix.Tasks.LiveState.Gen.Element do
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
    [channel_name, tag_name] = validate_args!(args)

    binding = [
      channel_name: channel_name |> Phoenix.Naming.underscore(),
      tag_name: tag_name,
      element_class: element_class(tag_name)
    ]

    Mix.shell().cmd("npm install --prefix assets lit phx-live-state")

    element_contents =
      EEx.eval_file(Path.join(__DIR__, "../../../templates/custom-element.ts"), binding)

    File.write!("assets/js/#{tag_name}.ts", element_contents)
  end

  @spec raise_with_help() :: no_return()
  defp raise_with_help do
    Mix.raise("""
    mix live_state.gen.channel expects the channel name and tag name

        mix live_state.gen.element ContactForm contact-form

    """)
  end

  defp validate_args!(args) do
    unless length(args) == 2 and args |> Enum.at(1) |> valid_tag_name?() do
      raise_with_help()
    end

    args
  end

  defp element_class(tag_name),
    do: tag_name |> String.split("-") |> Enum.concat(["element"]) |> Enum.map(&String.capitalize/1) |> Enum.join("")

  defp valid_tag_name?(name) do
    name =~ ~r/^[a-z]*\-/
  end
end
