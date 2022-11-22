defmodule LivestateTestbedWeb.PageController do
  use LivestateTestbedWeb, :controller
  alias LivestateTestbedWeb.Endpoint

  def index(conn, _params) do
    conn
    |> assign(:url, url())
    |> render("index.html")
  end

  def react(conn, _params) do
    conn |> render("react.html")
  end

  def join_params(conn, _params) do
    conn |> assign(:url, url()) |> render("join_params.html")
  end

  defp url() do
    "#{String.replace(Endpoint.url(), "http:", "ws:")}/socket"
    |> IO.inspect(label: "building livestate url")
  end
end
