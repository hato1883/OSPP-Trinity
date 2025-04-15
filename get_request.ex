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
  def localhost do
    IO.puts("Request loop started...")
    GetRequest.localhost_req()
  end 

  def localhost_req do
    Req.get("http://localhost:8080/dev/dashboard/home")
    # IO.puts("Request made!")
    # IO.puts("Waiting for 1 second(s)...")
    # :timer.sleep(1000)
    # IO.puts("Done!")
    GetRequest.localhost_req()
  end 

  def requester_loop(iteration) when iteration < 100 do
    spawn(fn -> localhost() end)
    IO.puts("Requester made")
    requester_loop(iteration + 1)
  end
  
  def requester_loop(_iteration), do: :ok
  

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
Process.sleep(50000)
