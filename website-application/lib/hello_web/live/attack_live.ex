defmodule HelloWeb.AttackLive do
  use HelloWeb, :live_view

  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("attacker")

    send(:attack_coordinator, {:get_attackers, self()})

    receive do
      {:attacker_list, attackers} ->
        {:ok, assign(socket, attackers: attackers)}
    after
      500 ->
        {:ok, assign(socket, attackers: %{})}
    end
  end

  def render(assigns) do
    ~H"""
      <section>
        <div class="grid grid-cols-2 gap-3">
            <label class="self-center">Target address</label>
            <input id="target-input" type="text" />
            <label class="self-center">Workers</label>
            <input id="workers-input" type="number" />
            <label class="self-center">Requests</label>
            <input id="requests-input" type="number" />
          <.button id="start-btn" >Start</.button>
        </div>
      </section>

      <h3 class="flex justify-center text-xl mt-12">Connected nodes</h3>

      <ul>
        <%= for {node, workers} <- @attackers do %>
          <li class="grid grid-cols-2 gap-3 my-8 bg-gray-200 p-6">
            <label>Node:</label>
            <label>{ inspect node}</label>
            <label>Active workers:</label>
            <label>{workers}</label>
          </li>
        <% end %>
      </ul>
    """
  end

  def handle_info(
        %{event: "active-update", payload: %{node: _node, pid: _pid, active: active_workers}},
        socket
      ) do
    {:noreply, assign(socket, active: active_workers)}
  end

  def handle_info(%{event: "subscribed", payload: %{node: node, pid: pid}}, socket) do
    {:noreply, assign(socket, node: inspect(node), pid: inspect(pid))}
  end

  def handle_info(%{event: "attacker_list_update", payload: attackers}, socket) do
    {:noreply, assign(socket, attackers: attackers)}
  end
end
