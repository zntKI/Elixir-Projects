defmodule MyApp.Chapter2.String do
  def connect(first_word, second_word) do
    first_word <> second_word
  end

  def connect_with(first_word, second_word, separator) do
    first_word <> separator <> second_word
  end
end
