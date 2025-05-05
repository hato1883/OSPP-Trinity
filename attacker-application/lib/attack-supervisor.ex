defmodule AttackSupervisor do
  require AttackWorker
  require Logger

  def start_link do
    pid = spawn_link(fn -> start() end)
    {:ok, pid}
  end

  defp start() do
    Process.register(self(), :attack_supervisor)
    Process.flag(:trap_exit, true)
    loop(false, 0)
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

  defp loop(true, 0) do
    loop(false, 0)
  end

  defp loop(processing, active_workers) do
    receive do

      {:EXIT, _from, :normal} ->
        loop(processing, active_workers - 1)

      {:EXIT, _from, reason} ->
        Logger.info("Worker terminated: #{reason}")
        loop(processing, active_workers - 1)

      {:start, from, worker_count, target, request_count} ->
        Logger.info("Worker count: #{worker_count}")
        if processing do
          send(from, {:error, :processing})
          loop(processing, active_workers)
        else
          case start_workers(worker_count, target, request_count) do
            :ok ->
              send(from, :ok)
              loop(true, worker_count)

            {:error, reason} ->
              send(from, {:error, reason})
              loop(processing, 0)
          end
        end

      {:worker_count, from} ->
        send(from, {:worker_count, active_workers})
        loop(processing, active_workers)

      msg ->
        Logger.info("Unhandled message: #{msg}")
        loop(processing, active_workers)
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

  def active_workers() do
    send(:attack_supervisor, {:worker_count, self()})
    receive do
      {:worker_count, active_workers} ->
        active_workers
    end
  end
end
