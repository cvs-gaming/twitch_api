defmodule TwitchApi.EventSub do
  @moduledoc """
  Start using Twitch EventSub

  You can test all your subscriptions using:

  https://github.com/twitchdev/twitch-cli/blob/main/docs/event.md#verify-subscription
  """

  @doc """
  Start listening to follows

  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelfollow
  """
  def listen_to_follows(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "channel.follow")
  end

  @doc """
  Start listening to subscriptions

  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelsubscribe

  Scopes required: channel:read:subscriptions

  Test using the twitch cli:
  `twitch event verify-subscription subscribe -F https://localhost:4001/webhooks/listen-to-subscriptions`
  """
  def listen_to_subscriptions(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "channel.subscribe")
  end

  @doc """
  Start listening to when the streamer comes online

  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#streamonline
  """
  def listen_to_stream_online(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "stream.online")
  end

  @doc """
  Start listening to when the streamer goes offline

  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#streamoffline
  """
  def listen_to_stream_offline(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "stream.offline")
  end

  @doc """
  Start listening to channel points usage

  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelchannel_points_custom_reward_redemptionadd

  Scopes required: channel:read:redemptions or channel:manage:redemptions
  """
  def listen_to_channel_points_used(client_id, app_access_token, callback_url, secret, channel) do
    listen(
      client_id,
      app_access_token,
      callback_url,
      secret,
      channel,
      "channel.channel_points_custom_reward_redemption.add"
    )
  end

  defp listen(client_id, app_access_token, callback_url, secret, channel, type) when is_bitstring(channel) do
    HTTPoison.start()

    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    body = %{
      type: type,
      version: "1",
      condition: %{
        broadcaster_user_id: channel
      },
      transport: %{
        method: "webhook",
        callback: callback_url,
        secret: secret,
      }
    }

    case HTTPoison.post("https://api.twitch.tv/helix/eventsub/subscriptions", Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, Jason.decode!(body)}
      nil -> {:error, "Something went wrong. Are you already listening to this EventSub?"}
    end
  end

  @doc """
  Stop listening to certain events
  """
  def stop_listening(client_id, app_access_token, subscription_id) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    HTTPoison.delete(
      "https://api.twitch.tv/helix/eventsub/subscriptions?id=#{subscription_id}",
      headers
    )
  end

  @doc """
  List all event sub listeners

  There is a maximum, so make sure to stop listening at some point
  """
  def list_event_subs(client_id, app_access_token) do
    HTTPoison.start()

    headers = [
      {"Client-ID", client_id},
      {"Authorization", "Bearer #{app_access_token}"}
    ]

    case HTTPoison.get("https://api.twitch.tv/helix/eventsub/subscriptions", headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, Jason.decode!(body)}
      _ ->
        {:error, "Something went wrong."}
    end
  end
end
