defmodule App do
  def start() do
    GenServer.start(Account, [], name: Account)
    GenServer.start(Messaging, [], name: Messaging)
  end

  # Account funcs

  def get_state_account() do
    GenServer.call(Account, :get_state)
  end

  def register(username, email, password) do
    GenServer.call(
      Account,
      {:register, {{:username, username}, {:email, email}, {:password, password}}}
    )
  end

  def login(username, password) do
    GenServer.call(
      Account,
      {:login, {{:username, username}, {:password, password}}}
    )
  end

  def logout(username) do
    GenServer.call(
      Account,
      {:logout, {:username, username}}
    )
  end

  def send_invitation(sender, receiver) do
    GenServer.call(
      Account,
      {:invite, {{:sender, sender}, {:receiver, receiver}}}
    )
  end

  def list_all_invites(username) do
    GenServer.call(
      Account,
      {:list_all, {:username, username}}
    )
  end

  def handle_invite(username, username_to_handle, action) do
    GenServer.call(
      Account,
      {:handle_action,
       {{:username, username}, {:user_handle, username_to_handle}, {:action, action}}}
    )
  end

  def are_friends(user_1, user_2) do
    GenServer.call(
      Account,
      {:are_friends, {{:user_1, user_1}, {:user_2, user_2}}}
    )
  end

  # Messaging funcs

  def get_state_messaging() do
    GenServer.call(Messaging, :get_state)
  end

  def add_user(username) do
    GenServer.cast(Messaging, {:add_user, username})
  end

  def add_friend(username, username_to_add) do
    GenServer.cast(Messaging, {:add_friend, {:user, username}, {:user_to_add, username_to_add}})
  end

  def send_message(sender, receiver, message) do
    GenServer.call(
      Messaging,
      {:send, {{:sender, sender}, {:receiver, receiver}, {:message, message}}}
    )
  end

  def remove_message(sender, receiver, message) do
    GenServer.call(
      Messaging,
      {:remove, {{:sender, sender}, {:receiver, receiver}, {:message, message}}}
    )
  end

  def edit_message(sender, receiver, old_message, new_message) do
    GenServer.call(
      Messaging,
      {:edit,
       {{:sender, sender}, {:receiver, receiver}, {:old_message, old_message},
        {:new_message, new_message}}}
    )
  end

  def list_unread(receiver, sender \\ nil) do
    GenServer.call(
      Messaging,
      {:list_unread, {{:receiver, receiver}, {:sender, sender}}}
    )
  end
end
