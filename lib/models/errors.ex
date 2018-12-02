defmodule U2FEx.Errors do
  @moduledoc false
  @spec get_retval_from_error(number()) ::
          {:error,
           :u2f_other_error
           | :u2f_bad_request
           | :u2f_configuration_unsupported
           | :u2f_device_ineligible
           | :u2f_timeout}
  def get_retval_from_error(error_code) when is_number(error_code) do
    case error_code do
      1 -> {:error, :u2f_other_error}
      2 -> {:error, :u2f_bad_request}
      3 -> {:error, :u2f_configuration_unsupported}
      4 -> {:error, :u2f_device_ineligible}
      5 -> {:error, :u2f_timeout}
    end
  end
end
