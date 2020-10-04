defmodule SakaVault.Accounts.User do
  @moduledoc false

  use SakaVault.Schema

  alias SakaVault.Fields.{
    Encrypted,
    Hash,
    Password
  }

  schema "users" do
    field :name, Encrypted
    field :email, Encrypted
    field :email_hash, Hash

    field :password, :binary, virtual: true
    field :password_hash, Password

    timestamps()
  end

  def changeset(%__MODULE__{} = user, params) do
    user
    |> cast(params, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
    |> add_email_hash()
    |> add_password_hash()
    |> unique_constraint(:email_hash)
  end

  defp add_email_hash(%{changes: %{email: email}} = changeset) do
    put_change(changeset, :email_hash, email)
  end

  defp add_email_hash(changeset), do: changeset

  defp add_password_hash(%{changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, password)
  end

  defp add_password_hash(changeset), do: changeset
end
