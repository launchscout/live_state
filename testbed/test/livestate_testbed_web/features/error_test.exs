defmodule LivestateTestbedWeb.Features.ErrorTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  feature "join params", %{session: session} do
    session
    |> visit("/errors")
    |> within_shadow_dom("connect-error", fn shadow_dom ->
      shadow_dom
      |> assert_has(css("div", text: "error"))
    end)
  end

end
