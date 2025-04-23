defmodule HelloWeb.ServerChannel do
  use Phoenix.Channel

  def join("servers", _message, socket) do
    {:ok, socket}
  end

  def handle_in(_, _, socket) do
    {:noreply, socket}
  end
end
