defmodule MyApp.Chapter2.Atom do
  def connect_to_atom(first_string, second_string) do
    String.to_atom(String.trim(first_string) <> "_" <> String.trim(second_string))
  end
end
