defmodule MyApp.Chapter6.Lists do
  def get_all_nums(list) do
    for n <- list, is_number(n) do
      n
    end
  end

  def is_pangram(text) do
    all_letters = "abcdefghijklmnopqrstuvwxyz"

    letter_list =
      for s <- String.graphemes(String.downcase(text)), s != " ", reduce: [] do
        acc ->
          if String.contains?(text, s) do
            [s | acc]
          else
            acc
          end
      end

    text_letters = List.to_string(Enum.sort(Enum.uniq(letter_list)))

    text_letters == all_letters
  end

  def scrabble(list) do
    final_list =
      for {name, words} <- list, reduce: [] do
        acc_list ->
          final_points =
            for word <- words, reduce: 0 do
              all_points ->
                list_word = String.graphemes(String.downcase(word))

                word_points =
                  for char <- list_word, reduce: 0 do
                    acc ->
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
                  end

                all_points + word_points
            end

          [{name, final_points} | acc_list]
      end

    Enum.max_by(final_list, fn {_name, points} -> points end)
  end

  def scrabble_test(list) do
    for {name, words} <- list do
      final_points =
        for word <- words, reduce: 0 do
          all_points ->
            list_word = String.graphemes(String.downcase(word))

            word_points =
              for char <- list_word, reduce: 0 do
                acc ->
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
              end

            all_points + word_points
        end

      IO.puts({name, final_points})
    end
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

    for s <- text_list, into: "" do
      if s in Map.values(first) do
        num =
          first
          |> Enum.find(fn {_key, value} -> value == s end)
          |> elem(0)

        "#{Map.get(second, num)}"
      else
        if s in Map.values(second) do
          num =
            second
            |> Enum.find(fn {_key, value} -> value == s end)
            |> elem(0)

          "#{Map.get(first, num)}"
        else
          "#{s}"
        end
      end
    end
  end
end
