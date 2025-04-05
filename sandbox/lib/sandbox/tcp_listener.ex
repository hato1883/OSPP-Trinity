defmodule Sandbox.TcpListener do
  require Logger

  def start_link(port) do
    pid = Process.spawn(fn -> start(port) end, [])
    {:ok, pid}
  end

  def start(port) do
    Logger.info("[TcpListener] started on port #{port}")
    {:ok, socket} = :gen_tcp.listen(port, active: false, reuseaddr: true)

    loop(socket)
  end

  defp loop(socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    Logger.info("[TcpListener] accepted connection")

    send(:tcp_load_balancer, {:handle_request, connection})
    loop(socket)
  end
end
