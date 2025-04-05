defmodule Sandbox.TcpLoadBalancer do
  require Logger

  def start_link(server_list) do
    pid = Process.spawn(fn -> start(server_list) end, [])
    {:ok, pid}
  end

  def start(server_list) do
    Logger.info("[TcpLoadBalancer] started")
    Process.register(self(), :tcp_load_balancer)
    loop(server_list, 0)
  end

  def loop(server_list, next_index) do
    receive do
      {:handle_request, sender} ->
        Logger.info("[TcpLoadBalancer] handling request")
        recipent = Enum.at(server_list, next_index, nil)

        handle(recipent, sender)

        loop(server_list, rem(next_index + 1, length(server_list)))
    end
  end

  def handle({recipent_ip, recipent_port}, sender) do

    case :gen_tcp.connect(recipent_ip, recipent_port, active: false) do
      {:ok, socket} ->
        send(:tcp_supervisor, {:forward_request, sender, socket})
        Logger.info("[TcpLoadBalancer] request forwarded")

      {:error, reason} ->
        Logger.info("[TcpLoadBalancer] failed to connect to server, #{reason}")
    end
  end
end
