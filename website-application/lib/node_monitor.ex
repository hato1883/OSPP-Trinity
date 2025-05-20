defmodule NodeMonitor do
  require Logger

  # Module for monitoring node connections.

  # Child specification to simplify supervised starts
  def child_spec(_args) do
    %{
      id: NodeMonitor,
      start: {NodeMonitor, :start_link, []}
    }
  end

  # Spawns a node monitor process
  def start_link() do
    pid = Process.spawn(fn -> start() end, [])
    {:ok, pid}
  end

  # Setup function
  def start() do
    Logger.info("Node monitor started")
    Process.register(self(), :node_monitor)
    :net_kernel.monitor_nodes(true)
    loop()
  end

  # Main event loop
  def loop() do
    receive do
      # Log new node connection
      {:nodeup, node} ->
        Logger.info("Node up")
        Logger.info(inspect(node))

        loop()

      # Log node disconnection and notify the attack coordinator
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
