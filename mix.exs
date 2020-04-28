defmodule Qldbex.MixProject do
  use Mix.Project

  def project do
    [
      app: :qldbex,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      compilers: [:unifex, :bundlex] ++ Mix.compilers(),
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:unifex, "~> 0.2.0"},
      {:ex_aws_qldb, git: "https://github.com/Astrocoders/ex_aws_qldb"},
      {:poison, "~> 3.1"}
    ]
  end

  defp package do
    [
      files: ["lib", "c_src", "LICENSE", "README", "mix.exs"],
      maintainers: ["George Lima <george.lima@astrocoders.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Astrocoders/qldbex"
      }
    ]
  end
end
