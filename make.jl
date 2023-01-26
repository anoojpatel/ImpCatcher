using PackageCompiler

include("packages.jl")

PackageCompiler.create_sysimage(
  PACKAGES,
  sysimage_path = "sysimg.so",
  precompile_execution_file = "precompile.jl",
  cpu_target = PackageCompiler.default_app_cpu_target()
)
