defmodule Messaging do
  use GenServer

  defstruct [:user_id, :messages]

  @impl true
  def init(_state) do
    {:ok, []}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, {:state, state}, state}
  end

  @impl true
  def handle_call(
        {:send, {{:sender, sender}, {:receiver, receiver}, {:message, message}}},
        _from,
        state
      ) do
    user_sender = find_user(state, sender)
    user_receiver = find_user(state, receiver)

    cond do
      user_sender == nil ->
        {:reply, {:error, "such sender doesn't exist"}, state}

      user_receiver == nil ->
        {:reply, {:error, "such receiver doesn't exist"}, state}

      true ->
        are_friends = App.are_friends(user_sender, user_receiver)

        if are_friends == false do
          {:reply, {:error, "users are not friends"}, state}
        else
          new_state =
            Enum.map(state, fn
              %Messaging{user_id: id, messages: messages_from_all} = new_user ->
                if id == receiver do
                  %Messaging{
                    user_receiver
                    | messages:
                        Enum.map(messages_from_all, fn map = new_msgs ->
                          sender_id =
                            map
                            |> Map.keys()
                            |> List.first()

                          if sender_id == sender do
                            Map.update!(map, sender_id, fn msgs ->
                              [
                                %{
                                  content: message,
                                  status: "unread",
                                  time: Time.utc_now(),
                                  edited: false
                                }
                                | msgs
                              ]
                            end)
                          else
                            new_msgs
                          end
                        end)
                  }
                else
                  new_user
                end
            end)

          {:reply, {:succes, "successfully sent message to #{receiver}"}, new_state}
        end
    end
  end

  @impl true
  def handle_call(
        {:remove, {{:sender, sender}, {:receiver, receiver}, {:message, message}}},
        _from,
        state
      ) do
    user_sender = find_user(state, sender)
    user_receiver = find_user(state, receiver)

    cond do
      user_sender == nil ->
        {:reply, {:error, "such sender doesn't exist"}, state}

      user_receiver == nil ->
        {:reply, {:error, "such receiver doesn't exist"}, state}

      true ->
        are_friends = App.are_friends(user_sender, user_receiver)

        if are_friends == false do
          {:reply, {:error, "users are not friends"}, state}
        else
          contains_message =
            Enum.find(user_receiver.messages, false, fn map ->
              sender_id =
                map
                |> Map.keys()
                |> List.first()

              if sender_id == user_sender.user_id do
                Enum.any?(map[sender_id], fn %{
                                               content: content,
                                               edited: _edited,
                                               status: status,
                                               time: _time
                                             } ->
                  content == message and status == "unread"
                end)
              end
            end)

          if contains_message == false do
            {:reply,
             {:error, "either such message couldn't be found or it has been read by the user"},
             state}
          else
            new_state =
              Enum.map(state, fn
                %Messaging{user_id: id, messages: messages_from_all} = new_user ->
                  if id == receiver do
                    %Messaging{
                      user_receiver
                      | messages:
                          Enum.map(messages_from_all, fn map = new_msgs ->
                            sender_id =
                              map
                              |> Map.keys()
                              |> List.first()

                            if sender_id == sender do
                              after_removal =
                                Enum.filter(map[sender_id], fn %{
                                                                 content: content,
                                                                 status: _status,
                                                                 time: _time,
                                                                 edited: _is_edited
                                                               } ->
                                  message != content
                                end)

                              %{sender_id => after_removal}
                            else
                              new_msgs
                            end
                          end)
                    }
                  else
                    new_user
                  end
              end)

            {:reply, {:succes, "successfully removed message sent to #{receiver}"}, new_state}
          end
        end
    end
  end

  @impl true
  def handle_cast({:add_user, username}, state) do
    {:noreply,
     [
       %Messaging{
         user_id: username,
         messages: []
       }
       | state
     ]}
  end

  @impl true
  def handle_cast({:add_friend, {:user, username}, {:user_to_add, username_to_add}}, state) do
    user = find_user(state, username)
    user_to_add = find_user(state, username_to_add)

    new_state =
      Enum.map(state, fn
        %Messaging{user_id: id} = new_user ->
          if id == username do
            %Messaging{
              user
              | messages: [%{username_to_add => []} | user.messages]
            }
          else
            if id == username_to_add do
              %Messaging{
                user_to_add
                | messages: [%{username => []} | user_to_add.messages]
              }
            else
              new_user
            end
          end
      end)

    {:noreply, new_state}
  end

  def find_user(state, username) do
    Enum.find(state, fn %{
                          user_id: id,
                          messages: _messages
                        } ->
      id == username
    end)
  end
end
