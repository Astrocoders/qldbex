defmodule Qldbex.BundlexProject do
  use Bundlex.Project

  def project() do
    [
      nifs: nifs(Bundlex.platform())
    ]
  end

  def nifs(_platform) do
    [
      qldbex: [
        deps: [unifex: :unifex],
        src_base: "qldbex",
        sources: ["_generated/qldbex.c", "base64/base64.c", "qldbex.c"],
        libs: ["decNumber", "ionc", "json-c"],
        includes: ["c_src"]
      ]
    ]
  end
end