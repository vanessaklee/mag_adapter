defmodule MagAdapter do
  @moduledoc """
  Method for initializing the ingestion of faculty and faculty rosters from Microsoft Academic Graph.
  Rosters are CSV files located in priv/data directory named for the institution (i.e. emory_university.csv).

  To ingest a single faculty member, a search spec struct is required.
  Exida.Services.Search.SearchSpec
  @type
  defstruct([
    :external_id,
    :name,
    :aliases,
    :dois,
    :affiliations,
    :departments,
    :known_resource_ids,
    :keywords,
    :fields_of_study
  ])

  Fields:
  Name {.given, .surname, .middle}
  Known aliases [(::Name)]
  PID: [integer as string]
  DOIs: [::url]
  Affiliations {Institution/Research facility name, display name, department name, etc}
  known resource ids: [::adapter id as uri, eg: "mag://id-of-faculty" or "mag.identifier"]
  keywords: [::string]
  fields of study: [::string]
  """
  @default_limit 1

  @doc """
  Ingest faculty for an affiliation institution from a roster
  """
  @spec ingest_roster(String.t(), Integer.t()) :: :ok | :error
  def ingest_roster(affiliation, limit \\ @default_limit) do
    read_roster(affiliation, limit)
    |> Enum.map(fn contents ->
      map_contents(contents, affiliation)
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> List.flatten()
    |> Enum.map(fn faculty ->
      IO.inspect(faculty, label: "Ingesting faculty member object")

      # TODO orcid

    end)

    :ok
    # TODO handle errors?
  end

  @doc """
  Ingest a single faculty member from search params.
  """
  # TODO handle aliases, resource_ids, keywords, and fields of study and pass them along to the evaluation
  @spec ingest_faculty_member(list()) :: list()
  def ingest_faculty_member([
    pid,
    {given, family, middle},
    _aliases,
    dois,
    affiliation,
    [ group | departments ],
    _known_resource_ids,
    _keywords,
    _fields_of_study
  ]) do
    faculty = [
      pid,
      family,
      given,
      middle,
      nil,
      group,
      departments,
      dois
    ]

    map_contents({:ok, faculty}, affiliation)
    |> Enum.filter(&(!is_nil(&1)))
    |> List.flatten()
  end

  @doc """
  Normalize a row from the roster into a map that represents a faculty member. Skip if the row is the header row.
  """
  @spec read_roster(String.t(), Integer.t()) :: list()
  def read_roster(affiliation, limit \\ @default_limit) do
    dir = Path.join([:code.priv_dir(:mag_adapter), "data"])
    file = affiliation <> ".csv"
    Path.join([dir, file])
      |> File.stream!()
      |> CSV.decode()
      |> Enum.take(limit)
  end

  @doc """
  Normalize a row from the roster into a map that represents a faculty member. Skip if the row is the header row.
  """
  @spec map_contents(tuple(), String.t()) :: map()
  def map_contents(
        {:ok,
         [
           "Employee ID",
           "Last Name",
           "First Name",
           "Middle Name",
           "Email",
           "Primary Group Descriptor",
           "Department",
           "Doi"
         ]},
        _
      ),
      do: nil
  def map_contents(
      {:ok,
        [
          faculty_id,
          last_name,
          first_name,
          middle_initial,
          email,
          group,
          department,
          doi
        ]},
      affiliation
    ) when is_list(department) do
    Enum.map(department, fn d ->
      map_contents({:ok, [
        faculty_id,
        last_name,
        first_name,
        middle_initial,
        email,
        group,
        d,
        doi
      ]}, affiliation)
    end)
  end
  def map_contents(
        {:ok,
         [
           faculty_id,
           last_name,
           first_name,
           middle_initial,
           email,
           group,
           department,
           doi
         ]},
        affiliation
      ) do
    dois =
      if is_list(doi) do
        doi
      else
        [doi]
      end

    faculty_name =
      (first_name <> " " <> middle_initial <> " " <> last_name)
      |> String.replace("  ", " ")
      |> String.trim()

    dept = if is_nil(department) or department == "" do
        Department.from_group(group)
      else
        department
      end

    %{
      affiliation: affiliation,
      pid: faculty_id,
      faculty_name: faculty_name,
      last_name: last_name,
      first_name: first_name,
      middle_initial: middle_initial,
      email: email,
      group: group,
      department: dept,
      dois: dois
    }
  end
end
