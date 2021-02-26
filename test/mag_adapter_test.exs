defmodule MagAdapterTest do
  use ExUnit.Case
  doctest MagAdapter

  @institution "test_university"

  test "reads the roster" do
    assert MagAdapter.read_roster(@institution) == test_row_one()
  end

  test "maps a roster row" do
    row = MagAdapter.read_roster(@institution)
      |> Enum.map(fn contents ->
        MagAdapter.map_contents(contents, @institution)
      end)

    assert row == [test_row_one_map()]
  end

  test "limit does limit the number of rows returned" do
    rows = MagAdapter.read_roster(@institution, 3)
      |> Enum.map(fn contents ->
        MagAdapter.map_contents(contents, @institution)
      end)

    next_rows = MagAdapter.read_roster(@institution, 5)
      |> Enum.map(fn contents ->
        MagAdapter.map_contents(contents, @institution)
      end)

    assert Enum.count(rows) == 3
    assert Enum.count(next_rows) == 5
  end

  test "map single faculty member" do
    [
      pid,
      {given, family, middle},
      aliases,
      dois,
      affiliation,
      [ group | department ],
      resource_ids,
      keywords,
      fields_of_study]  = fixture_faculty()

    send_faculty = [
      pid,
      family,
      given,
      middle,
      nil,
      group,
      department,
      dois
    ]
    assert MagAdapter.map_contents({:ok, send_faculty}, @institution)  == Map.new(ingested_fixture_faculty())
  end

  test "ingest single faculty member" do
    faculty = MagAdapter.ingest_faculty_member(fixture_faculty())
    assert faculty == ingested_fixture_faculty()
  end

  test "handle multiple departments" do
    # TODO this test
    assert true
  end

  def test_row_one() do
    [{:ok, ["1234567", "Test0", "Jane", "Doe", "jane.doe.test@university.edu", "University Engineering", "Computer Science", ""]}]
  end

  def test_row_one_map() do
    %{
      affiliation: @institution,
      department: "Computer Science",
      dois: [""],
      email: "jane.doe.test@university.edu",
      faculty_name: "Jane Doe Test0",
      first_name: "Jane",
      group: "University Engineering",
      last_name: "Test0",
      middle_initial: "Doe",
      pid: "1234567"
    }
  end

  def fixture_faculty() do
    [{:ok, [pid, family, given, middle, _, group, department, _]}] = test_row_one()
    [
      pid,
      {given, family, middle},
      ["j doe", "janie maiden name"],
      ["10.1287/OPRE.2018.1832", "10.1145/3328526.3329565"], # dois
      @institution,
      [ group | department ],
      [%{type: :author, origin: "mag", origin_id: "2442316571"}], # resource ids
      ["computer science", "mathematical optimization", "regret", "mathematical economics", "general game playing"], # keywords
      ["computer science", "mathematical optimization", "reinforcement learning", "thompson sampling"] # fields of study
    ]
  end

  def ingested_fixture_faculty() do
    [
      affiliation: @institution,
      department: "Computer Science",
      dois: ["10.1287/OPRE.2018.1832", "10.1145/3328526.3329565"],
      email: nil,
      faculty_name: "Jane Doe Test0",
      first_name: "Jane",
      group: "University Engineering",
      last_name: "Test0",
      middle_initial: "Doe",
      pid: "1234567"
    ]
  end
end
