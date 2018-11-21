defmodule Provider do
  @moduledoc false
  @spec list_key_handles_for_user(user_id :: any()) ::
          {:ok,
           [
             %{
               required(:version) => String.t(),
               required(:key_handle) => String.t(),
               optional(:transports) => [map()],
               optional(:app_id) => String.t()
             }
           ]}
  def list_key_handles_for_user(_user_id) do
    {:ok,
     [
       %{
         version: "U2F_V2",
         key_handle:
           "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
         app_id: "https://localhost"
       }
     ]}
  end

  @spec get_public_key_for_user(user_id :: any(), key_handle :: String.t()) ::
          {:ok, %{required(:key_handle) => String.t(), required(:public_key) => String.t()}}
  def get_public_key_for_user(_user_id, _key_handle) do
    {:ok,
     %{
       version: "U2F_V2",
       key_handle:
         "Uvo6wxNqPu4s7_fLKFsUA7hUFabwUsZE0oXz131QUggt8lHYKXCwAoqDfPtFkEC2AbXZXes48tfpwAe-oFaSSA",
       app_id: "https://localhost",
       public_key:
         "BD6itc6pGwof1pSaAFJKM9XO24_13PamI1wh3s_j3Dpj_SyMQdrN9dM582ttDd64jaKCpmj3JZ_J-bRn7x-V9Wc"
     }}
  end
end
