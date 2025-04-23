defmodule HelloWeb.UpdateListener do
  require Logger

  def child_spec(_args) do
    %{
      id: HelloWeb.UpdateListener,
      start: {HelloWeb.UpdateListener, :start_link, []}
    }
  end

  def start_link() do
    pid = Process.spawn(fn -> loop() end, [])
    Logger.info("Update Listener started")
    Logger.info(Node.self())
    Process.register(pid, :server_listener)
    {:ok, pid}
  end

  def loop() do
    receive do
      {:server_update, msg} ->
        Logger.info("Update received")
        HelloWeb.Endpoint.broadcast("servers", "update", msg)
    end

    loop()
  end
end
