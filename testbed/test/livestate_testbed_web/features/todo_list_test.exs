defmodule LivestateTestbedWeb.Features.TodoListTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  import Wallaby.Query

  feature "todo list", %{session: session} do
    session
    |> visit("/")
    |> assert_text("todo list")
    |> within_shadow_dom("todo-form", fn shadow_dom ->
      shadow_dom
      |> fill_in(css("input[name='todo']"), with: "Do a thing")
      |> click(css("button"))
    end)
    |> within_shadow_dom("todo-list", fn shadow_dom ->
      shadow_dom
      |> assert_has(css("li", text: "Do a thing"))
    end)
  end

  feature "react todo list", %{session: session} do
    session
    |> visit("/react")
    |> fill_in(css("input[name='todo']"), with: "Do a thing")
    |> click(css("button"))
    |> assert_has(css("li", text: "Do a thing"))
  end
end
