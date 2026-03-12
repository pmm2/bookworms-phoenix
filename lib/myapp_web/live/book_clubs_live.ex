defmodule MyappWeb.BookClubsLive do
  use MyappWeb, :live_view

  @mock_clubs [
    %{
      id: "1",
      name: "Sci-Fi Nerds",
      invite_code: "SF2024",
      member_count: 8,
      last_activity: "2 hours ago"
    },
    %{
      id: "2",
      name: "Classics Crew",
      invite_code: "CLS42",
      member_count: 5,
      last_activity: "Yesterday"
    },
    %{
      id: "3",
      name: "Mystery Lovers",
      invite_code: "MYST99",
      member_count: 12,
      last_activity: "5 min ago"
    }
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "My book clubs")
     |> assign(:clubs, @mock_clubs)
     |> assign(:show_join_modal, false)
     |> assign(:show_create_modal, false)
     |> assign(:join_form, to_form(%{"invite_code" => ""}, as: :join))
     |> assign(:create_form, to_form(%{"name" => ""}, as: :create))
     |> assign(:show_nav, true)}
  end

  def handle_event("open_join", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_join_modal, true)
     |> assign(:show_create_modal, false)}
  end

  def handle_event("open_create", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_create_modal, true)
     |> assign(:show_join_modal, false)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_join_modal, false)
     |> assign(:show_create_modal, false)}
  end

  def handle_event("join_submit", %{"join" => %{"invite_code" => code}}, socket) do
    if String.trim(code) != "" do
      {:noreply,
       socket
       |> put_flash(:info, "Joined club with code: #{code}")
       |> assign(:show_join_modal, false)
       |> assign(:join_form, to_form(%{"invite_code" => ""}, as: :join))}
    else
      {:noreply, assign(socket, :join_form, to_form(%{"invite_code" => code}, as: :join))}
    end
  end

  def handle_event("create_submit", %{"create" => %{"name" => name}}, socket) do
    if String.trim(name) != "" do
      {:noreply,
       socket
       |> put_flash(:info, "Created club: #{name}")
       |> assign(:show_create_modal, false)
       |> assign(:create_form, to_form(%{"name" => ""}, as: :create))}
    else
      {:noreply, assign(socket, :create_form, to_form(%{"name" => name}, as: :create))}
    end
  end

  def handle_event("validate_join", %{"join" => params}, socket) do
    {:noreply, assign(socket, :join_form, to_form(params, as: :join))}
  end

  def handle_event("validate_create", %{"create" => params}, socket) do
    {:noreply, assign(socket, :create_form, to_form(params, as: :create))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav} current_user={@current_user}>
      <div class="space-y-8">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <h1 class="text-2xl font-bold text-base-content">My book clubs</h1>
          <div class="flex gap-2">
            <button
              type="button"
              phx-click="open_join"
              class="btn btn-outline btn-sm gap-1.5 hover:btn-primary hover:border-primary transition-colors"
            >
              <.icon name="hero-ticket" class="w-4 h-4" /> Join club
            </button>
            <button
              type="button"
              phx-click="open_create"
              class="btn btn-primary btn-sm gap-1.5"
            >
              <.icon name="hero-plus-circle" class="w-4 h-4" /> Create club
            </button>
          </div>
        </div>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          <.link
            :for={club <- @clubs}
            navigate={~p"/clubs/#{club.id}"}
            class="group block rounded-xl border-2 border-base-200 bg-base-200/50 p-5 hover:border-primary/40 hover:bg-base-200/80 hover:shadow-lg transition-all duration-200"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1 min-w-0">
                <h2 class="font-semibold text-lg text-base-content truncate group-hover:text-primary transition-colors">
                  {club.name}
                </h2>
                <p class="text-sm text-base-content/60 mt-1">
                  {club.member_count} members · {club.last_activity}
                </p>
              </div>
              <.icon
                name="hero-chevron-right"
                class="w-5 h-5 text-base-content/40 group-hover:text-primary group-hover:translate-x-1 transition-all shrink-0 mt-0.5"
              />
            </div>
          </.link>
        </div>

        <%!-- Join club modal --%>
        <.modal :if={@show_join_modal} on_click="close_modal">
          <.form
            for={@join_form}
            phx-submit="join_submit"
            phx-change="validate_join"
            id="join-club-form"
          >
            <div class="space-y-4">
              <h2 class="text-xl font-semibold">Join a club</h2>
              <p class="text-sm text-base-content/70">
                Enter the invite code shared by a club member.
              </p>
              <.input
                field={@join_form[:invite_code]}
                type="text"
                label="Invite code"
                placeholder="e.g. SF2024"
                class="input-bordered"
              />
              <div class="flex gap-2 justify-end">
                <button type="button" phx-click="close_modal" class="btn btn-ghost">
                  Cancel
                </button>
                <button type="submit" class="btn btn-primary">
                  Join
                </button>
              </div>
            </div>
          </.form>
        </.modal>

        <%!-- Create club modal --%>
        <.modal :if={@show_create_modal} on_click="close_modal">
          <.form
            for={@create_form}
            phx-submit="create_submit"
            phx-change="validate_create"
            id="create-club-form"
          >
            <div class="space-y-4">
              <h2 class="text-xl font-semibold">Create a club</h2>
              <p class="text-sm text-base-content/70">
                Start a new book club and share the invite code with friends.
              </p>
              <.input
                field={@create_form[:name]}
                type="text"
                label="Club name"
                placeholder="e.g. Weekend Readers"
                class="input-bordered"
              />
              <div class="flex gap-2 justify-end">
                <button type="button" phx-click="close_modal" class="btn btn-ghost">
                  Cancel
                </button>
                <button type="submit" class="btn btn-primary">
                  Create
                </button>
              </div>
            </div>
          </.form>
        </.modal>
      </div>
    </Layouts.app>
    """
  end
end
