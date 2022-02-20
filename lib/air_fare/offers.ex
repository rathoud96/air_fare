defmodule AirFare.Offers do
  @moduledoc """
  Contains logic of parsing the data and getting the cheapest offer
  """

  require Logger

  import SweetXml

  alias AireFare.HTTPClient

  def get_cheapest_offer(_args) do
    ba_airport_fare = Task.Supervisor.async_nolink(__MODULE__, fn -> get_ba_offer_price() end)

    afklm_airport_dare =
      Task.Supervisor.async_nolink(__MODULE__, fn -> get_afklm_offer_price() end)

    data = %{
      ba_lowest_fare: Task.await(ba_airport_fare),
      afklm_lowest_fare: Task.await(afklm_airport_dare)
    }

    cheapest_offer =
      if data[:ba_lowest_fare] < data[:afklm_lowest_fare] do
        %{amount: to_float(data[:ba_lowest_fare]), airline: "BA"}
      else
        %{amount: to_float(data[:afklm_lowest_fare]), airline: "AFKL"}
      end

    %{cheapestOffer: cheapest_offer}
  end

  defp get_ba_offer_price do
    url =
      "https://gist.githubusercontent.com/kanmaniselvan/bb11edf031e254977b210c480a0bd89a/raw/ea9bcb65ba4bb2304580d6202ece88aee38540f8/ba_response_sample.xml"

    url |> HTTPClient.get() |> xpath(~x"//TotalPrice/SimpleCurrencyPrice/text()"l) |> Enum.min()
  end

  defp get_afklm_offer_price do
    url =
      "https://gist.githubusercontent.com/kanmaniselvan/bb11edf031e254977b210c480a0bd89a/raw/ea9bcb65ba4bb2304580d6202ece88aee38540f8/afklm_response_sample.xml"

    url
    |> HTTPClient.get()
    |> xpath(~x"//ns2:FarePriceType/ns2:Price/ns2:TotalAmount/text()"l)
    |> Enum.min()
  end

  ## convert charlist to float
  defp to_float(data) do
    data |> to_string() |> String.to_float()
  end
end
