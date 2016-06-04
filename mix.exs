defmodule JsonapiKit.Mixfile do
  use Mix.Project

  def project do
    [app: :solage,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [plt_add_apps: [:plug]],
     deps: deps,
     docs: [extras: ["README.md"], main: "readme",
       source_url: "https://github.com/simonprev/solage"]
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:plug, "~> 1.1.0"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:dialyxir, "~> 0.3.3", only: [:dev, :test]}
    ]
  end
end
