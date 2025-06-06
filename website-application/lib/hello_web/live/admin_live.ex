defmodule HelloWeb.AdminLive do
  use HelloWeb, :live_view

  def render(assigns) do
    ~H"""
    Current temperature: {@temperature} °C
    <.button phx-click="inc_temperature">+</.button>
    <.button phx-click="dec_temperature">-</.button>

    <.button phx-click="nice">51</.button>

    <.button phx-click="random">random</.button>

    <p>How about this: {@request}</p>
    <.button phx-click="request">request</.button>

    <h3>Running Servers</h3>
    <div style="height: 150px; overflow-y: auto; border: 1px solid #ccc; margin-top: 10px; padding: 5px;">
      <ul>
        <%= for server <- @servers do %>
          <li>
            <.icon name="hero-server-solid" />
            {server.name} - Status: {server.status}
          </li>
        <% end %>
      </ul>
    </div>
    Nodes
    <div style="height: 150px; overflow-y: auto; border: 1px solid #ccc; margin-top: 10px; padding: 5px;">
      <ul>
        <%= for node <- @nodes do %>
          <li>
            <.icon name="hero-moon-solid" />
            {node.name} - Status: {node.status}
          </li>
        <% end %>
      </ul>
    </div>

    <div style="height: 150px; overflow-y: auto; border: 1px solid #ccc; margin-top: 10px; padding: 5px;">
      Random data {@random}
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # nodes = Node.list()
   
    nodes = [
      %{name: "Placeholder node 1", status: "Unknown"},
      %{name: "Placeholder node 2", status: "Unknown"},
      %{name: "Placeholder node 3", status: "Unknown"},
      %{name: "Placeholder node 4", status: "Unknown"}
    ]

    # Initial list of servers
    servers = [
      %{name: "Placeholder server 1", status: "Unknown"},
      %{name: "Placeholder server 2", status: "Unknown"},
      %{name: "Placeholder server 3", status: "Unknown"},
      %{name: "Placeholder server 4", status: "Unknown"}
    ]

    random = :rand.uniform(20)

    socket =
      socket
      |> assign(:temperature, 70)
      |> assign(:request, "Request")
      |> assign(:servers, servers)
      |> assign(:nodes, nodes)
      |> assign(:random, random)

    {:ok, socket}
  end

  def handle_info(msg, socket) do
    case msg do
      _ ->
        {:noreply, update(socket, :random, &(&1 - &1 + :rand.uniform(100)))}
    end
  end

  def handle_info(%{event: "server_update", payload: server_update}, socket) do
    updated_servers =
      Enum.map(socket.assigns.servers, fn server ->
        if server.name == server_update.name do
          %{server | status: server_update.status}
        else
          server
        end
      end)

    {:noreply, assign(socket, :servers, updated_servers)}
  end

  def handle_event(event, _params, socket) do
    case event do
      "inc_temperature" ->
        {:noreply, update(socket, :temperature, &(&1 + 1))}

      "dec_temperature" ->
        {:noreply, update(socket, :temperature, &(&1 - 1))}

      "nice" ->
        {:noreply, update(socket, :temperature, fn _ -> 51 end)}

      "random" ->
        {:noreply, update(socket, :temperature, fn _ -> :rand.uniform(100) end)}

      _ ->
        # Default case for unhandled events
        {:noreply, socket}
    end
  end
end
