defmodule NodeMonitor do
  require Logger

  def child_spec(_args) do
    %{
      id: NodeMonitor,
      start: {NodeMonitor, :start_link, []}
    }
  end

  def start_link() do
    pid = Process.spawn(fn -> start() end, [])
    Logger.info("Node monitor started")
    Process.register(pid, :node_monitor)
    {:ok, pid}
  end

  def start() do
    :net_kernel.monitor_nodes(true)
    loop()
  end

  def loop() do
    receive do
      {:nodeup, node} ->
        Logger.info("Node up")
        Logger.info(inspect(node))

        loop()

      {:nodedown, node} ->
        Logger.info("Node down")
        Logger.info(inspect(node))

        send(:attack_coordinator, {:node_down, node})
        loop()

      msg ->
        Logger.info("Unknown message")
        Logger.info(msg)
        loop()
    end
  end
end
