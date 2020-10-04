defmodule SakaVaultWeb.AuthController do
  use SakaVaultWeb, :controller

  alias SakaVault.{Accounts, Auth}

  action_fallback SakaVaultWeb.FallbackController

  def login(conn, params) do
    with {email, password} <- get_credentials(params),
         {:ok, auth} <- Auth.authenticate(email, password) do
      conn
      |> put_status(:created)
      |> render("auth.json", auth: auth)
    end
  end

  def register(conn, params) do
    with {:ok, user} <- Accounts.create(params),
         {:ok, auth} <- Auth.authenticate(user) do
      conn
      |> put_status(:created)
      |> render("auth.json", auth: auth)
    end
  end

  defp get_credentials(%{"email" => email, "password" => password}) do
    {email, password}
  end
end
