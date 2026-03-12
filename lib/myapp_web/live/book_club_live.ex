defmodule MyappWeb.BookClubLive do
  use MyappWeb, :live_view

  alias Myapp.Clubs

  def mount(%{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user

    case Clubs.get_club(id) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Club not found.")
         |> push_navigate(to: ~p"/clubs")}

      club ->
        if Clubs.membership?(club, current_user) do
          {:ok,
           socket
           |> assign(:page_title, club.name)
           |> assign(:club, club)
           |> assign(:sessions, Clubs.list_sessions(club))
           |> assign(:leaderboard, Clubs.list_leaderboard(club))
           |> assign(:show_log_modal, false)
           |> assign(
             :log_form,
             to_form(
               %{
                 "book_name" => "",
                 "amount" => "",
                 "unit" => "pages",
                 "session_date" => Date.utc_today() |> Date.to_iso8601()
               },
               as: :session
             )
           )
           |> assign(:show_nav, true)}
        else
          {:ok,
           socket
           |> put_flash(:error, "You don't have access to this club.")
           |> push_navigate(to: ~p"/clubs")}
        end
    end
  end

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
    {club, current_user} = {socket.assigns.club, socket.assigns.current_user}

    case Clubs.log_session(current_user, club, params) do
      {:ok, _session} ->
        today = Date.utc_today() |> Date.to_iso8601()

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Logged: #{params["book_name"]} — #{params["amount"]} #{params["unit"]}"
         )
         |> assign(:show_log_modal, false)
         |> assign(:sessions, Clubs.list_sessions(club))
         |> assign(:leaderboard, Clubs.list_leaderboard(club))
         |> assign(
           :log_form,
           to_form(
             %{"book_name" => "", "amount" => "", "unit" => "pages", "session_date" => today},
             as: :session
           )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:log_form, to_form(changeset, as: :session))}

      {:error, :not_member} ->
        {:noreply,
         socket
         |> put_flash(:error, "You're not a member of this club.")
         |> assign(:show_log_modal, false)}
    end
  end

  def handle_event("validate_log", %{"session" => params}, socket) do
    {:noreply, assign(socket, :log_form, to_form(params, as: :session))}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav} current_user={@current_user}>
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
            <.icon name="hero-trophy" class="w-5 h-5 text-primary" />
            {leaderboard_title()}
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
                {format_leaderboard_entry(entry)}
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

  defp format_amount(%{amount: amt, unit: unit}) when unit in [:pages, "pages"],
    do: "#{amt} pages"

  defp format_amount(%{amount: amt, unit: unit}) when unit in [:minutes, "minutes"],
    do: "#{amt} min"

  defp format_leaderboard_entry(entry) do
    parts = []

    parts =
      if (entry[:total_pages] || 0) > 0,
        do: [to_string(entry[:total_pages]) <> " pages" | parts],
        else: parts

    parts =
      if (entry[:total_minutes] || 0) > 0,
        do: [to_string(entry[:total_minutes]) <> " min" | parts],
        else: parts

    if parts == [], do: "—", else: Enum.reverse(parts) |> Enum.join(" · ")
  end

  defp leaderboard_title do
    now = Date.utc_today()
    Calendar.strftime(now, "%B %Y") <> " leaderboard"
  end

  defp format_date(date) do
    date
    |> Date.to_string()
    |> String.replace("-", "/")
  end
end
