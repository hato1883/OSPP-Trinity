defmodule HelloWeb.ThermostatLive do
  use HelloWeb, :live_view


  def render(assigns) do
    ~H"""
    Current temperature: {@temperature} °C <button phx-click="inc_temperature">+</button>
    <button phx-click="dec_temperature">-</button>

    <button phx-click="nice">69</button>

    <button phx-click="random">random</button>

    <p>How about this: {@request}</p>
    <button phx-click="request">request</button>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:temperature, 70)
      |> assign(:request, "RARAREQUEST")

    {:ok, socket}
  end

  def handle_event(event, _params, socket) do
    case event do
      "inc_temperature" ->
        {:noreply, update(socket, :temperature, &(&1 + 1))}

      "dec_temperature" ->
        {:noreply, update(socket, :temperature, &(&1 - 1))}

      "nice" ->
        {:noreply, update(socket, :temperature, fn _ -> 69 end)}

      "random" ->
        {:noreply, update(socket, :temperature, fn _ -> :rand.uniform(100) end)}

      _ ->
        # Default case for unhandled events
        {:noreply, socket}
    end
  end
end
