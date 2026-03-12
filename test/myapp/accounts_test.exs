defmodule Myapp.AccountsTest do
  use Myapp.DataCase, async: true

  alias Myapp.Accounts
  alias Myapp.Accounts.User

  describe "get_or_create_user_from_auth/1" do
    test "creates a new user when google_uid does not exist" do
      auth = build_ueberauth(uid: "google-123", email: "new@example.com", name: "New User")

      user = Accounts.get_or_create_user_from_auth(auth)

      assert user.email == "new@example.com"
      assert user.name == "New User"
      assert user.google_uid == "google-123"
    end

    test "updates existing user when google_uid exists" do
      auth = build_ueberauth(uid: "google-456", email: "existing@example.com", name: "Original Name")
      user = Accounts.get_or_create_user_from_auth(auth)

      auth_updated = build_ueberauth(uid: "google-456", email: "existing@example.com", name: "Updated Name")
      updated = Accounts.get_or_create_user_from_auth(auth_updated)

      assert updated.id == user.id
      assert updated.name == "Updated Name"
    end
  end

  describe "get_user/1" do
    test "returns user when exists" do
      user = insert_user!()
      assert Accounts.get_user(user.id).id == user.id
    end

    test "returns nil when user does not exist" do
      assert Accounts.get_user(-1) == nil
    end
  end

  describe "get_user!/1" do
    test "returns user when exists" do
      user = insert_user!()
      assert Accounts.get_user!(user.id).id == user.id
    end

    test "raises when user does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end
  end

  defp build_ueberauth(uid: uid, email: email, name: name) do
    %Ueberauth.Auth{
      uid: uid,
      provider: :google,
      info: %Ueberauth.Auth.Info{
        email: email,
        name: name,
        image: "https://example.com/avatar.png"
      }
    }
  end

  defp insert_user!(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: "test-#{:rand.uniform(100_000)}@example.com",
        name: "Test User",
        google_uid: "google-#{:rand.uniform(100_000)}"
      })

    %User{}
    |> User.changeset(attrs)
    |> Myapp.Repo.insert!()
  end
end
