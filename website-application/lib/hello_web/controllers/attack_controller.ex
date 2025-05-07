defmodule HelloWeb.AttackController do
  use HelloWeb, :controller
  require Logger

  def start(conn, %{"target" => target, "workers" => workers, "requests" => requests})
      when workers > 0 and
             requests > 0 do
    Logger.info("Start: #{workers} workers, #{requests}")

    send(:attack_coordinator, {:start_attack, workers, target, requests})

    json(conn, %{status: :ok})
  end

  def start(conn, %{"workers" => workers, "requests" => requests})
      when workers <= 0 or
             requests <= 0 do
    Logger.info("Start: #{workers} workers, #{requests} requests")

    json(conn, %{start: :error, reason: "Workers and requests must be positive non-zero integers"})
  end

  def start(conn, params) do
    Logger.info("Start: #{inspect(params)}")

    json(conn, %{start: :error, reason: "Required fields missing"})
  end
end
