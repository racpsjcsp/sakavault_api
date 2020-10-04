defmodule SakaVault.Fields.Encrypted do
  @moduledoc false
  @behaviour Ecto.Type

  alias SakaVault.AES

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    cipher_text = value |> to_string |> AES.encrypt()

    {:ok, cipher_text}
  end

  def load(value) do
    {:ok, AES.decrypt(value)}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2
end
