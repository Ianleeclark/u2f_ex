defmodule U2FEx.PKIStorageBehaviour do
  @type b64_string :: String.t()

  @doc """
  """
  @callback list_key_handles_for_user(user_id :: any()) ::
              {:ok,
               [
                 %{
                   required(:version) => String.t(),
                   required(:key_handle) => b64_string(),
                   optional(:app_id) => String.t(),
                   optional(:transports) => [map]
                 }
               ]}

  @doc """
  """
  @callback get_public_key_for_user(user_id :: any(), key_handle :: b64_string()) :: b64_string()
end
