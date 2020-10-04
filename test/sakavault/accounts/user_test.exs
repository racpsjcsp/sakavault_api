defmodule SakaVault.Accounts.UserTest do
  use SakaVault.DataCase

  import Ecto.Query

  alias SakaVault.Accounts.User
  alias SakaVault.Fields.Hash

  @valid_attrs %{
    name: "Max",
    email: "max@example.com",
    password: "NoCarbsBeforeMarbs"
  }

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    assert %{valid?: true} = User.changeset(@valid_attrs)
  end

  test "changeset with invalid attributes" do
    assert %{valid?: false} = User.changeset(@invalid_attrs)
  end

  describe "Verify correct working of encryption and hashing" do
    setup do
      user =
        @valid_attrs
        |> User.changeset()
        |> Repo.insert!()

      {:ok, user: user, email: @valid_attrs.email}
    end

    test "inserting a user sets the :email_hash field", %{user: user} do
      assert user.email_hash == user.email
    end

    test ":email_hash field is the encrypted hash of the email", %{user: user} do
      loaded_user = Repo.one(User)

      assert loaded_user.email_hash == Hash.hash(user.email)
    end

    test "changeset validates uniqueness of email through email_hash" do
      {:error, %{errors: errors}} = Repo.insert(User.changeset(@valid_attrs))

      assert errors == [
               email_hash:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "users_email_hash_index"]}
             ]
    end

    test "can decrypt values of encrypted fields when loaded from database", %{user: user} do
      found_user = Repo.one(User)

      assert found_user.name == user.name
      assert found_user.email == user.email
    end

    test "User.get_by_email finds the user by their email address", %{user: user} do
      found_user = Repo.get_by(User, email_hash: user.email)

      assert found_user.email == user.email
      assert found_user.email_hash == Hash.hash(user.email)
    end

    test "cannot query on email field due to encryption not producing same value twice", %{
      user: user
    } do
      refute Repo.get_by(User, email: user.email)
    end

    test "can query on email_hash field because sha256 is deterministic", %{user: user} do
      assert %User{} = Repo.get_by(User, email_hash: user.email)

      assert %User{} = Repo.one(from(u in User, where: u.email_hash == ^user.email))
    end

    test "Key rotation: add a new encryption key", %{email: email} do
      original_keys = Application.get_env(:sakavault, SakaVault.EncryptionKeys)[:keys]

      # add a new key
      Application.put_env(:sakavault, SakaVault.EncryptionKeys,
        keys: "#{original_keys},#{:base64.encode(:crypto.strong_rand_bytes(32))}"
      )

      # find user encrypted with previous key
      assert %{email: ^email} = Repo.get_by(User, email_hash: email)

      %{name: "Frank", email: "frank@example.com", password: "frank123"}
      |> User.changeset()
      |> Repo.insert!()

      user = Repo.get_by(User, email_hash: "frank@example.com")

      assert user.email == "frank@example.com"
      assert user.name == "Frank"

      # rollback to the original keys
      Application.put_env(:sakavault, SakaVault.EncryptionKeys, keys: original_keys)
    end
  end
end
