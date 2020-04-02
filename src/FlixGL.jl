module FlixGL

import GLFW

export use, destroy

use(_...) = error("Not implemented")
destroy(_...) = error("Not implemented")

include("./LowLevel.jl")
include("./Windows.jl")

function init()
    GLFW.Init()
end

function terminate()
    GLFW.Terminate()
end

end # module
