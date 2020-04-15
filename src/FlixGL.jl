module FlixGL

import GLFW
using StaticArrays

export use, destroy

const dir_assets  = "$(@__DIR__)/../assets"
const dir_shaders = "$dir_assets/shaders"

use(    _...) = error("Not implemented")
destroy(_...) = error("Not implemented")
upload( _...) = error("Not implemented")

include("./LowLevel.jl")
include("./Windows.jl")
include("./FlixGL.Errors.jl")
include("./FlixGL.Color.jl")
include("./FlixGL.Matrix.jl")
include("./FlixGL.Transform.jl")
include("./FlixGL.Vertex.jl")
include("./FlixGL.Material.jl")
include("./FlixGL.Entity.jl")
include("./FlixGL.RenderPipeline.jl")
include("./FlixGL.RenderForward.jl")
include("./FlixGL.Misc.jl")

function init()
    GLFW.Init()
end

function terminate()
    GLFW.Terminate()
end

end # module
