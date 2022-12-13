defmodule MyApp.Processes.Pingpong do
  def process_a(receiver) do
    spawn(fn ->
      receive do
        {:ping, "ping"} -> send(receiver, {:pong, "pong"})
      end
    end)
  end
end
