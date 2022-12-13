defmodule MyApp.Chapter3.Operators do
  def both_nums_present(num1, num2, nums) do
    if Enum.member?(nums, num1) == true do
      if Enum.member?(nums, num2) == true do
        true
      else
        false
      end
    else
      false
    end
  end

  def check_two_lists(list1, list2) do
    Enum.all?(list2, &(Enum.member?(list1, &1) == true))
  end
end
