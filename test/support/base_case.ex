defmodule SakaVault.BaseCase do
  @moduledoc false

  defmacro __using__(opts) do
    opts = Keyword.put_new(opts, :async, true)

    quote do
      use ExUnit.Case, unquote(opts)

      alias SakaVault.Repo

      alias Ecto.{
        Adapters.SQL.Sandbox,
        Changeset
      }

      import SakaVault.Support.Factories

      setup tags do
        pid = Sandbox.start_owner!(SakaVault.Repo, shared: not tags[:async])
        on_exit(fn -> Sandbox.stop_owner(pid) end)
        :ok
      end
    end
  end
end
