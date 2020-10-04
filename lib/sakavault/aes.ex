defmodule SakaVault.AES do
  @moduledoc false

  # Use AES 256 Bit Keys for Encryption.
  @aad "AES256GCM"

  def encrypt(plain_text) do
    # create random Initialisation Vector
    initial_vector = :crypto.strong_rand_bytes(16)

    # get the *latest* key in the list of encryption keys
    key = get_key()

    # get the *latest* key id in the list of encryption keys
    key_id = get_key_id()

    {cipher, tag} =
      :crypto.block_encrypt(
        :aes_gcm,
        key,
        initial_vector,
        {@aad, to_string(plain_text), 16}
      )

    initial_vector <> tag <> <<key_id::unsigned-big-integer-32>> <> cipher
  end

  def decrypt(cipher_text) do
    <<
      initial_vector::binary-16,
      tag::binary-16,
      key_id::unsigned-big-integer-32,
      cipher_text::binary
    >> = cipher_text

    :crypto.block_decrypt(:aes_gcm, get_key(key_id), initial_vector, {@aad, cipher_text, tag})
  end

  defp get_key, do: get_key_id() |> get_key()

  defp get_key(key_id), do: encryption_keys() |> Enum.at(key_id)

  defp get_key_id, do: Enum.count(encryption_keys()) - 1

  defp encryption_keys, do: SakaVault.EncryptionKeys.get_keys()
end
