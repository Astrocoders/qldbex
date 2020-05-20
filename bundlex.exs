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
          get_lib_path("decNumber"),
          get_lib_path("ionc")
        ]
      ]
    ]
  end

  defp get_lib_path(folder) do
    Path.join(__DIR__, "c_src/qldbex/c_libs/#{folder}")
  end
end
