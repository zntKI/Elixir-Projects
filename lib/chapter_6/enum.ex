defmodule MyApp.Chapter6.Enum do
  def get_all_nums(list) do
    Enum.filter(list, &is_integer(&1))
  end

  def scrable(list) do
    final_list =
      Enum.map(list, fn {name, words} ->
        final_points =
          Enum.reduce(words, 0, fn word, all_points ->
            list_word = String.graphemes(String.downcase(word))

            word_points =
              Enum.reduce(list_word, 0, fn char, acc ->
                cond do
                  char == " " -> acc
                  char in ["a", "e", "i", "l", "n", "o", "r", "s", "t", "u"] -> acc + 1
                  char in ["d", "g"] -> acc + 2
                  char in ["b", "c", "m", "p"] -> acc + 3
                  char in ["f", "h", "v", "w", "y"] -> acc + 4
                  char == "k" -> acc + 5
                  char in ["j", "x"] -> acc + 8
                  char in ["q", "z"] -> acc + 10
                  true -> acc
                end
              end)

            all_points + word_points
          end)

        {name, final_points}
      end)

    Enum.max_by(final_list, fn {_name, points} -> points end)
  end

  def is_pangram(text) do
    all_letters = "abcdefghijklmnopqrstuvwxyz"

    list =
      text
      |> String.downcase()
      |> String.graphemes()
      |> Enum.filter(fn letter -> letter != " " end)
      |> Enum.reduce([], fn char, acc ->
        if String.contains?(text, char) do
          [char | acc]
        else
          acc
        end
      end)

    text_letters =
      Enum.uniq(list)
      |> Enum.sort()
      |> List.to_string()

    text_letters == all_letters
  end

  def rot13(text) do
    first = %{
      one: "a",
      two: "b",
      three: "c",
      four: "d",
      five: "e",
      six: "f",
      seven: "g",
      eight: "h",
      nine: "i",
      ten: "j",
      eleven: "k",
      thirteen: "l",
      fourteen: "m"
    }

    second = %{
      one: "n",
      two: "o",
      three: "p",
      four: "q",
      five: "r",
      six: "s",
      seven: "t",
      eight: "u",
      nine: "v",
      ten: "w",
      eleven: "x",
      thirteen: "y",
      fourteen: "z"
    }

    text_list = String.graphemes(String.downcase(text))

    Enum.reduce(text_list, "", fn char, text ->
      if char in Map.values(first) do
        num =
          first
          |> Enum.find(fn {_key, value} -> value == char end)
          |> elem(0)

        text <> "#{Map.get(second, num)}"
      else
        if char in Map.values(second) do
          num =
            second
            |> Enum.find(fn {_key, value} -> value == char end)
            |> elem(0)

          text <> "#{Map.get(first, num)}"
        else
          text <> "#{char}"
        end
      end
    end)
  end
end
