defmodule MyappWeb.Router do
  use MyappWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyappWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MyappWeb.AuthPlug, :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", MyappWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/", MyappWeb do
    pipe_through :browser

    get "/", PageController, :redirect_to_login
    delete "/logout", AuthController, :delete
    post "/session", SessionController, :create

    live_session :redirect_if_authenticated,
      on_mount: [{MyappWeb.LiveAuth, :redirect_if_authenticated}] do
      live "/login", LoginLive, :index
      live "/register", RegisterLive, :index
    end

    live_session :require_authenticated,
      on_mount: [{MyappWeb.LiveAuth, :require_authenticated}] do
      live "/clubs", BookClubsLive, :index
      live "/clubs/:id", BookClubLive, :show
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyappWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:myapp, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyappWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
