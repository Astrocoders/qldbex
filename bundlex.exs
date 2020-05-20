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
        sources: [
          "_generated/qldbex.c",
          "base64/base64.c",
          "qldbex.c"
        ],
        libs: ["decNumber", "ionc", "json-c", "crypto"],
        includes: ["c_src/qldbex"],
        lib_dirs: [
          Path.join(:code.priv_dir(:qldbex), "decNumber"),
          Path.join(:code.priv_dir(:qldbex), "ionc")
        ]
      ]
    ]
  end
end
