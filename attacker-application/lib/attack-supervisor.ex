defmodule AttackSupervisor do
  require AttackWorker
  require Logger

  # Supervisor for attack workers. Subscribes to an attack coordinator and awaits messages to start attacks. Monitors the active workers and supplies the coordinator with the current status.

  # Spawns the supervisor process with the node the attack coordinator runs on.
  def start_link(node) do
    pid = spawn_link(fn -> start(node) end)
    {:ok, pid}
  end

  # Setup function for the supervisor.
  defp start(node) do
    Process.flag(:trap_exit, true)
    Process.register(self(), :attack_supervisor)
    send({:attack_coordinator, node}, {:subscribe, Node.self()})
    Logger.info("Subscription sent to #{inspect(node)}")
    loop(false, 0, {:attack_coordinator, node})
  end

  # Recursive stop condition for starting workers.
  defp start_workers(0, _, _, _, _) do
    :ok
  end

  # Catch invalid worker count.
  defp start_workers(worker_count, _target, _request_count, _method, _attack_type)
       when worker_count < 0 do
    {:error, :invalid_worker_count}
  end

  # start_workers could do with more error checking

  # Recursively start and link attack workers with the given parameters
  defp start_workers(worker_count, target, request_count, method, attack_type) do
    AttackWorker.start_link(target, request_count, method, attack_type)
    start_workers(worker_count - 1, target, request_count, method, attack_type)
  end

  # Set the processing flag to false when all the workers are done to signal that the attack is complete
  defp loop(true, 0, coordinator) do
    loop(false, 0, coordinator)
  end

  # Main event loop
  defp loop(processing, active_workers, coordinator) do
    receive do
      # Handle normal exits from workers
      {:EXIT, _from, :normal} ->
        send(coordinator, {:attack_update, Node.self(), active_workers - 1})
        loop(processing, active_workers - 1, coordinator)

      # Handle worker errors
      {:EXIT, _from, reason} ->
        Logger.info("Worker terminated: #{reason}")
        send(coordinator, {:attack_update, Node.self(), active_workers - 1})
        loop(processing, active_workers - 1, coordinator)

      # Handle message to start attack
      {:start, workers, target, requests, method, attack_type} ->
        Logger.info("#{inspect(self())} Worker count: #{workers}")

        # Avoid starting a new attack while in the middle of one
        if processing do
          send(coordinator, {:error, :processing})
          loop(processing, active_workers, coordinator)
        else
          case start_workers(workers, target, requests, method, attack_type) do
            :ok ->
              send(coordinator, {:attack_update, Node.self(), workers})
              loop(true, workers, coordinator)

            # Technically doesn't handle errors properly as some workers may have started when the error occcurs
            {:error, reason} ->
              send(coordinator, {:error, reason})
              loop(processing, 0, coordinator)
          end
        end

      msg ->
        Logger.info("Unhandled message: #{inspect(msg)}")
        loop(processing, active_workers, coordinator)
    end
  end
end
