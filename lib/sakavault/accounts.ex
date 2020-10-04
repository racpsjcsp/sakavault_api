defmodule SakaVault.Accounts do
  @moduledoc false

  alias SakaVault.Accounts.User
  alias SakaVault.Repo

  def find(id) do
    {:ok, Repo.get(User, id)}
  end

  def find_by_email(email) do
    {:ok, Repo.get_by(User, email_hash: email)}
  end

  def create(attrs \\ %{}) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end
end
