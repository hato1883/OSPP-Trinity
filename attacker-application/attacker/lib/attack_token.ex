Mix.install([:req, :floki])

defmodule GetRequest do
  def hello do
    IO.puts("Hello, World!")
  end

  def weather do
    # {:ok, _} = Application.ensure_all_started(:req)
    response = Req.get!("https://wttr.in/?format=3")
    IO.puts(response.body)
  end

  def localhost_uptime do
    # {:ok, _} = Application.ensure_all_started(:req)
    {_ok, response} = Req.get("http://localhost:8080/dev/dashboard/home")

    divs = Floki.parse_document!(response.body) |> Floki.find("div.banner-card.mt-auto") |> Floki.text()
    lines = String.split(divs, "\n")
    uptime = Enum.at(lines, 31) |> String.trim()
    # IO.inspect(divs)
    # IO.inspect(lines)
    IO.puts(uptime)
  end
  def localhost_get(iteration) do
    IO.puts("Request loop started...")
    GetRequest.localhost_get_req(iteration)
  end

  def localhost_post do
    IO.puts("Request loop started...")
    {:ok, body} = File.read("./nuke.json")
    {:ok, data} = Jason.decode(body)
    GetRequest.localhost_post_req(data)
  end

  def localhost_get_req(iteration) do

    Req.get("http://192.168.47.237:8080/?ip=#{iteration}")
    # IO.puts("Request made!")
    # IO.puts("Waiting for 1 second(s)...")
    # :timer.sleep(1000)
    # IO.puts("Done!")
    GetRequest.localhost_get_req(iteration + 1)
  end

  def localhost_post_req(data) do
    Req.post("http://192.168.47.237:8080/?ip=abcd",
        json: data
        )
    # IO.puts("Done!")
    GetRequest.localhost_post_req(data)
  end

  def requester_loop(iteration) when iteration < 20 do
    spawn(fn -> localhost_get(iteration) end)
    IO.puts("Requester made")
    requester_loop(iteration + 1)
  end

  def requester_loop(_iteration), do: :ok

  def print_wait do
    IO.puts("Wait for 20 seconds!")
  end

  def testing do
    # {:ok, _} = Application.ensure_all_started(:req)
    response = Req.get!("https://www.google.com")
    IO.inspect(response.headers, label: "Headers")
    IO.puts("Waiting for 2 seconds...")
    :timer.sleep(2000)
    IO.puts("Done!")
    GetRequest.testing()
  end
end

#  GetRequest.hello()

# GetRequest.testing()
# GetRequest.weather()
# GetRequest.localhost_uptime()
# GetRequest.localhost()
GetRequest.requester_loop(0)
GetRequest.print_wait()
Process.sleep(20000)
