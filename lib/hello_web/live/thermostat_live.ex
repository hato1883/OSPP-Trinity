defmodule HelloWeb.ThermostatLive do
  use HelloWeb, :live_view

  def render(assigns) do
    ~H"""
    Current temperature: {@temperature} °C
    <button phx-click="inc_temperature">+</button>
    <button phx-click="dec_temperature">-</button>

    <button phx-click="nice">69</button>

    <button phx-click="random">random</button>
    """
  end

  def mount(_params, _session, socket) do
      temperature = 70
      {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_event("inc_temperature", _params, socket) do
      {:noreply, update(socket, :temperature, &(&1 + 1))}
  end


  def handle_event("dec_temperature", _params, socket) do
      {:noreply, update(socket, :temperature, &(&1 - 1))}
  end


  def handle_event("nice", _params, socket) do
      {:noreply, update(socket, :temperature, &(&1-&1 +69))}
  end

  def handle_event("random", _params, socket) do
      {:noreply, update(socket, :temperature, &(&1-&1 + :rand.uniform(100)))}
  end

end
