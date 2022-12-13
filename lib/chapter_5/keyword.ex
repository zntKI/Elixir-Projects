defmodule MyApp.Chapter5.Keyword do
  def first(string, list \\ []) do
    letter = String.at(string, 0)

    upper_if = Keyword.get(list, :upper, nil)
    repeat_if = Keyword.get(list, :repeat, 1)

    letter_moodified =
      case upper_if do
        nil ->
          letter

        false ->
          String.downcase(letter)

        true ->
          String.upcase(letter)
      end

    String.to_charlist(String.duplicate(letter_moodified, repeat_if))
    # if upper_if do
    #  String.to_charlist(String.duplicate(String.upcase(String.at(string, 0)), repeat_if))
    # else
    #  upcase? = fn x -> x == String.upcase(x) end
    #
    #  if upcase?.(String.at(string, 0)) do
    #    String.to_charlist(String.duplicate(String.downcase(String.at(string, 0)), repeat_if))
    #  else
    #    String.to_charlist(String.duplicate(String.at(string, 0), repeat_if))
    #  end
    # end
  end
end
