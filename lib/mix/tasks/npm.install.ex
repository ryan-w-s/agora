defmodule Mix.Tasks.Npm.Install do
  use Mix.Task

  @shortdoc "Installs npm dependencies"
  @moduledoc """
  Installs npm dependencies defined in assets/package.json.

  This task runs `npm install` in the assets directory.
  """

  def run(_) do
    Mix.shell().info("Installing npm dependencies...")

    case System.cmd("npm", ["install"], cd: "assets") do
      {output, 0} ->
        Mix.shell().info(output)
        :ok

      {output, status} ->
        Mix.raise("""
        npm install failed with status #{status}
        #{output}
        """)
    end
  end
end
