defmodule HelloWeb.AttackController do
  use HelloWeb, :controller
  require Logger

  def start(conn, %{"workers" => workers, "requests" => requests, "node" => node})
  when
    workers > 0 and
    requests > 0
  do
    Logger.info("Start: #{workers} workers, #{requests} requests on node #{node}")

    send({:attack_supervisor, node}, {:start, workers, "http://localhost", requests})

    receive do
      :ok ->
        json(conn, %{start: :ok})

      :error ->
        json(conn, %{start: :error})

      after
        500 ->
          json(conn, %{start: :timeout})

    end
  end

  def start(conn, %{"workers" => workers, "requests" => requests})
  when
    workers <= 0 or
    requests <= 0
  do
    Logger.info("Start: #{workers} workers, #{requests} requests")

    json(conn, %{start: :error, reason: "Workers and requests must be positive non-zero integers"})
  end

  def start(conn, params) do
    Logger.info("Start: #{inspect params}")

    json(conn, %{start: :error, reason: "Required fields missing"})
  end
end
