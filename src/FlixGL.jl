module FlixGL

import GLFW
using StaticArrays
using VPEWorlds

export use, destroy, upload

const dir_assets  = "$(@__DIR__)/../assets"
const dir_shaders = "$dir_assets/shaders"

const Optional{T} = Union{Nothing, T}

include("./LowLevel.jl")
include("./Monitors.jl")
include("./Windows.jl")
include("./FlixGL.Errors.jl")
include("./FlixGL.Color.jl")
include("./FlixGL.Misc.jl")
include("./FlixGL.Vertex.jl")
include("./FlixGL.Image.jl")
include("./FlixGL.Texture.jl")
include("./FlixGL.Material.jl")
include("./FlixGL.UniformIdentifier.jl")
include("./FlixGL.Camera.jl")
include("./FlixGL.Entity.jl")
include("./FlixGL.RenderPipeline.jl")
include("./FlixGL.RenderForward.jl")

function __init__()
    
end

function __exit__()
    wnd = activewindow()
    if wnd
        destroy(activewindow())
    end
end
atexit(__exit__)

end # module
