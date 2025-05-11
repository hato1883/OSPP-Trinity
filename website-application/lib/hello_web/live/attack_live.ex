defmodule HelloWeb.AttackLive do
  use HelloWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("attacker")

    send(:attack_coordinator, {:get_attackers, self()})

    receive do
      {:attacker_list, attackers} ->
        {:ok, assign(socket, attackers: attackers, form: to_form(%{"target" => "http://localhost", "workers" => 1, "requests" => 1}))}
    after
      500 ->
        {:ok, assign(socket, attackers: %{}, form: to_form(%{"target" => "http://localhost", "workers" => 1, "requests" => 1}))}
    end
  end

  def render(assigns) do
    ~H"""
      <section>
        <.form for={@form} class="grid grid-cols-2 gap-3" phx-submit="start">
            <label class="self-center">Target address</label>
            <.input id="target-input" type="text" field={@form[:target]} />
            <label class="self-center">Workers</label>
            <.input id="workers-input" type="number" field={@form[:workers]}/>
            <label class="self-center">Requests</label>
            <.input id="requests-input" type="number" field={@form[:requests]}/>
            <.button id="start-btn" class="col-span-2 self-center" >Start</.button>
        </.form>
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

  def handle_event("start", %{"target" => target, "workers" => workers, "requests" => requests}, socket) do

    Logger.info("Start: #{workers} workers, #{requests}")

    send(:attack_coordinator, {:start_attack, String.to_integer(workers), target, String.to_integer(requests)})

    {:noreply, socket}
  end

  def handle_event(event, params, socket) do
    Logger.info("Unhandled event: #{event}~nWith parameters: #{inspect params}")

    {:noreply, socket}
  end
end
