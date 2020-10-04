defmodule SakaVault.EncryptionKeys do
  @moduledoc false

  def get_keys do
    :sakavault
    |> Application.get_env(__MODULE__)
    |> Keyword.get(:keys)
    |> String.split(",")
    |> Enum.map(&:base64.decode/1)
  end
end
