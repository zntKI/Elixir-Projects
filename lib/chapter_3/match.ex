defmodule MyApp.Chapter3.Match do
  def match1([h, h1 | _]) do
    {h, h1}
  end

  def match1(_a) do
    raise(ArgumentError, "Must be at least two elements")
  end

  def match2([a, b]) do
    {a, b}
  end

  def match2(_a) do
    raise(ArgumentError, "Must be exactly two elements")
  end

  def match3([a, a | _]) do
    a
  end

  def match3(_a) do
    raise(ArgumentError, "Must be the same two elements")
  end

  def match4([a, a]) do
    a
  end

  def match4(_a) do
    raise(ArgumentError, "Must be the same two elements")
  end

  def replace(string, ch1, ch2) do
    func = fn ch ->
      if ch == ch1 do
        ch2
      else
        ch
      end
    end

    word = String.graphemes(string)
    word = Enum.map(word, func)
    List.to_string(word)
  end
end
