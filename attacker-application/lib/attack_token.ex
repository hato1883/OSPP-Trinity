# # Mix.install([:req, :floki])

# # import GetRequestToken

defmodule GetRequestToken do
  def localhost_get() do
    IO.puts("Request loop started...")
    GetRequestToken.localhost_get_req()
  end

  def localhost_get_req() do
    first = Enum.random(0..255)
    second = Enum.random(0..255)
    third = Enum.random(0..255)
    fourth = Enum.random(0..255)
    Req.get("http://localhost:8080/?ip=#{first}.#{second}.#{third}.#{fourth}")
    # IO.puts("Request made!")
    # IO.puts("Waiting for 1 second(s)...")
    # :timer.sleep(1000)
    # IO.puts("Done!")
    GetRequestToken.localhost_get_req()
  end

  def requester_loop(iteration) when iteration < 250 do
    spawn(fn -> localhost_get() end)
    IO.puts("Requester made")
    requester_loop(iteration + 1)
  end

#   def requester_loop(_iteration), do: :ok

  def print_wait do
    IO.puts("Wait for 20 seconds!")
  end
end

# GetRequestToken.requester_loop(0)
# GetRequestToken.print_wait()
# Process.sleep(20000)
