defmodule AttackSupervisor do
  require AttackWorker
  require Logger

  def start_link(node) do
    pid = spawn_link(fn -> start(node) end)
    {:ok, pid}
  end

  defp start(node) do
    Process.flag(:trap_exit, true)
    send({:attack_coordinator, node}, {:subscribe, Node.self, self()})
    Logger.info("Subscription sent to #{inspect node}")
    loop(false, 0, {:attack_coordinator, node})
  end


  defp start_workers(0, _, _) do
    :ok
  end

  defp start_workers(worker_count, target, request_count) when worker_count < 0 do
    Logger.info("#{worker_count}, #{target}, #{request_count}")
    {:error, :invalid_worker_count}
  end

  defp start_workers(worker_count, target, request_count) do
    AttackWorker.start_link(target, request_count)
    start_workers(worker_count - 1, target, request_count)
  end

  defp loop(true, 0, coordinator) do
    loop(false, 0, coordinator)
  end

  defp loop(processing, active_workers, coordinator) do
    receive do

      {:EXIT, _from, :normal} ->
        send(coordinator, {:attack_update, Node.self, self(), active_workers - 1})
        loop(processing, active_workers - 1, coordinator)

      {:EXIT, _from, reason} ->
        Logger.info("Worker terminated: #{reason}")
        send(coordinator, {:attack_update, Node.self, self(), active_workers - 1})
        loop(processing, active_workers - 1, coordinator)

      {:start, worker_count, target, request_count} ->
        Logger.info("Worker count: #{worker_count}")
        if processing do
          send(coordinator, {:error, :processing})
          loop(processing, active_workers, coordinator)
        else
          case start_workers(worker_count, target, request_count) do
            :ok ->
              send(coordinator, {:attack_update, Node.self, self(), worker_count})
              loop(true, worker_count, coordinator)

            {:error, reason} ->
              send(coordinator, {:error, reason})
              loop(processing, 0, coordinator)
          end
        end

      msg ->
        Logger.info("Unhandled message: #{msg}")
        loop(processing, active_workers, coordinator)
    end
  end


  def start(worker_count, target, request_count) do
    send(:attack_supervisor, {:start, self(), worker_count, target, request_count})
    receive do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
