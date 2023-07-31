defmodule TwitchApi.Client do
  @moduledoc """
  The Twitch API Client
  """
  
  alias TwitchApi.Auth
  alias TwitchApi.EventSub
  alias TwitchApi.Helix

  ###########################
  # Auth
  ###########################

  defdelegate get_app_access_token!(client_id, client_secret), to: Auth
  defdelegate get_user_access_token!(access_token), to: Auth

  ###########################
  # EventSub
  ###########################

  defdelegate listen_to_follows(client_id, app_access_token, callback_url, secret, channel), to: EventSub
  defdelegate listen_to_subscriptions(client_id, app_access_token, callback_url, secret, channel), to: EventSub
  defdelegate listen_to_stream_online(client_id, app_access_token, callback_url, secret, channel), to: EventSub
  defdelegate listen_to_stream_offline(client_id, app_access_token, callback_url, secret, channel), to: EventSub
  defdelegate listen_to_channel_points_used(client_id, app_access_token, callback_url, secret, channel), to: EventSub
  defdelegate stop_listening(client_id, app_access_token, subscription_id), to: EventSub
  defdelegate list_event_subs(client_id, app_access_token, cursor), to: EventSub
  defdelegate stop_listening_to_event_subs_for_uninstalled_channels(client_id, token, after_stop_listening_closure, cursor), to: EventSub

  ###########################
  # Helix
  ###########################
  defdelegate get_user_image_by_user_id!(client_id, app_access_token, user_id), to: Helix
  defdelegate get_username_by_user_id!(client_id, app_access_token, user_id), to: Helix
  defdelegate get_user_info_by_user_id!(client_id, app_access_token, user_id), to: Helix
  defdelegate is_banned_for_channel?(client_id, user_access_token, channel, user_id), to: Helix
  defdelegate is_live?(client_id, app_access_token, user_id), to: Helix
  defdelegate create_channel_points_custom_reward(client_id, user_access_token, user_id, title, cost), to: Helix
  defdelegate is_installed?(client_id, access_token), to: Helix
  defdelegate is_installed?(client_id, app_access_token, user_id), to: Helix
  defdelegate list_streamers(client_id, app_access_token, page_size, cursor), to: Helix

end
