#parameters
ip = "192.168.3.2"
port = 8080
connections = 2

defmodule Volumetric do
  require Logger
  def send_request(target, port) do
    case :gen_tcp.connect(String.to_charlist(target), port, [:binary, packet: :raw, active: false]) do
      {:ok, socket} ->
        :gen_tcp.send(socket, "GET / HTTP/1.1\r\n")
        :gen_tcp.send(socket, "Host: #{target}\r\n")
        :gen_tcp.send(socket, "\r\n")
        :gen_tcp.close(socket)

        :ok
      {:error, reason} ->
        Logger.info("#{inspect(self())} - #{reason}")
    end


  end
end
Volumetric.start(ip, port, connections)
# Volumetric.start("127.0.0.1", 8080, 2)

:timer.sleep(:infinity)
