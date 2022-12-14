defmodule Account do
  use GenServer

  defstruct [:id, :username, :email, :password, :is_logged_in, :invitations, :friendlist]

  def start() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def register(username, email, password) do
    GenServer.call(
      __MODULE__,
      {:register, {{:username, username}, {:email, email}, {:password, password}}}
    )
  end

  def login(username, password) do
    GenServer.call(
      __MODULE__,
      {:login, {{:username, username}, {:password, password}}}
    )
  end

  def logout(username) do
    GenServer.call(
      __MODULE__,
      {:logout, {:username, username}}
    )
  end

  def send_invitation(sender, receiver) do
    GenServer.call(
      __MODULE__,
      {:invite, {{:sender, sender}, {:receiver, receiver}}}
    )
  end

  def list_all_invites(username) do
    GenServer.call(
      __MODULE__,
      {:list_all, {:username, username}}
    )
  end

  def handle_invite(username, username_to_handle, action) do
    GenServer.call(
      __MODULE__,
      {:handle_action,
       {{:username, username}, {:user_handle, username_to_handle}, {:action, action}}}
    )
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @impl true
  def init(_state) do
    IO.inspect("Register: *Account.register(*username*, *email*, *password*)*")
    {:ok, []}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:all_users, state}, state}
  end

  @impl true
  def handle_call({:login, {{:username, username}, {:password, u_password}}}, _from, state) do
    user = find_user(state, username)

    if user == nil do
      {:reply, {:error, "no such user"}, state}
    else
      if user.password == u_password do
        new_state = user_is_logged_in(state, user, true)

        {:reply, {:success, "you have logged in"}, new_state}
      else
        {:reply, {:error, "wrong password"}, state}
      end
    end
  end

  @impl true
  def handle_call(
        {:register, {{:username, username}, {:email, email}, {:password, password}}},
        _from,
        state
      ) do
    user = find_user(state, username)

    if user != nil do
      {:reply, {:error, "such account already exists"}, state}
    else
      {:reply, {:success, "successfully registered"},
       [
         %Account{
           id: username,
           username: username,
           email: email,
           password: password,
           is_logged_in: false,
           invitations: [],
           friendlist: []
         }
         | state
       ]}
    end
  end

  @impl true
  def handle_call({:logout, {:username, username}}, _from, state) do
    user = find_user(state, username)

    if user == nil do
      {:reply, {:error, "such user doesn't exist"}, state}
    else
      new_state = user_is_logged_in(state, user, false)

      {:reply, {:success, "you have logged out"}, new_state}
    end
  end

  @impl true
  def handle_call({:invite, {{:sender, sender}, {:receiver, receiver}}}, _from, state) do
    user_sender = find_user(state, sender)
    user_receiver = find_user(state, receiver)

    cond do
      user_sender == nil ->
        {:reply, {:error, "such sender doesn't exist"}, state}

      user_receiver == nil ->
        {:reply, {:error, "such receiver doesn't exist"}, state}

      user_sender.is_logged_in == false ->
        {:reply, {:error, "the sender isn't logged in"}, state}

      true ->
        # TODO: User should be logged in to make use of this action
        friend = Enum.find(user_receiver.friendlist, fn fr -> fr == user_sender.id end)

        if friend != nil do
          {:reply, {:error, "user: #{user_sender.id} is already friend to #{user_receiver.id}"},
           state}
        else
          invitation =
            Enum.find(
              user_receiver.invitations,
              fn sender_id ->
                sender_id == user_sender.id
              end
            )

          if invitation != nil do
            {:reply, {:error, "there is already such an invite"}, state}
          else
            new_state =
              Enum.map(state, fn
                %Account{id: id} = new_user ->
                  if id == user_receiver.id do
                    %Account{
                      user_receiver
                      | invitations: [user_sender.id | user_receiver.invitations]
                    }
                  else
                    new_user
                  end
              end)

            {:reply, {:success, "successfully sent the invitation"}, new_state}
          end
        end
    end
  end

  @impl true
  def handle_call({:list_all, {:username, username}}, _from, state) do
    user = find_user(state, username)

    if user == nil do
      {:reply, {:error, "such user doesn't exist"}, state}
    else
      {:reply, {:success, user.invitations}, state}
    end
  end

  @impl true
  def handle_call(
        {:handle_action,
         {{:username, username}, {:user_handle, username_to_handle}, {:action, action}}},
        _from,
        state
      ) do
    user = find_user(state, username)

    if user == nil do
      {:reply, {:error, "such user doesn't exist"}, state}
    else
      invitation = find_invitation(user, username_to_handle)

      case invitation do
        nil ->
          {:reply, {:error, "there isn't a invite from such user"}, state}

        _ ->
          deleted_invite_state =
            Enum.map(state, fn
              %Account{id: id} = new_user ->
                if id == user.id do
                  %Account{
                    user
                    | invitations: List.delete(user.invitations, username_to_handle)
                  }
                else
                  new_user
                end
            end)

          if action == "accept" do
            new_state =
              Enum.map(deleted_invite_state, fn
                %Account{id: id} = new_user ->
                  if id == user.id do
                    %Account{
                      user
                      | friendlist: [username_to_handle | user.friendlist],
                        invitations: List.delete(user.invitations, username_to_handle)
                    }
                  else
                    new_user
                  end
              end)

            {:reply,
             {:success, "successfully accepted the invitation from #{username_to_handle}"},
             new_state}
          else
            if action != "decline" do
              {:reply, "no such action accessable: #{action}", state}
            else
              {:reply,
               {:success, "successfully declined the invitation from #{username_to_handle}"},
               deleted_invite_state}
            end
          end
      end
    end
  end

  def find_invitation(user_receiver, user_sender) do
    Enum.find(
      user_receiver.invitations,
      fn sender_id ->
        sender_id == user_sender
      end
    )
  end

  def find_user(state, username) do
    Enum.find(state, fn %{
                          id: id,
                          username: _name,
                          email: _mail,
                          password: _pass,
                          is_logged_in: _status
                        } ->
      id == username
    end)
  end

  def user_is_logged_in(state, user, bool) do
    Enum.map(state, fn
      %Account{id: id} = new_user ->
        if id == user.id do
          %Account{new_user | is_logged_in: bool}
        else
          new_user
        end
    end)
  end
end
