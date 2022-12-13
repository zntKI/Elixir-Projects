defmodule MyApp.Chapter5.Structs do
  defmodule Employee do
    defstruct [:first_name , :last_name , :age , :department , :years_of_exp , :salary ]
  end

  defmodule Company do
    defstruct [name: "Quanterall", employees: [
      %Employee{first_name: "Kaloyan", last_name: "Ivanov", age: 25, department: "IT", years_of_exp: 5, salary: 3000},
      %Employee{first_name: "Ivan", last_name: "Georgiev", age: 28, department: "sales", years_of_exp: 6, salary: 3200},
      %Employee{first_name: "Boris", last_name: "Draganov", age: 35, department: "operations", years_of_exp: 9, salary: 4000},
    ]]
  end

  def promote_employees(%{name: _name, employees: emps}, salary_below, new_salary) do
    #Enum.map(company_info, &Map.update(&1, :salary, salary_below,
    #  fn salary -> if salary <= salary_below do
    #    new_salary
    #  else
    #    salary
    #  end end))

      Enum.map(emps, fn map ->
          salary = Map.get(map, :salary)
          if salary <= salary_below do
            %{map | salary: new_salary}
          else
            %{map | salary: salary}
          end
        end)
  end

  def moving_emp(%{name: _name, employees: emps}, fullname, department) do
    Enum.map(emps, fn map ->
      full_name = make_full_name(map)
      if full_name == fullname do
        %{map | department: department}
      else
        map
      end
    end)
  end

  def pull_emps(%{name: _name, employees: emps}, department, first_s, second_s) do
    Enum.filter(emps, fn map ->
      dep = Map.get(map, :department)
      salary = Map.get(map, :salary)
      dep == department and salary >= first_s and salary <= second_s
    end)
  end

  def fire_emp(%{name: _name, employees: emps}, fullname) do
    Enum.filter(emps, fn map ->
      full_name = make_full_name(map)
      full_name != fullname
    end)
  end

  def make_full_name(map) do
    Map.get(map, :first_name) <> " " <> Map.get(map, :last_name)
  end
end
