module FlixGL

import GLFW
using StaticArrays
using VPEWorlds

export use, destroy, upload

# Forward VPEWorlds exports
export Vector2, Vector3, Vector4, Matrix2, Matrix3, Matrix4
export World, Transform2D
export translate!, rotate!, scale!, update, idmat, obj2world, world2obj

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
