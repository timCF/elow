defmodule Elow.Mixfile do
  use Mix.Project

  def project do
    [app: :elow,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: 	[
						:logger,
						:silverb,
						:myswt,
						:wwwest,
						:exutils
					],
     mod: {Elow, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
	[
		{:silverb, github: "timCF/silverb"},
		{:myswt, github: "timCF/myswt", branch: "megaweb"},
		{:wwwest, github: "timCF/wwwest"},
		{:exutils, github: "timCF/exutils"}
	]
  end
end
