defmodule SakaVaultWeb.AuthView do
  use SakaVaultWeb, :view

  def render("auth.json", %{auth: auth}), do: auth
end
