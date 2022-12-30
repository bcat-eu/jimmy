defmodule JimmyWeb.PageController do
  use JimmyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
