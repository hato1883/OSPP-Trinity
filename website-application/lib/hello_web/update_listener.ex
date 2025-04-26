defmodule HelloWeb.UpdateListener do
  require Logger

  def child_spec(_args) do
    %{
      id: HelloWeb.UpdateListener,
      start: {HelloWeb.UpdateListener, :start_link, []}
    }
  end

  def start_link() do
    pid = Process.spawn(fn -> loop(%{}) end, [])
    Logger.info("Update Listener started")
    Process.register(pid, :server_listener)
    {:ok, pid}
  end

  def loop(server_map) do
    receive do
      {:server_update, %{id: id, name: name, status: status}} ->
        Logger.info("Update received")

        new_server_map = Map.put(server_map, id, %{name: name, status: status})

        HelloWeb.Endpoint.broadcast("servers", "server-update", new_server_map)
        loop(new_server_map)

      _ ->
        loop(server_map)
    end
  end
end
