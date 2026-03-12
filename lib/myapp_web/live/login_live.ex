defmodule MyappWeb.LoginLive do
  use MyappWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sign in")
     |> assign(:show_nav, false)
     |> assign(
       :login_form,
       to_form(%{"email" => "", "password" => ""}, as: :user)
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
              Bookworms
            </h1>
            <p class="text-base-content/70">
              Log your reading. Compete with friends. Finish more books.
            </p>
          </div>

          <div class="space-y-4">
            <.form
              for={@login_form}
              action={~p"/session"}
              method="post"
              id="login-form"
              class="space-y-4"
            >
              <.input
                field={@login_form[:email]}
                type="email"
                label="Email"
                placeholder="you@example.com"
                class="input-bordered"
                required
              />
              <.input
                field={@login_form[:password]}
                type="password"
                label="Password"
                placeholder="••••••••"
                class="input-bordered"
                required
              />
              <button type="submit" class="btn btn-primary btn-block gap-2">
                <.icon name="hero-envelope" class="w-5 h-5" /> Sign in with email
              </button>
            </.form>

            <div class="flex items-center gap-2 text-sm text-base-content/60">
              <span class="flex-1 border-t border-base-200" />
              <span>or</span>
              <span class="flex-1 border-t border-base-200" />
            </div>

            <a
              href={~p"/auth/google"}
              class="btn btn-outline btn-lg w-full gap-2 hover:scale-[1.01] active:scale-[0.99] transition-transform inline-flex items-center justify-center"
            >
              <.icon name="hero-arrow-right-on-rectangle" class="w-5 h-5" /> Sign in with Google
            </a>

            <p class="text-center text-sm text-base-content/60">
              Don't have an account?
              <.link navigate={~p"/register"} class="link link-primary font-medium">
                Sign up
              </.link>
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
