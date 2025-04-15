Mix.install([:req])
defmodule GetRequest do
    def hello do 
        IO.puts("Hello, World!")
    end
    def weather do 
        response = Req.get!("https://wttr.in/?format=3")
        IO.inspect(response.body)
    end

    def testing do 
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
GetRequest.weather()