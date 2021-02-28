defmodule TwitchApi.Helix do
  @moduledoc """
  Documentation for the Twitch API.
  Twitch API version: Helix
  """

  @doc """
  Get the user's profile image by their user id (channel)
  """
  def get_user_image_by_user_id!(user_access_token, client_id, user_id) do
    {:ok, %{"data" => [%{"profile_image_url" => image}]}} = get_user_info_by_user_id!(
      user_access_token,
      client_id,
      user_id
    )

    image
  end

  @doc """
  Get the username by their user id (channel)
  """
  def get_username_by_user_id!(user_access_token, client_id, user_id) do
    {:ok, %{"data" => [%{"display_name" => display_name}]}} = get_user_info_by_user_id!(
      user_access_token,
      client_id,
      user_id
    )

    display_name
  end

  @doc """
  Get information about the user by their id (channel id)

  {
    :ok,
     %{
     "data" => [
       %{
         "broadcaster_type" => _,
         "created_at" => _,
         "description" => _,
         "display_name" => _,
         "email" => _,
         "id" => _,
         "login" => _,
         "offline_image_url" => _,
         "profile_image_url" => _,
         "type" => _,
         "view_count" => _,
       }
     ]
    }}
  }
  """
  def get_user_info_by_user_id!(user_access_token, client_id, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-Id", client_id},
      {"Authorization", "Bearer #{user_access_token}"}
    ]

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        "https://api.twitch.tv/helix/users?id=#{user_id}",
        headers
      )

    {:ok, Jason.decode!(body)}
  end

  @doc """
  Check whether this user is banned for a channel
  """
  def is_banned_for_channel?(user_access_token, client_id, channel, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{user_access_token}"}
    ]

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        "https://api.twitch.tv/helix/moderation/banned?broadcaster_id=#{channel}&user_id=#{user_id}",
        headers
      )

    # If the result is empty, the user is not banned
    case Jason.decode!(body) do
      %{"data" => []} -> false
      _ -> true
    end
  end
end
