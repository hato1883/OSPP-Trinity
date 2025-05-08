Mix.install([:req, :floki])

# import GetRequestToken

defmodule GetRequestToken do

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

  def localhost_post do
    IO.puts("Request loop started...")
    {:ok, body} = File.read("./nuke.json")
    {:ok, data} = Jason.decode(body)
    GetRequestToken.localhost_post_req(data)
  end

  def localhost_post_req(data) do
    Req.post("http://192.168.47.237:8080/?ip=abcd",
    json: data
    )
    # IO.puts("Done!")
    GetRequestToken.localhost_post_req(data)
  end

  def localhost_get() do
    IO.puts("Request loop started...")
    GetRequestToken.localhost_get_req()
  end

  # def localhost_finch do
  #   children = [
  #     {Finch, name: MyFinch}
  #   ]
  # end

  def localhost_get_req() do
    # IO.puts("Request loop started...")
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

  def requester_loop(iteration) when iteration < 20 do
    spawn(fn -> localhost_get() end)
    IO.puts("Requester made")
    requester_loop(iteration + 1)
  end

  def requester_loop(_iteration), do: :ok

  def print_wait do
    IO.puts("Wait for 20 seconds!")
  end
  def switch(case_var) do
    case case_var do
      "local" -> localhost_get()
      "remote" -> localhost_post()
      other -> IO.puts("Error, invalid argument: #{inspect(other)}\nShould be [local | remote]")
    end
  end
end

#  GetRequestToken.hello()

# GetRequestToken.testing()
# GetRequestToken.weather()
# GetRequestToken.localhost_uptime()
# GetRequestToken.localhost()
GetRequestToken.requester_loop(0)
GetRequestToken.print_wait()
Process.sleep(20000)
# [ argument | _ ] = System.argv()
# GetRequest.print(argument)
# GetRequestToken.switch(argument)
