defmodule AttackApplication do
  use Application
  require AttackSupervisor

  # Application module to enable the attack supervisor module to be started with mix run

  @impl true
  def start(_type, _args) do
    children = [
      %{
        id: AttackSupervisor,
        # Start the attack supervisor with the argument :web@hostname where hostname is the first command line argument
        start:
          {AttackSupervisor, :start_link, [String.to_atom("web@" <> List.first(System.argv()))]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
