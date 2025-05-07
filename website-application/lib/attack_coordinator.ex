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
    loop([])
  end

  defp loop(subscribed_attackers) do
    receive do
      {:subscribe, node, pid} ->
        Logger.info("Attacker subscribed: #{inspect node}, #{inspect pid}")
        HelloWeb.Endpoint.broadcast("attacker", "subscribed", %{node: node, pid: pid})
        loop([{node, pid} | subscribed_attackers])

      {:attack_update, node, pid, active_workers} ->
        Logger.info("Update received from #{inspect node} with #{active_workers} active workers")
        HelloWeb.Endpoint.broadcast("attacker", "active-update", %{node: node, pid: pid, active: active_workers})

      {:start_attack, workers, target, requests} ->
        start_attack(subscribed_attackers, workers, target, requests)

      msg ->
        Logger.info("Unhandled message received: #{inspect msg}")
    end

    loop(subscribed_attackers)
  end

  defp start_attack([], _workers, _target, _requests) do
    :ok
  end

  defp start_attack([{node, pid} | subscribed_attackers], workers, target, requests) do
    send({node, pid}, {:start, workers, target, requests})
    start_attack(subscribed_attackers, workers, target, requests)
  end
end
