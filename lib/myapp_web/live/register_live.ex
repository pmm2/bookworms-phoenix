defmodule MyappWeb.RegisterLive do
  use MyappWeb, :live_view

  alias Myapp.Accounts

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sign up")
     |> assign(:show_nav, false)
     |> assign(
       :form,
       to_form(
         %{"email" => "", "name" => "", "password" => "", "password_confirmation" => ""},
         as: :user
       )
     )}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} show_nav={@show_nav} current_user={@current_user}>
      <div class="flex flex-col items-center justify-center min-h-[70vh] px-4">
        <div class="w-full max-w-sm space-y-8">
          <div class="space-y-2 text-center">
            <.icon name="hero-book-open" class="w-16 h-16 mx-auto text-primary" />
            <h1 class="text-3xl font-bold tracking-tight text-base-content">
              Create your account
            </h1>
            <p class="text-base-content/70">
              Join Bookworms and start tracking your reading.
            </p>
          </div>

          <.form for={@form} phx-submit="register" id="register-form" class="space-y-4">
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              placeholder="you@example.com"
              class="input-bordered"
              required
            />
            <.input
              field={@form[:name]}
              type="text"
              label="Name"
              placeholder="Your name"
              class="input-bordered"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              placeholder="••••••••"
              class="input-bordered"
              required
            />
            <.input
              field={@form[:password_confirmation]}
              type="password"
              label="Confirm password"
              placeholder="••••••••"
              class="input-bordered"
              required
            />
            <button type="submit" class="btn btn-primary btn-block gap-2">
              <.icon name="hero-plus-circle" class="w-5 h-5" /> Sign up
            </button>
          </.form>

          <p class="text-center text-sm text-base-content/60">
            Already have an account?
            <.link navigate={~p"/login"} class="link link-primary font-medium">
              Sign in
            </.link>
          </p>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def handle_event("register", %{"user" => params}, socket) do
    case Accounts.register_user(params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created. Please sign in.")
         |> push_navigate(to: ~p"/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset, as: :user))}
    end
  end
end
