Mix.install([:finch, :floki])

defmodule TestFinch do
  def start do
    Finch.start_link(name: MyFinch)
  end

  def get_request(url) do
    Finch.build(:get, url)
    |> Finch.request(MyFinch)
  end

  def get_request_with_headers(url, headers) do
    Finch.build(:get, url, headers)
    |> Finch.request(MyFinch)
  end

  def requester_loop(iteration) when iteration < 1050 do
    spawn(fn -> localhost_get(iteration) end)
    IO.puts("Requester made")
    requester_loop(iteration + 1)
  end

  def requester_loop(_iteration), do: :ok

  def localhost_get(iteration) do
    IO.puts("Request loop started...")
    TestFinch.localhost_get_req(iteration)
  end

  def localhost_get_req(iteration) do
    # IO.puts("Request loop started...")
    first = Enum.random(0..255)
    second = Enum.random(0..255)
    third = Enum.random(0..255)
    fourth = Enum.random(0..255)
    case TestFinch.get_request("http://localhost:8080/?ip=#{first}.#{second}.#{third}.#{fourth}") do
      {:ok, _response} ->
        # IO.inspect(response.status, label: "Status")
        # IO.puts("Body:\n#{response.body}")
        # IO.puts("Looks good to me!")
        1+1

      {:error, reason} ->
        IO.inspect(reason, label: "Error")
    end
    TestFinch.localhost_get_req(iteration + 1)
  end

end

# 👇 Start the Finch pool
{:ok, _pid} = TestFinch.start()
TestFinch.requester_loop(0)
Process.sleep(20000)
# 👇 Make a GET request
# case TestFinch.get_request("https://wttr.in/?format=3") do
#   {:ok, response} ->
#     # IO.inspect(response.status, label: "Status")
#     IO.puts("Body:\n#{response.body}")
#     IO.puts("Looks good to me!")

#   {:error, reason} ->
#     IO.inspect(reason, label: "Error")
# end
