defmodule HelloWeb.AdminController do
  use HelloWeb, :controller

  def index(conn, _params) do

    conn
    |> put_flash(:info, "You are connected!")
    |> render( :index)
  end
end
