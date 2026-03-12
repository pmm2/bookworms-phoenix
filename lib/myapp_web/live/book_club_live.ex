defmodule MyappWeb.BookClubLive do
  use MyappWeb, :live_view

  @mock_sessions [
    %{
      id: "1",
      user_name: "Alex Rivera",
      book_name: "Project Hail Mary",
      amount: 45,
      unit: :pages,
      session_date: ~D[2025-03-12],
      inserted_at: "2 hours ago"
    },
    %{
      id: "2",
      user_name: "Jordan Lee",
      book_name: "The Midnight Library",
      amount: 90,
      unit: :minutes,
      session_date: ~D[2025-03-12],
      inserted_at: "5 hours ago"
    },
    %{
      id: "3",
      user_name: "Sam Chen",
      book_name: "Dune",
      amount: 28,
      unit: :pages,
      session_date: ~D[2025-03-11],
      inserted_at: "Yesterday"
    },
    %{
      id: "4",
      user_name: "Morgan Blake",
      book_name: "Atomic Habits",
      amount: 30,
      unit: :minutes,
      session_date: ~D[2025-03-11],
      inserted_at: "Yesterday"
    },
    %{
      id: "5",
      user_name: "Alex Rivera",
      book_name: "Project Hail Mary",
      amount: 52,
      unit: :pages,
      session_date: ~D[2025-03-10],
      inserted_at: "2 days ago"
    }
  ]

  @mock_leaderboard [
    %{rank: 1, user_name: "Alex Rivera", total_pages: 312, badge: :winner},
    %{rank: 2, user_name: "Jordan Lee", total_pages: 280, badge: nil},
    %{rank: 3, user_name: "Sam Chen", total_pages: 245, badge: nil},
    %{rank: 4, user_name: "Morgan Blake", total_pages: 180, badge: nil}
  ]

  @mock_club %{
    id: "1",
    name: "Sci-Fi Nerds",
    invite_code: "SF2024"
  }

  def mount(%{"id" => id}, _session, socket) do
    club = get_mock_club(id)

    {:ok,
     socket
     |> assign(:page_title, club.name)
     |> assign(:club, club)
     |> assign(:sessions, @mock_sessions)
     |> assign(:leaderboard, @mock_leaderboard)
     |> assign(:show_log_modal, false)
     |> assign(
       :log_form,
       to_form(
         %{
           "book_name" => "",
           "amount" => "",
           "unit" => "pages",
           "session_date" => Date.utc_today() |> Date.to_iso8601()
         }, as: :session)
     )
     |> assign(:show_nav, true)}
  end

  defp get_mock_club("1"), do: %{@mock_club | name: "Sci-Fi Nerds", invite_code: "SF2024"}

  defp get_mock_club("2"),
    do: %{@mock_club | id: "2", name: "Classics Crew", invite_code: "CLS42"}

  defp get_mock_club("3"),
    do: %{@mock_club | id: "3", name: "Mystery Lovers", invite_code: "MYST99"}

  defp get_mock_club(_), do: @mock_club

  def handle_event("open_log", _params, socket) do
    today = Date.utc_today() |> Date.to_iso8601()

    {:noreply,
     socket
     |> assign(:show_log_modal, true)
     |> assign(
       :log_form,
       to_form(%{"book_name" => "", "amount" => "", "unit" => "pages", "session_date" => today},
         as: :session
       )
     )}
  end

  def handle_event("close_log_modal", _params, socket) do
    {:noreply, assign(socket, :show_log_modal, false)}
  end

  def handle_event("log_submit", %{"session" => params}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Logged: #{params["book_name"]} — #{params["amount"]} #{params["unit"]}")
     |> assign(:show_log_modal, false)
     |> assign(
       :log_form,
       to_form(%{"book_name" => "", "amount" => "", "unit" => "pages", "session_date" => ""},
         as: :session
       )
     )}
  end

  def handle_event("validate_log", %{"session" => params}, socket) do
    {:noreply, assign(socket, :log_form, to_form(params, as: :session))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav}>
      <div class="space-y-8">
        <%!-- Club header --%>
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <.link
              navigate={~p"/clubs"}
              class="text-sm text-base-content/60 hover:text-primary mb-1 inline-flex items-center gap-1 transition-colors"
            >
              <.icon name="hero-arrow-left" class="w-4 h-4" /> Back to clubs
            </.link>
            <h1 class="text-2xl font-bold text-base-content">{@club.name}</h1>
            <p class="text-sm text-base-content/60 mt-0.5">
              Invite code:
              <code class="px-2 py-0.5 rounded bg-base-200 font-mono text-sm">
                {@club.invite_code}
              </code>
            </p>
          </div>
          <button
            type="button"
            phx-click="open_log"
            class="btn btn-primary gap-2 self-start sm:self-center"
          >
            <.icon name="hero-plus-circle" class="w-5 h-5" /> Log reading
          </button>
        </div>

        <%!-- Monthly leaderboard --%>
        <div class="rounded-xl border-2 border-base-200 bg-base-200/30 p-5">
          <h2 class="font-semibold text-lg mb-4 flex items-center gap-2">
            <.icon name="hero-trophy" class="w-5 h-5 text-primary" /> March 2025 leaderboard
          </h2>
          <div class="space-y-2">
            <div
              :for={entry <- @leaderboard}
              class={[
                "flex items-center gap-4 rounded-lg px-4 py-3 transition-colors",
                entry.rank == 1 && "bg-primary/10 border border-primary/20",
                entry.rank != 1 && "hover:bg-base-200/50"
              ]}
            >
              <span class={[
                "flex h-8 w-8 items-center justify-center rounded-full text-sm font-bold shrink-0",
                entry.rank == 1 && "bg-primary text-primary-content",
                entry.rank == 2 && "bg-base-300 text-base-content",
                entry.rank == 3 && "bg-amber-500/20 text-amber-700 dark:text-amber-300",
                entry.rank > 3 && "bg-base-300/50 text-base-content/70"
              ]}>
                {entry.rank}
              </span>
              <div class="flex-1 min-w-0">
                <span class="font-medium text-base-content">
                  {entry.user_name}
                  <%= if entry.badge == :winner do %>
                    <span class="ml-2 text-xs font-normal px-2 py-0.5 rounded-full bg-primary/20 text-primary">
                      Winner
                    </span>
                  <% end %>
                </span>
              </div>
              <span class="text-sm font-semibold text-base-content/80 shrink-0">
                {entry.total_pages} pages
              </span>
            </div>
          </div>
        </div>

        <%!-- Reading feed --%>
        <div>
          <h2 class="font-semibold text-lg mb-4 flex items-center gap-2">
            <.icon name="hero-chat-bubble-left-right" class="w-5 h-5 text-base-content/60" />
            Reading feed
          </h2>
          <div class="space-y-3">
            <div
              :for={session <- @sessions}
              class="rounded-xl border border-base-200 bg-base-100 p-4 hover:border-base-300 transition-colors"
            >
              <div class="flex items-start justify-between gap-3">
                <div class="flex-1 min-w-0">
                  <p class="font-semibold text-base-content">{session.book_name}</p>
                  <p class="text-sm text-base-content/60 mt-0.5">
                    {session.user_name} · {format_amount(session)}
                  </p>
                  <p class="text-xs text-base-content/50 mt-1">
                    {format_date(session.session_date)} · {session.inserted_at}
                  </p>
                </div>
                <.icon name="hero-book-open" class="w-8 h-8 text-base-200 shrink-0" />
              </div>
            </div>
          </div>
        </div>

        <%!-- Log session modal --%>
        <.modal :if={@show_log_modal} on_click="close_log_modal">
          <.form
            for={@log_form}
            phx-submit="log_submit"
            phx-change="validate_log"
            id="log-session-form"
          >
            <div class="space-y-4">
              <h2 class="text-xl font-semibold">Log your reading</h2>
              <p class="text-sm text-base-content/70">
                Record what you read today to stay on the leaderboard.
              </p>
              <.input
                field={@log_form[:book_name]}
                type="text"
                label="Book name"
                placeholder="e.g. Project Hail Mary"
                class="input-bordered"
              />
              <div class="grid grid-cols-2 gap-4">
                <.input
                  field={@log_form[:amount]}
                  type="number"
                  label="Amount"
                  placeholder="45"
                  class="input-bordered"
                />
                <.input
                  field={@log_form[:unit]}
                  type="select"
                  label="Unit"
                  options={[{"Pages", "pages"}, {"Minutes", "minutes"}]}
                  class="select-bordered"
                />
              </div>
              <.input
                field={@log_form[:session_date]}
                type="date"
                label="Date"
                class="input-bordered"
              />
              <div class="flex gap-2 justify-end pt-2">
                <button type="button" phx-click="close_log_modal" class="btn btn-ghost">
                  Cancel
                </button>
                <button type="submit" class="btn btn-primary">
                  Log
                </button>
              </div>
            </div>
          </.form>
        </.modal>
      </div>
    </Layouts.app>
    """
  end

  defp format_amount(%{amount: amt, unit: :pages}), do: "#{amt} pages"
  defp format_amount(%{amount: amt, unit: :minutes}), do: "#{amt} min"

  defp format_date(date) do
    date
    |> Date.to_string()
    |> String.replace("-", "/")
  end
end
