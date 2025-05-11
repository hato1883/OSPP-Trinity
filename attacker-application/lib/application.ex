defmodule AttackApplication do
  use Application
  require AttackSupervisor

  @impl true
  def start(_type, _args) do
    children = [
      %{
        id: AttackSupervisor,
        start: {AttackSupervisor, :start_link, [:web@e573c4267773]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
