defmodule Messaging do
  @moduledoc """
  GenServer holding data for user's accounts
  """

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
                          sender_id = get_sender_id(map)

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
              sender_id = get_sender_id(map)

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
             {:error,
              "either such message doesn't exist or it has been already read by the user"}, state}
          else
            new_state =
              Enum.map(state, fn
                %Messaging{user_id: id, messages: messages_from_all} = new_user ->
                  if id == receiver do
                    %Messaging{
                      user_receiver
                      | messages:
                          Enum.map(messages_from_all, fn map = new_msgs ->
                            sender_id = get_sender_id(map)

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
  def handle_call(
        {:edit,
         {{:sender, sender}, {:receiver, receiver}, {:old_message, old_message},
          {:new_message, new_message}}},
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
              sender_id = get_sender_id(map)

              if sender_id == user_sender.user_id do
                Enum.any?(map[sender_id], fn %{
                                               content: content,
                                               edited: _edited,
                                               status: _status,
                                               time: time
                                             } ->
                  content == old_message and Time.diff(Time.utc_now(), time) <= 60
                end)
              end
            end)

          if contains_message == false do
            {:reply,
             {:error,
              "either such message doesn't exist or it has been already a minute since the message has been posted by the user"},
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
                            sender_id = get_sender_id(map)

                            if sender_id == sender do
                              after_removal =
                                Enum.map(map[sender_id], fn %{
                                                              content: content,
                                                              status: _status,
                                                              time: _time,
                                                              edited: _is_edited
                                                            } = map ->
                                  if content == old_message do
                                    %{map | content: new_message, edited: true}
                                  else
                                    map
                                  end
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

            {:reply, {:succes, "successfully edited message sent to #{receiver}"}, new_state}
          end
        end
    end
  end

  @impl true
  def handle_call({:list_unread, {{:receiver, receiver}, {:sender, sender}}}, _from, state) do
    user_receiver = find_user(state, receiver)

    cond do
      user_receiver == nil ->
        {:reply, {:error, "No such receiver"}, state}

      sender == nil ->
        user = find_user(state, receiver)

        msgs =
          Enum.map(user.messages, fn map ->
            sender_id = get_sender_id(map)

            map[sender_id]
          end)

        filtered = filter_unread(msgs)

        {:reply, {:all_unread, filtered}, state}

      true ->
        user = find_user(state, sender)

        if user == nil do
          {:reply, {:error, "No such sender"}, state}
        else
          msgs =
            Enum.map(user_receiver.messages, fn map ->
              sender_id = get_sender_id(map)

              if sender_id == sender do
                map[sender_id]
              else
                []
              end
            end)

          filtered = filter_unread(msgs)

          {:reply, {:unread_from_user, "Uread messages from #{sender}", filtered}, state}
        end
    end
  end

  @impl true
  def handle_call({:total_unread, {:receiver, receiver}}, _from, state) do
    user_receiver = find_user(state, receiver)

    cond do
      user_receiver == nil ->
        {:reply, {:error, "No such receiver"}, state}

      true ->
        user = find_user(state, receiver)

        msgs =
          Enum.map(user.messages, fn map ->
            sender_id = get_sender_id(map)

            map[sender_id]
          end)

        filtered = filter_unread(msgs)

        {:reply, {:total_unread, Enum.count(filtered)}, state}
    end
  end

  @impl true
  def handle_call(
        {:remove_friend, {{:username_1, username_1}, {:username_2, username_2}}},
        _from,
        state
      ) do
    user_1 = find_user(state, username_1)

    cond do
      user_1 == nil ->
        {:reply, {:error, "such user doesn't exist"}, state}

      true ->
        user_2 = find_user(state, username_2)

        if user_2 == nil do
          {:reply, {:error, "such user doesn't exist"}, state}
        else
          new_state =
            Enum.map(state, fn %Messaging{user_id: user_id} = user_map ->
              cond do
                username_1 == user_id ->
                  %Messaging{
                    user_1
                    | messages:
                        Enum.filter(user_1.messages, fn map ->
                          sender_id = get_sender_id(map)

                          sender_id != username_2
                        end)
                  }

                username_2 == user_id ->
                  %Messaging{
                    user_2
                    | messages:
                        Enum.filter(user_2.messages, fn map ->
                          sender_id = get_sender_id(map)

                          sender_id != username_1
                        end)
                  }

                true ->
                  user_map
              end
            end)

          {:reply,
           {:success,
            "successfully removed user #{username_2} from the friendlist of user #{username_1}",
            "successfully removed user #{username_1} from the friendlist of user #{username_2}"},
           new_state}
        end
    end
  end

  def handle_call(
        {:list_chat, {{:username_1, username_1}, {:username_2, username_2}}},
        _from,
        state
      ) do
    user_1 = find_user(state, username_1)
    user_2 = find_user(state, username_2)

    cond do
      user_1 == nil ->
        {:reply, {:error, "such user doesn't exist"}, state}

      user_2 == nil ->
        {:reply, {:error, "such user doesn't exist"}, state}

      true ->
        are_friends = App.are_friends(user_1, user_2)

        if are_friends == false do
          {:reply, {:error, "users are not friends"}, state}
        else
          map_first =
            Enum.find(user_1.messages, fn map ->
              sender_id = get_sender_id(map)

              sender_id == username_2
            end)

          msgs_first = map_first[username_2]

          map_second =
            Enum.find(user_2.messages, fn map ->
              sender_id = get_sender_id(map)

              sender_id == username_1
            end)

          msgs_second = map_second[username_1]

          unsorted_list = msgs_first ++ msgs_second

          final_list =
            Enum.sort_by(unsorted_list, fn %{
                                             content: _content,
                                             status: _status,
                                             time: time,
                                             edited: _is_edited
                                           } ->
              time
            end)

          {:reply,
           {:chat,
            Enum.map(final_list, fn %{
                                      content: content,
                                      status: _status,
                                      time: _time,
                                      edited: _is_edited
                                    } ->
              content
            end)}, state}
        end
    end
  end

  def get_sender_id(map) do
    map
    |> Map.keys()
    |> List.first()
  end

  def filter_unread(msgs) do
    msgs
    |> List.flatten()
    |> Enum.filter(fn %{content: _content, edited: _edited, status: status, time: _time} ->
      status == "unread"
    end)
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
