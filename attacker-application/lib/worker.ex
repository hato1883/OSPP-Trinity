Mix.install([:req, :floki])

defmodule Worker do
  def start(master) do
    spawn(fn -> worker_loop(master) end)
  end

  def worker_loop do
    # TODO: update so the ip changes for each request
    Req.get("http://localhost:8080/?ip=1")
    receive do
      # TODO: i dont think we necessarily need to send ok back to the master
      # since the master should not care about if its working, only if its not working
      {:ok, data} ->
        IO.puts("Received data: #{inspect(data)}")
        # Process the data here
        worker_loop(master)

      {:error, reason} ->
        IO.puts("Error: #{inspect(reason)}")
        send(master, :error, reason)
        worker_loop(master)
    end
  end
end
