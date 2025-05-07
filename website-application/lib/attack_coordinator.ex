defmodule AttackCoordinator do
  require Logger

  def child_spec([]) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def start_link do
    pid = spawn_link(fn -> start() end)
    {:ok, pid}
  end

  defp start() do
    Process.register(self(), :attack_coordinator)
    Logger.info("Attack coordinator started")
    loop(%{})
  end

  defp loop(subscribed_attackers) do
    receive do
      {:subscribe, node} ->
        Logger.info("Attacker subscribed: #{inspect(node)}")

        updated_attackers = Map.put(subscribed_attackers, node, 0)
        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", updated_attackers)
        loop(updated_attackers)

      {:attack_update, node, active_workers} ->
        Logger.info("Update received from #{inspect(node)} with #{active_workers} active workers")

        updated_attackers = Map.put(subscribed_attackers, node, active_workers)

        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", updated_attackers)

        loop(updated_attackers)

      {:start_attack, workers, target, requests} ->
        Logger.info("Starting attack on: ~n#{inspect(subscribed_attackers)}")

        for {node, _workers} <- subscribed_attackers do
          start_attack(node, workers, target, requests)
        end

        loop(subscribed_attackers)

      {:node_down, disconnected_node} ->
        remaining_attackers =
          Map.filter(
            subscribed_attackers,
            fn {node, _} -> node != disconnected_node end
          )

        HelloWeb.Endpoint.broadcast("attacker", "attacker_list_update", remaining_attackers)

        loop(remaining_attackers)

      {:get_attackers, from} ->
        send(from, {:attacker_list, subscribed_attackers})
        loop(subscribed_attackers)

      msg ->
        Logger.info("Unhandled message received: #{inspect(msg)}")
        loop(subscribed_attackers)
    end
  end

  defp start_attack(node, workers, target, requests) do
    send({:attack_supervisor, node}, {:start, workers, target, requests})
    # start_attack(subscribed_attackers, workers, target, requests)
  end
end
