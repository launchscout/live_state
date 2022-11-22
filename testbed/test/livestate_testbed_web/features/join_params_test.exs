defmodule LivestateTestbedWeb.Features.JoinParamsTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  feature "join params", %{session: session} do
    session
    |> visit("/join_params")
    |> within_shadow_dom("join-params", fn shadow_dom ->
      shadow_dom
      |> assert_has(css("div", text: "foo"))
    end)
  end

end
