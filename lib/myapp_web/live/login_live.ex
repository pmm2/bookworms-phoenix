defmodule MyappWeb.LoginLive do
  use MyappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sign in")
     |> assign(:show_nav, false)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav}>
      <div class="flex flex-col items-center justify-center min-h-[70vh] px-4">
        <div class="w-full max-w-sm space-y-8 text-center">
          <div class="space-y-2">
            <.icon name="hero-book-open" class="w-16 h-16 mx-auto text-primary" />
            <h1 class="text-3xl font-bold tracking-tight text-base-content">
              Bookworms
            </h1>
            <p class="text-base-content/70">
              Log your reading. Compete with friends. Finish more books.
            </p>
          </div>

          <div class="space-y-4">
            <.link
              navigate={~p"/clubs"}
              class="btn btn-primary btn-lg w-full gap-2 hover:scale-[1.02] active:scale-[0.98] transition-transform"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Sign in with Google
            </.link>
            <p class="text-xs text-base-content/50">
              Demo: click to continue without authentication
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
