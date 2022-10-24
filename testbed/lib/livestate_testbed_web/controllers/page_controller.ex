defmodule LivestateTestbedWeb.PageController do
  use LivestateTestbedWeb, :controller
  alias LivestateTestbedWeb.Endpoint

  def index(conn, _params) do
    url =
      "#{String.replace(Endpoint.url(), "http:", "ws:")}/socket"
      |> IO.inspect(label: "building livestate url")

    conn
    |> assign(:url, url)
    |> render("index.html")
  end
end
