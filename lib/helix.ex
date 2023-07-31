defmodule TwitchApi.Helix do
  @moduledoc """
  The Twitch API

  Twitch API version: Helix
  """

  @doc """
  Get the user's profile image by their user id (channel)
  """
  def get_user_image_by_user_id!(client_id, app_access_token, user_id) do
    {:ok, %{"data" => [%{"profile_image_url" => image}]}} =
      get_user_info_by_user_id!(
        client_id,
        app_access_token,
        user_id
      )

    image
  end

  @doc """
  Get the username by their user id (channel)
  """
  def get_username_by_user_id!(client_id, app_access_token, user_id) do
    {:ok, %{"data" => [%{"display_name" => display_name}]}} =
      get_user_info_by_user_id!(
        client_id,
        app_access_token,
        user_id
      )

    display_name
  end

  @doc """
  Get information about the user by their id (channel)

  ```
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
  ```
  """
  def get_user_info_by_user_id!(client_id, app_access_token, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-Id", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
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
  def is_banned_for_channel?(client_id, user_access_token, channel, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{user_access_token}"}
    ]

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        "https://api.twitch.tv/helix/moderation/banned?broadcaster_id=#{channel}&user_id=#{
          user_id
        }",
        headers
      )

    # If the result is empty, the user is not banned
    case Jason.decode!(body) do
      %{"data" => []} -> false
      _ -> true
    end
  end

  @doc """
  Is the user or streamer live?
  """
  def is_live?(client_id, app_access_token, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-Id", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    response =
      HTTPoison.get(
        "https://api.twitch.tv/helix/streams?user_id=#{user_id}",
        headers
      )

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Jason.decode!(body) do
          %{"data" => [%{"type" => "live"}]} ->
            true

          _ ->
            false
        end

      _ ->
        false
    end
  end

  @doc """
  Create a channel points icon on a channel
  """
  def create_channel_points_custom_reward(client_id, user_access_token, user_id, title, cost)
      when is_bitstring(cost) do
    headers = [
      {"Content-Type", "application/json"},
      {"Client-Id", client_id},
      {"Authorization", "Bearer #{user_access_token}"}
    ]

    body = %{
      title: title,
      cost: cost
    }

    case HTTPoison.post(
           "https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=#{user_id}",
           Jason.encode!(body),
           headers
         ) do
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, Jason.decode!(body)}
      nil -> {:error, "Something went wrong."}
    end
  end

  @doc """
  Check whether the extension is installed for a user
  Using the user access token directly
  """
  def is_installed?(client_id, access_token) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{access_token}"}
    ]

    url = "https://api.twitch.tv/helix/users/extensions"

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Jason.decode!(body) do
          %{"data" => data} ->
            data
            |> Enum.to_list()
            |> Enum.any?(
                 fn {_name, apps} ->
                   Enum.any?(
                     apps,
                     fn {_key, values} ->
                       case values do
                         %{"id" => id} -> id == client_id
                         _ -> false
                       end
                     end
                   )
                 end
               )
          _ ->
            {:error, "Something went wrong."}
        end
      _ ->
        {:error, "Something went wrong."}
    end
  end

  @doc """
  Check whether the extension is installed for a user
  Using the extensions app_access_token
  """
  def is_installed?(client_id, app_access_token, user_id) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    url = "https://api.twitch.tv/helix/users/extensions?user_id=#{user_id}"

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Jason.decode!(body) do
          %{"data" => data} ->
            data
            |> Enum.to_list()
            |> Enum.any?(
                 fn {_name, apps} ->
                   Enum.any?(
                     apps,
                     fn {_key, values} ->
                       case values do
                         %{"id" => id} -> id == client_id
                         _ -> false
                       end
                     end
                   )
                 end
               )
          _ ->
            {:error, "Something went wrong."}
        end
      _ ->
        {:error, "Something went wrong."}
    end
  end

  @doc """
  List all live streams
  """
  def list_streamers(client_id, app_access_token, page_size \\ 10, cursor \\ nil) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    url = "https://api.twitch.tv/helix/streams?type=live&first=#{page_size}"

    url =
      case cursor do
        nil -> url
        _ -> "#{url}&after=#{cursor}"
      end

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        {:error, "Something went wrong."}
    end
  end
end
