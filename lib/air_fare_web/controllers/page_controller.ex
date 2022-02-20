defmodule AirFareWeb.PageController do
  use AirFareWeb, :controller

  import Ecto.Changeset

  alias AirFare.Offers

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def find_cheapest_offer(conn, params) do
    with {:ok, valid_params} <- validate_params(params) do
      response = Offers.get_cheapest_offer(valid_params)
      IO.inspect(response)

      conn
      |> put_status(200)
      |> json(%{data: response})
    else
      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> json(%{message: "Invalid params"})
    end
  end

  defp validate_params(params) do
    types = %{origin: :string, destination: :string, departureDate: :string}

    changeset =
      {%{}, types}
      |> cast(params, Map.keys(types))
      |> validate_required(Map.keys(types))

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
