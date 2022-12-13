defmodule Account do
  use GenServer

  defstruct [:id, :username, :email, :password, :is_logged_in]

  def start() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
    # IO.inspect("Login: *Account.login(*username*, *email*, *password*)*")
  end

  def register(username, email, password) do
    GenServer.cast(
      __MODULE__,
      {:register, {{:username, username}, {:email, email}, {:password, password}}}
    )
  end

  def login(id, password) do
    GenServer.call(
      __MODULE__,
      {:login, {{:id, id}, {:password, password}}}
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
  def handle_call({:login, {{:id, u_id}, {:password, u_password}}}, _from, state) do
    user =
      Enum.find(state, fn %{
                            id: id,
                            username: _name,
                            email: _mail,
                            password: _pass,
                            is_logged_in: _status
                          } ->
        id == u_id
      end)

    if user == nil do
      {:reply, {:error, "no such user"}, state}
    else
      if user.password == u_password do
        new_state =
          Enum.map(state, fn
            %Account{id: id} = new_user ->
              if id == user.id do
                %Account{new_user | is_logged_in: true}
              else
                new_user
              end
          end)

        {:reply, {:success, "you have logged in"}, new_state}
      end
    end
  end

  @impl true
  def handle_cast(
        {:register, {{:username, username}, {:email, email}, {:password, password}}},
        state
      ) do
    {:noreply,
     [
       %Account{
         id: "\#{username}##\{1234\}",
         username: username,
         email: email,
         password: password,
         is_logged_in: false
       }
       | state
     ]}
  end
end
