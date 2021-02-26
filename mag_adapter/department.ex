defmodule MagAdapter.Department do
  @moduledoc """
  Methods for handling and processing university departments to be used in determining a faculty member's fields of study.
  """
  # alias MagAdapter.Affiliations
  # alias MagAdapter.FieldsOfStudy
  # alias MagAdapter.Institutions.EmoryUniversity
  # alias MagAdapter.{Departments, Repo, Clean}

  # @generic ["study", "studies", "service", "services", "system", "systems", "care", "center", "centers", "ctr", "admin", "administration", "college", "emory", "general", "of", "dean", "the", "provost", "office", "offices", "ofc", "support", "funding", "development", "practice", "method", "theory", "mind"]
  # @emory ["faculty support / resrch", "lt leave  (hr use only)", "library it expense", "administration", "admin", "oxford college", "play emory", "office of the dean", "general", "the carter center", "dean of the college", "evp academic affairs & provost", "leadership", "ofc undergrad education", "system", "development practice mdp", "vp faculty affairs", "winship cancer institute", "evp health affairs", "research funding support", "development practice mdp"]

  # def keywords(department) do
  #   trim_dept = department |> String.downcase() |> String.trim()

  #   IO.inspect "Ingesting department: #{trim_dept}"
  #   if trim_dept not in @emory do
  #     clean(trim_dept)
  #     |> FieldsOfStudy.create()
  #   else
  #     []
  #   end
  # end

  # def clean(department) do
  #   trim = department
  #     |> String.trim()

  #   if String.downcase(trim) in @emory do
  #     []
  #   else
  #     big = String.split(trim, "&")

  #     trim_big = Enum.map(big, fn b ->
  #       String.trim(b)
  #     end)

  #     small = Enum.map(trim_big, fn b ->
  #       b |> String.split()
  #     end) |> List.flatten()

  #     combined = trim_big ++ small |> Enum.uniq() |> combinations()

  #     clean = Enum.reduce(combined, [], fn c, acc ->
  #       if String.contains?(c, "'s") do
  #         # MAG expects apostrophe's to be resplaced by a space
  #         # women's studies -> women s studies
  #         acc ++ [String.replace(c, "'", ""), String.replace(c, "'", " ")]
  #       else
  #         if String.contains?(c, "'") do
  #           # MAG expects apostrophe's to be resplaced by a space
  #           # women's studies -> women s studies
  #           acc ++ [String.replace(c, "'", " ")]
  #         else
  #           if String.ends_with?(c, "ies") do
  #             acc ++ [c, String.slice(c, 0..-4) <> "y"]
  #           else
  #             if String.ends_with?(c, "s") do
  #               acc ++ [c, String.slice(c, 0..-2)]
  #             else
  #               acc ++ [c]
  #             end
  #           end
  #         end
  #       end
  #     end)

  #     filtered = Enum.filter(clean, fn n ->
  #         String.downcase(n) not in @generic
  #       end)
  #   end
  # end

  # def clean_no_combo(department) do
  #   trim = department |> String.trim() |> String.downcase()

  #   if trim in @emory || trim in @generic do
  #     nil
  #   else
  #     if String.contains?(trim, "'") do
  #       # MAG expects apostrophe's to be resplaced by a space
  #       # women's studies -> women s studies
  #       String.replace(trim, "'", " ")
  #     else
  #       if String.contains?(trim, "department of") do
  #         [_h | dept] = String.split(trim, "department of ")
  #         dept
  #       else
  #         if String.contains?(trim, "school of") do
  #           [_h | dept] = String.split(trim, "school of ")
  #           dept
  #         else
  #           trim
  #         end
  #       end
  #     end
  #   end
  # end

  # def combinations(list) when is_list(list) do
  #   num = 2
  #   Enum.reduce(0..num, [], fn n, acc ->
  #     single_word_list = Enum.reject(list, fn l -> String.contains?(l, " ") end)
  #     combo = combinations(single_word_list, n)
  #     flat = List.flatten(combo)
  #     flat_count = Enum.count(flat)

  #     result =
  #       if flat_count == num do
  #         single = flat |> List.flatten() |> Enum.join(" ")
  #         ([single] ++ flat) |> List.flatten()
  #       else
  #         Enum.map(combo, fn c ->
  #           c |> List.flatten() |> Enum.join(" ")
  #         end)
  #       end

  #     (acc ++ result) |> List.flatten()
  #   end)
  #   |> Enum.filter(fn r -> !is_nil(r) && r != "" end)
  #   |> List.insert_at(-1, list)
  #   |> List.flatten()
  #   |> Enum.uniq()
  # end

  # def combinations(_, _, _), do: []

  # def combinations(list, num)

  # def combinations(_list, 0), do: [[]]

  # def combinations(list = [], _num), do: list

  # def combinations([head | tail], num) do
  #   Enum.map(combinations(tail, num - 1), &[head | &1]) ++
  #     combinations(tail, num)
  # end

  # def trim_downcase(department) do
  #   department
  #   |> String.downcase()
  #   |> String.trim()
  # end

  # def ampersand_check(departments) when is_list(departments) do
  #   Enum.map(departments, fn department -> ampersand_check(department) end) ++ departments
  #   |> List.flatten()
  # end
  # def ampersand_check(department) do
  #   d = String.downcase(department)
  #   if String.contains?(d, "&") do
  #     String.split(d, "&")
  #     |> Clean.symbols()
  #     |> Clean.remove_stop_words()
  #     |> Clean.remove_numbers()
  #     |> Clean.remove_commas()
  #     |> Clean.trim()
  #   else
  #     if String.contains?(d, "and") do
  #       String.split(d, "and")
  #       |> Clean.symbols()
  #       |> Clean.remove_stop_words()
  #       |> Clean.remove_numbers()
  #       |> Clean.remove_commas()
  #       |> Clean.trim()
  #     else
  #       department
  #     end
  #   end
  # end

  @doc """
  Associate a group from a faculty roster with a top-level field of study or department.
  TODO this should be a table
  """
  def from_group(nil), do: ""
  def from_group(group) do
    case String.downcase(group) do
      "columbia engineering" -> "engineering"
      _ -> ""
    end
  end
end
