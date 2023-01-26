using Pkg

function list_packages()
  deps = Pkg.dependencies()
  installs = Dict{String, Vector{Any}}()
  
  for (uuid, dep) in deps
    dep.is_direct_dep || continue
    dep.version === nothing && continue
    dep.source === nothing && continue
    moddevdir = false
      
    if haskey(ENV, "JULIA_PKG_DEVDIR")
      moddevdir = true
    end
  
    if moddevdir && occursin(ENV["JULIA_PKG_DEVDIR"], dep.source)
      installs[dep.name] = [dep.version, "dev"]
    elseif !moddevdir && !isempty(findall(x -> x == "dev", splitpath(dep.source)))
      installs[dep.name] = [dep.version, "dev"]
    else
      installs[dep.name] = [dep.version, ""]
    end
  
  end
  
  return installs
end

const PACKAGES = [pkg for pkg in keys(list_packages())]
