defmodule TwitchApi.EventSub do
  @moduledoc """
  Documentation for Twitch EventSub

  You can test all your subscriptions using:
  https://github.com/twitchdev/twitch-cli/blob/main/docs/event.md#verify-subscription
  """

  @doc """
  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelfollow
  """
  def listen_to_follows(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "channel.follow")
  end

  def stop_listening_to_follows(client_id, app_access_token, subscription_id) do
    stop_listening(client_id, app_access_token, subscription_id)
  end

  @doc """
  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#channelsubscribe
  Scopes required: channel:read:subscriptions

  Test using the twitch cli:
  `twitch event verify-subscription subscribe -F https://localhost:4001/webhooks/listen-to-subscriptions`
  """
  def listen_to_subscriptions(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "channel.subscribe")
  end

  def stop_listening_to_subscriptions(client_id, app_access_token, subscription_id) do
    stop_listening(client_id, app_access_token, subscription_id)
  end

  @doc """
  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#streamonline
  """
  def listen_to_stream_online(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "stream.online")
  end

  def stop_listening_to_stream_online(client_id, app_access_token, subscription_id) do
    stop_listening(client_id, app_access_token, subscription_id)
  end

  @doc """
  https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#streamoffline
  """
  def listen_to_stream_offline(client_id, app_access_token, callback_url, secret, channel) do
    listen(client_id, app_access_token, callback_url, secret, channel, "stream.offline")
  end

  def stop_listening_to_stream_offline(client_id, app_access_token, subscription_id) do
    stop_listening(client_id, app_access_token, subscription_id)
  end

  @doc """
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

  def stop_listening_to_channel_points_used(client_id, app_access_token, subscription_id) do
    stop_listening(client_id, app_access_token, subscription_id)
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

  defp stop_listening(client_id, app_access_token, subscription_id) do
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
