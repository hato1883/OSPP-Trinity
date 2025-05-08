defmodule HelloWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_hello_key",
    signing_salt: "gn9rKpM6",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :hello,
    gzip: false,
    only: HelloWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :hello
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  # Prometheus metrics
  plug PromEx.Plug,
    prom_ex_module: Hello.PromEx,
    metrics_path: "/metrics",
    metrics_options: [prom_ex_module: Hello.PromEx]

  plug HelloWeb.Plug.HealthCheck

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug :set_custom_headers

  defp set_custom_headers(conn,_opts) do
    conn
    |> put_resp_header("cache-control", "max-age=0, private, no-store, must-revalidate")

  end

  plug HelloWeb.Router

end
