defmodule Sandbox.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      %{
        id: Sandbox.TcpSupervisor,
        start: {Sandbox.TcpSupervisor, :start_link, [1]}
        # Number of worker pairs for transferring data between the client and server. Each connection takes two workers for bidirectional communication.
      },
      %{
        id: Sandbox.TcpLoadBalancer,
        start: {Sandbox.TcpLoadBalancer, :start_link, [[{{127, 0, 0, 1}, 80}]]}
        # List of tuples for the servers connections should be forwarded to. Elements are on the form {ip, port} where ip is {x, x, x, x}.
      },
      %{
        id: Sandbox.TcpListener,
        start: {Sandbox.TcpListener, :start, [8083]}
        # The listening port for incoming connections.
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
