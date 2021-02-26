defmodule MagAdapter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      MagAdapter.Repo
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: Exida.Supervisor)
  end
end
