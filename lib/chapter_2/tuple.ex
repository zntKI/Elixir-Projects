defmodule MyApp.Chapter2.Tuple do
  def with_length(string) do
    {string, String.length(string)}
  end

  def dividing(num1, num2) do
    result = rem(num1, num2)

    if result == 0 do
      "result #{num1 / num2}"
    else
      {:error, "Forbidden operation!"}
    end
  end
end
