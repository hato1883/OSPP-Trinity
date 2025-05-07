defmodule AttackWorker do
  require Logger
  require Req

  def start_link(target, request_count) do
    spawn_link(fn -> loop(target, request_count) end)
  end

  defp loop(_, 0) do
    :ok
  end

  defp loop(target, request_count) do
    Req.get(target)
    Logger.info("#{inspect(self())} - Request complete")
    Process.sleep(5000)
    loop(target, request_count - 1)
  end
end
