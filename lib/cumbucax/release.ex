defmodule Cumbucax.Release do
  @moduledoc """
  Module respinsible for executing migrations during the release of the application
  """
  @app :cumbucax

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  def load_app do
    Application.load(@app)

    if Application.get_env(@app, Cumbucax.Repo)[:ssl] do
      Application.ensure_all_started(:ssl)
    end
  end
end
