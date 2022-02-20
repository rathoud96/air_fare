defmodule AirFareWeb.PageControllerTest do
  use AirFareWeb.ConnCase

  import Mock

  test "GET /findCheapestOffer gives cheapest offer", %{conn: conn} do
    with_mock AirFare.Offers,
      get_cheapest_offer: fn _arg -> %{cheapestOffer: %{airline: "BA", amount: 55.19}} end do
      conn =
        get(
          conn,
          Routes.page_path(conn, :find_cheapest_offer, %{
            origin: "BER",
            destination: "LHR",
            departureDate: "2019-07-17"
          })
        )

      response = conn |> json_response(200)
      assert !is_nil(response["data"])

      assert response == %{
               "data" => %{"cheapestOffer" => %{"airline" => "BA", "amount" => 55.19}}
             }
    end
  end

  test "GET /findCheapestOffer throws error for invalid params", %{conn: conn} do
    conn =
      get(
        conn,
        Routes.page_path(conn, :find_cheapest_offer, %{
          destination: "LHR",
          departureDate: "2019-07-17"
        })
      )

    response = conn |> json_response(400)
    assert response["message"] == "Invalid params"
  end
end
