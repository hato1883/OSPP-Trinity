defmodule Sandbox.TcpWorker do
  require Logger

  def start(supervisor) do
    send(supervisor, :ready)
    loop(supervisor)
  end

  def loop(supervisor) do
    receive do
      {:connect, sender, recipent} ->
        forward(sender, recipent)
        send(supervisor, {:done, self()})

      :stop ->
        exit(:shutdown)
    end

    loop(supervisor)
  end

  defp forward(sender, recipent) do
    Logger.info("[TcpWorker] starting receive")

    case :gen_tcp.recv(sender, 0) do
      {:ok, data} ->
        case :gen_tcp.send(recipent, data) do
          :ok ->
            forward(sender, recipent)

          {:error, :closed} ->
            Logger.info("Recipent closed")
            :gen_tcp.close(sender)
            send(:tcp_supervisor, {:done, self()})

          {:error, reason} ->
            Logger.info("Recipent error: #{reason}")
            :gen_tcp.close(sender)
            send(:tcp_supervisor, {:done, self()})
        end

      {:error, :closed} ->
        Logger.info("Sender closed")
        :gen_tcp.close(recipent)
        send(:tcp_supervisor, {:done, self()})

      {:error, reason} ->
        Logger.info("Sender error: #{reason}")
        :gen_tcp.close(recipent)
        send(:tcp_supervisor, {:done, self()})
    end
  end
end
