defmodule AttackWorker do
  require Logger

  # Worker module for attacks.

  # Spawns the worker process and links it to the calling process
  def start_link(target, request_count, method, attack_type) do
    spawn_link(fn -> loop(target, request_count, method, attack_type) end)
  end

  # Recursive stop condition, ends the loop when all requests have been sent
  defp loop(_, 0, _, _) do
    :ok
  end

  # Recursively performs a number of web requests
  defp loop(target, request_count, method, attack_type) do
    case attack_type do
      "volumetric" ->
        # Replace with actual volumetric attack
        do_volumetric(target, method)
        Process.sleep(:rand.uniform(5) * 1000)

        loop(target, request_count - 1, method, attack_type)

      "slowloris" ->
        # Replace with actual slowloris attack
        do_slowloris(target, method)
        Process.sleep(:rand.uniform(5) * 1000)

        loop(target, request_count - 1, method, attack_type)
    end
  end

  # Placeholder functions, either implement functionality in them or replace them

  defp do_volumetric(_target, "GET") do
    Logger.info("#{inspect(self())} - Volumetric GET complete")
  end

  defp do_volumetric(_target, "POST") do
    Logger.info("#{inspect(self())} - Volumetric POST complete")
  end

  defp do_slowloris(_target, "GET") do
    Logger.info("#{inspect(self())} - Slowloris GET complete")
  end

  defp do_slowloris(_target, "POST") do
    Logger.info("#{inspect(self())} - Slowloris POST complete")
  end
end
