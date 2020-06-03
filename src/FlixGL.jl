module FlixGL

import GLFW
using StaticArrays
using VPECore

export use, upload
export default_transform_type, default_transform_type!, defaulttransform

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
include("./FlixGL.FrameDrivers.jl")
include("./FlixGL.Entity.jl")
include("./FlixGL.Camera.jl")
include("./FlixGL.RenderPipeline.jl")
include("./FlixGL.RenderForward.jl")

function __init__()
    
end

function __exit__()
    wnd = activewindow()
    if wnd
        close(activewindow())
    end
end
atexit(__exit__)


default_transform_type() = _default_transform_type
default_transform_type!(T::Type{<:AbstractTransform}) = (global _default_transform_type; _default_transform_type = T)
defaulttransform() = default_transform_type()()

_default_transform_type = Transform2D{AbstractEntity2D, Float64}

end # module
