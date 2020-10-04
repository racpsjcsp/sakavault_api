defmodule SakaVault.AuthTest do
  use SakaVault.DataCase

  alias SakaVault.{Auth, Guardian}

  setup do
    {:ok, user: insert(:user)}
  end

  describe "authenticate/1 with user" do
    test "authenticate user", %{user: user} do
      user_id = user.id
      auth_user = Map.take(user, [:id, :name, :email])

      assert {:ok, %{token: token, user: ^auth_user}} = Auth.authenticate(user)

      assert {:ok, %{"sub" => ^user_id}} = Guardian.decode_and_verify(token)
    end
  end

  describe "authenticate/2" do
    test "authenticate user", %{user: user} do
      assert {:ok, %{token: _, user: _}} = Auth.authenticate(user.email, user.name)
    end

    test "invalid password", %{user: user} do
      assert {:error, :invalid_password} = Auth.authenticate(user.email, "invalidpass")
    end

    test "user not found" do
      assert {:error, :not_found} = Auth.authenticate("john@doe.com", "john123")
    end
  end
end
