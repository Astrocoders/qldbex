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
          get_priv_path("decNumber"),
          get_priv_path("ionc")
        ]
      ]
    ]
  end

  defp get_priv_path(folder) do
    Application.app_dir(:qldbex, "priv/#{folder}")
  end
end
