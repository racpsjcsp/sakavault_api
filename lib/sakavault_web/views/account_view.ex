defmodule SakaVaultWeb.AccountView do
  use SakaVaultWeb, :view

  def render("account.json", %{user: user}) do
    Map.take(user, [:id, :name, :email])
  end
end
