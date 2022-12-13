defmodule MyApp.Chapter3.Ifs do
  def odd(num) do
    if rem(num, 2) != 0 do
      true
    else
      false
    end
  end

  def even(num) do
    if rem(num, 2) == 0 do
      true
    else
      false
    end
  end

  def calculate(num1, num2) do
    if rem(num1, 2) == 0 do
      if rem(num2, 2) == 0 do
        num1 + num2
      else
        num1 * num2
      end
    else
      if rem(num2, 2) != 0 do
        num1 - num2
      else
        num1 / num2
      end
    end
  end

  def calculate_cond(num1, num2) do
    cond do
      rem(num1, 2) == 0 and rem(num2, 2) == 0 -> num1 + num2
      rem(num1, 2) == 0 and rem(num2, 2) != 0 -> num1 * num2
      rem(num1, 2) != 0 and rem(num2, 2) != 0 -> num1 - num2
      rem(num1, 2) != 0 and rem(num2, 2) == 0 -> num1 / num2
    end
  end

  def calculate_case(num1, num2) do
    case rem(num1, 2) == 0 do
      true ->
        case rem(num2, 2) == 0 do
          true -> num1 + num2
          false -> num1 * num2
        end

      false ->
        case rem(num2, 2) == 0 do
          true -> num1 / num2
          false -> num1 - num2
        end
    end
  end

  def language_hello(lang) do
    case lang do
      "spanish" -> "Hola"
      "english" -> "Hello"
      "french" -> "bonjour"
      "japanese" -> "こんにちは"
      _ -> {:error, "Either the language is not supported or the input is incorrect!"}
    end
  end

  def list_to_tuples(list) do
    sort(list, [])
  end

  def sort([], s_list) do
    List.keysort(s_list, 0)
  end

  def sort([word | remain] = list, s_list) do
    first_letter = String.at(word, 0)

    if List.keyfind(s_list, first_letter, 0, false) do
      sort(remain, s_list)
    else
      flist = Enum.filter(list, fn word_f -> String.starts_with?(word_f, first_letter) end)
      sort(remain, [{first_letter, flist} | s_list])
    end
  end
end
