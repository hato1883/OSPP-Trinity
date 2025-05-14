defmodule HelloWeb.AttackLive do
  use HelloWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    HelloWeb.Endpoint.subscribe("attacker")

    send(:attack_coordinator, {:get_attackers, self()})

    receive do
      {:attacker_list, attackers} ->
        {:ok,
         assign(socket,
            attack_in_progress: false,
            attackers: attackers,
            attack_type: "volumetric",
            stopping: false,
            volumetric_form:
            to_form(%{
                "target_address" => "http://localhost",
                "target_port" => 80,
                "workers" => 1
            }),
           slowloris_form:
             to_form(%{
               "target_address" => "http://localhost",
               "target_port" => 80,
               "workers" => 1,
               "transmission_interval" => 1000
             })
         )}
    after
      500 ->
        {:ok,
         assign(socket,
            attack_in_progress: false,
            attackers: %{},
            attack_type: "volumetric",
            stopping: false,
            volumetric_form:
            to_form(%{
                "target_address" => "http://localhost",
                "target_port" => 80,
                "workers" => 1
            }),
           slowloris_form:
             to_form(%{
               "target_address" => "http://localhost",
               "target_port" => 80,
               "workers" => 1,
               "transmission_interval" => 1000
             })
         )}
    end
  end


  def render(assigns) do
    # Logger.info("#{inspect assigns}")
    ~H"""

      <section>
        <%= if @attack_type == "volumetric" do %>
            <div class="flex justify-center space-x-4">
                <button phx-click={JS.push("switch_attack_type", value: %{attack_type: "volumetric"})} disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Volumetric</button>
                <button phx-click={JS.push("switch_attack_type", value: %{attack_type: "slowloris"})} class="bg-black hover:bg-gray-600 p-3 rounded-md text-white font-semibold" >Slowloris</button>
            </div>
            <.form for={@volumetric_form} class="grid grid-cols-2 gap-3" phx-submit="start_volumetric">
                <label class="self-center" >Target address</label>
                <.input type="text" field={@volumetric_form[:target_address]} />
                <label class="self-center" >Target port</label>
                <.input type="text" field={@volumetric_form[:target_port]} />
                <label class="self-center">Workers</label>
                <.input type="number" field={@volumetric_form[:workers]}/>

                <%= if @attack_in_progress do %>
                    <button id="start-btn" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Start</button>
                    <%= if @stopping do %>
                        <button phx-click="stop" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                    <% else %>
                        <button phx-click="stop" class="bg-black hover:bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                    <% end %>
                <% else %>
                    <button id="start-btn" class="bg-black hover:bg-gray-600 p-3 rounded-md text-white font-semibold">Start</button>
                    <button phx-click="stop" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                <% end %>
            </.form>
        <% end %>

        <%= if @attack_type == "slowloris" do %>
            <div class="flex justify-center space-x-4">
                <button phx-click={JS.push("switch_attack_type", value: %{attack_type: "volumetric"})} class="bg-black hover:bg-gray-600 p-3 rounded-md text-white font-semibold">Volumetric</button>
                <button phx-click={JS.push("switch_attack_type", value: %{attack_type: "slowloris"})} disabled="true" class="bg-gray-400 hover:bg-gray-400 p-3  rounded-md text-white font-semibold">Slowloris</button>
            </div>
            <.form for={@slowloris_form} class="grid grid-cols-2 gap-3" phx-submit="start_slowloris">
                <label class="self-center" >Target address</label>
                <.input type="text" field={@slowloris_form[:target_address]} />
                <label class="self-center" >Target port</label>
                <.input type="text" field={@slowloris_form[:target_port]} />
                <label class="self-center">Workers</label>
                <.input type="number" field={@slowloris_form[:workers]}/>
                <label class="self-center">Transmission interval(ms)</label>
                <.input type="number" field={@slowloris_form[:transmission_interval]}/>

                <%= if @attack_in_progress do %>
                    <button id="start-btn" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Start</button>
                    <%= if @stopping do %>
                        <button phx-click="stop" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                    <% else %>
                        <button phx-click="stop" class="bg-black hover:bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                    <% end %>
                <% else %>
                    <button id="start-btn" class="bg-black hover:bg-gray-600 p-3 rounded-md text-white font-semibold">Start</button>
                    <button phx-click="stop" disabled="true" class="bg-gray-400 p-3  rounded-md text-white font-semibold">Stop</button>
                <% end %>
            </.form>
        <% end %>
      </section>

      <%= if @stopping do %>
        <label class="flex justify-center mt-4">Stopping...</label>
    <% end %>


      <h3 class="flex justify-center text-xl mt-12">Connected nodes</h3>

      <ul>
        <%= for {node, {processing, workers}} <- @attackers do %>
          <li class="grid grid-cols-2 gap-3 my-1 bg-gray-200 p-6">
            <label>Node:</label>
            <label>{ inspect node}</label>
            <label>Attacking:</label>
            <label>{processing}</label>
            <label>Active workers:</label>
            <label>{workers}</label>
          </li>
        <% end %>
      </ul>
    """
  end

  def handle_info(%{event: "subscribed", payload: %{node: node, pid: pid}}, socket) do
    {:noreply, assign(socket, node: inspect(node), pid: inspect(pid))}
  end

  def handle_info(%{event: "attacker_list_update", payload: attackers}, socket) do

    attack_in_progress = Map.values(attackers)
    |> List.foldl(false, fn {processing, _}, acc -> acc or processing end)

    if socket.assigns[:stopping] and !attack_in_progress do
        {:noreply, assign(socket, attackers: attackers, attack_in_progress: attack_in_progress, stopping: false)}
    else
        {:noreply, assign(socket, attackers: attackers, attack_in_progress: attack_in_progress)}
    end

  end

  def handle_event(
        "start",
        %{
          "target" => target,
          "workers" => workers,
          "requests" => requests,
          "method" => method,
          "attack_type" => attack_type
        },
        socket
      ) do
    Logger.info("Start: #{workers} workers, #{requests} ")

    send(
      :attack_coordinator,
      {:start_attack, String.to_integer(workers), target, String.to_integer(requests), method,
       attack_type}
    )

    {:noreply, socket}
  end

  def handle_event(
        "start_volumetric",
        %{
          "target_address" => target_address,
          "target_port" => target_port,
          "workers" => workers
        },
        socket
      ) do
    Logger.info("Starting volumetric attack")

    send(
      :attack_coordinator,
      {:start_volumetric, target_address, String.to_integer(target_port), String.to_integer(workers)}
    )

    {:noreply, socket}
  end

  def handle_event(
        "start_slowloris",
        %{
          "target_address" => target_address,
          "target_port" => target_port,
          "workers" => workers,
          "transmission_interval" => transmission_interval
        },
        socket
      ) do
    Logger.info("Starting slowloris attack")

    send(
      :attack_coordinator,
      {:start_slowloris, target_address, String.to_integer(target_port), String.to_integer(workers), String.to_integer(transmission_interval)}
    )

    {:noreply, socket}
  end

  def handle_event("switch_attack_type", %{"attack_type" => attack_type}, socket) do
    {:noreply, assign(socket, attack_type: attack_type)}
  end

  def handle_event("stop", _params, socket) do
    send(:attack_coordinator, :stop_attack)
    {:noreply, assign(socket, stopping: true)}
  end

  def handle_event(event, params, socket) do
    Logger.info("Unhandled event: #{event}\nWith parameters: #{inspect(params)}")

    {:noreply, socket}
  end
end
