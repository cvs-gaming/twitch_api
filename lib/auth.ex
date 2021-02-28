defmodule TwitchApi.Auth do
  @moduledoc """
  Documentation for Twitch authentication.
  """

  @doc """
  Get the app access token (https://dev.twitch.tv/docs/authentication#types-of-tokens)
  The app access tokens expires in 60 days
  The client id and secret are app specific and can be found in the twitch development dashboard

  Example:
  {:ok, %{"access_token" => access_token, "token_type" => token_type, "expires_in" => expires_in}} = get_app_access_token!(client_id, client_secret)
  """
  def get_app_access_token!(client_id, client_secret) do
    # Get a new one
    HTTPoison.start()

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    body = "&grant_type=client_credentials&client_id=#{client_id}&client_secret=#{client_secret}"

    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post("https://id.twitch.tv/oauth2/token", body, headers)

    {:ok, Jason.decode!(body)}
  end

  @doc """

  Getting a user_access_token used requires some front-end logic.
  1: Add a link to your app - https://id.twitch.tv/oauth2/authorize?client_id=XX&redirect_uri=XX&response_type=token&scope=XX
  2: The user will authorize there
  3: Twitch will call the redirect_uri
  Example:
  def authorize(conn, %{"access_token" => access_token})
     {:ok, %{
       "client_id": _,
       "login": _,
       "scopes": [
         "chat:read",
         "moderation:read"
       ],
       "user_id": _,
       "expires_in": _,
    }} = get_user_access_token!(access_token)
  end
  """
  def get_user_access_token!(access_token) do
    HTTPoison.start()

    headers = [
      {"Authorization", "OAuth #{access_token}"}
    ]

    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get("https://id.twitch.tv/oauth2/validate", headers)

    {:ok, Jason.decode!(body)}
  end
end
