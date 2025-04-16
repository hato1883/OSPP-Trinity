Mix.install([:jason])

defmodule JsonGenerator do
  def generate(path \\ "nuke.json", count \\ 1_000_000) do
    data = Enum.map(1..count, fn i ->
      %{"key_#{i}" => :crypto.strong_rand_bytes(16) |> Base.encode64()}
    end)

    json = Jason.encode!(data)

    File.write!(path, json)
    
    IO.puts("Generated #{count} entries to #{path}")
  end
end

JsonGenerator.generate()
