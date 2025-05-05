defmodule HelloWeb.AttackLive do
  use HelloWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, workers: 0, requests: 0, active_workers: 0, processing: false)}
  end

  def render(assigns) do

    ~H"""
      <section>
        <h3>Test</h3>
        <div>
          <div>
            <label>Workers</label>
            <input type="number" value={@workers} />
          </div>
          <div>
            <label>Requests</label>
            <input type="number" value={@requests} />
          </div>
          <.button phx-click="start">Start</.button>
        </div>
        <div>
          <label>Processing: </label>
          <span>{@processing}</span>
        </div>
        <div>
          <label>Active workers:</label>
          <span>{@active_workers}</span>
        </div>
      </section>
    """

  end

  def handle_event("start", _value, socket) do
    assigns = socket.assigns

    send({:attack_supervisor, :attack@ed5457feacf7}, {:start, self(), 1, "http://localhost:8080", 1})

    receive do
      :ok ->
        {:ok, assign(socket, processing: true, active_workers: 1)}

      :error ->
        {:noreply, socket}

    end
  end

end
