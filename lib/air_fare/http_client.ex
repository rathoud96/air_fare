defmodule AireFare.HTTPClient do
  @moduledoc """
  Wrapper module to implement API calls
  """

  @doc """
  Function to make HTTP GET call
  """

  def get(url) do
    HTTPoison.get!(url)
    |> Map.get(:body)
  end
end
