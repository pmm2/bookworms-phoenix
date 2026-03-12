defmodule MyappWeb.ConfigLive do
  use MyappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Settings")
     |> assign(:show_nav, true)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav} current_user={@current_user}>
      <div class="space-y-8">
        <div>
          <.link
            navigate={~p"/clubs"}
            class="text-sm text-base-content/60 hover:text-primary mb-2 inline-flex items-center gap-1 transition-colors"
          >
            <.icon name="hero-arrow-left" class="w-4 h-4" /> Back to clubs
          </.link>
          <h1 class="text-2xl font-bold text-base-content">Settings</h1>
        </div>

        <div class="rounded-xl border border-base-200 bg-base-100 p-6">
          <h2 class="font-semibold text-lg mb-4 flex items-center gap-2">
            <.icon name="hero-swatch" class="w-5 h-5 text-primary" /> Theme
          </h2>
          <p class="text-sm text-base-content/70 mb-4">
            Choose how Bookworms looks. Your preference is saved.
          </p>
          <Layouts.theme_toggle />
        </div>
      </div>
    </Layouts.app>
    """
  end
end
