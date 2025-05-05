# # Mix.install([:req, :floki])

# defmodule Master do
#   def start(x) do
#     master = spawn(fn -> master_loop() end)

#     for i <- 1..x do
#       spawn(Worker, :start, [master])
#     end
#   end

#   def master_loop do
#     receive do
#       # TODO: i dont think we necessarily need to send ok back to the master
#       {:ok, data} ->
#         IO.puts("Received data: #{inspect(data)}")
#         master_loop()
#       {:error, reason} ->
#         IO.puts("Error: #{inspect(reason)}")
#         master_loop()
#     end
#   end

# end
