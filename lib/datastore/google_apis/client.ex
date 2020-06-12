defmodule Datastore.GoogleApis.Client do
  @moduledoc false

  use HTTPoison.Base

  def process_url(url) do
    base_url = Application.get_env(:straight_forward_vpn, StraightForwardVpn.Repo)[:url]
    base_url = "http://172.17.0.2:8081"
    base_url <> url
  end
end
