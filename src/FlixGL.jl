module FlixGL

export use, destroy

use(_...) = error("Not implemented")
destroy(_...) = error("Not implemented")

include("./LowLevel.jl")
include("./Windows.jl")

end # module
