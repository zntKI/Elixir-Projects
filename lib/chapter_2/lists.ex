defmodule MyApp.Chapter2.List do
  def capitalize_first(string) do
    list = String.graphemes(string)
    letter = String.upcase(hd(list))
    new_list = List.delete_at(list, 0)
    to_string([letter | new_list])
  end

  def first_even_or_odd(nums) do
    if rem(hd(nums), 2) == 0 do
      true
    else
      false
    end
  end

  def multiply_by_five(nums) do
    Enum.map(nums, &(&1 * 5))
  end

  def only_even_nums(nums) do
    Enum.filter(nums, &(rem(&1, 2) == 0))
  end

  def sum_of_all_nums_mult_by_five(nums) do
    new_nums = Enum.map(nums, &(&1 * 5))
    Enum.sum(new_nums)
  end
end
