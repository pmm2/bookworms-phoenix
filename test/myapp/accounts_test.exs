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
      auth =
        build_ueberauth(uid: "google-456", email: "existing@example.com", name: "Original Name")

      user = Accounts.get_or_create_user_from_auth(auth)

      auth_updated =
        build_ueberauth(uid: "google-456", email: "existing@example.com", name: "Updated Name")

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

  describe "register_user/1" do
    test "creates a user with email and password" do
      attrs = %{
        "email" => "newuser@example.com",
        "name" => "New User",
        "password" => "secret123",
        "password_confirmation" => "secret123"
      }

      assert {:ok, user} = Accounts.register_user(attrs)
      assert user.email == "newuser@example.com"
      assert user.name == "New User"
      assert user.password_hash != nil
      assert user.google_uid == nil
    end

    test "returns error for invalid attrs" do
      assert {:error, _} =
               Accounts.register_user(%{"email" => "", "name" => "", "password" => "short"})
    end

    test "returns error for duplicate email" do
      attrs = %{
        "email" => "dup@example.com",
        "name" => "First",
        "password" => "password123",
        "password_confirmation" => "password123"
      }

      assert {:ok, _} = Accounts.register_user(attrs)
      assert {:error, changeset} = Accounts.register_user(attrs)
      assert %{email: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "returns user when email and password match" do
      {:ok, user} =
        Accounts.register_user(%{
          "email" => "auth@example.com",
          "name" => "Auth User",
          "password" => "password123",
          "password_confirmation" => "password123"
        })

      assert found = Accounts.get_user_by_email_and_password("auth@example.com", "password123")
      assert found.id == user.id
    end

    test "returns nil when password is wrong" do
      {:ok, _user} =
        Accounts.register_user(%{
          "email" => "wrong@example.com",
          "name" => "User",
          "password" => "password123",
          "password_confirmation" => "password123"
        })

      assert nil == Accounts.get_user_by_email_and_password("wrong@example.com", "wrongpass")
    end

    test "returns nil when email does not exist" do
      assert nil == Accounts.get_user_by_email_and_password("nonexistent@example.com", "anything")
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
    |> User.oauth_changeset(attrs)
    |> Myapp.Repo.insert!()
  end
end
