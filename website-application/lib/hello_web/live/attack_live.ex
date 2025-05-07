defmodule HelloWeb.AttackLive do
  use HelloWeb, :live_view

  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("attacker")
    {:ok, assign(socket, active: 0, node: nil, pid: nil)}
  end

  def render(assigns) do

    ~H"""
      <section>
        <div class="grid grid-cols-2 gap-3">
            <label class="self-center">Workers</label>
            <input id="workers-input" type="number" />
            <label class="self-center">Requests</label>
            <input id="requests-input" type="number" />
          <.button id="start-btn" phx-click="start">Start</.button>
        </div>
      </section>

      <section class="grid grid-cols-2 gap-3 my-8">
        <label>Node:</label>
        <label>{@node}</label>
        <label>PID:</label>
        <label>{@pid}</label>
        <label>Active workers:</label>
        <label>{@active}</label>
      </section>
    """

  end


  def handle_info(%{event: "active-update", payload: %{node: _node, pid: _pid, active: active_workers}}, socket) do
    {:noreply, assign(socket, active: active_workers)}
  end

  def handle_info(%{event: "subscribed", payload: %{node: node, pid: pid}}, socket) do
    {:noreply, assign(socket, node: inspect(node), pid: inspect(pid))}
  end
end
