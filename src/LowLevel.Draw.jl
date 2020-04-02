import ModernGL

export AbstractDrawMode, PointsDrawMode, LinesDrawMode, LineStripDrawMode, TrianglesDrawMode, TriangleStripDrawMode, TriangleFanDrawMode, PatchesDrawMode
export draw

abstract type AbstractDrawMode end
struct PointsDrawMode        <: AbstractDrawMode end
struct LinesDrawMode         <: AbstractDrawMode end
struct LineStripDrawMode     <: AbstractDrawMode end
struct TrianglesDrawMode     <: AbstractDrawMode end
struct TriangleStripDrawMode <: AbstractDrawMode end
struct TriangleFanDrawMode   <: AbstractDrawMode end
struct PatchesDrawMode       <: AbstractDrawMode end
gltype(::Type{<:AbstractDrawMode}) = error("Unknown draw mode")
gltype(::Type{PointsDrawMode})        = ModernGL.GL_POINTS
gltype(::Type{LinesDrawMode})         = ModernGL.GL_LINES
gltype(::Type{LineStripDrawMode})     = ModernGL.GL_LINE_STRIP
gltype(::Type{TrianglesDrawMode})     = ModernGL.GL_TRIANGLES
gltype(::Type{TriangleStripDrawMode}) = ModernGL.GL_TRIANGLE_STRIP
gltype(::Type{TriangleFanDrawMode})   = ModernGL.GL_TRIANGLE_FAN
gltype(::Type{PatchesDrawMode})       = ModernGL.GL_PATCHES

function draw(va::VertexArray, mode::Type{<:AbstractDrawMode}, count::Integer; first::Integer = 1)
    use(va)
    ModernGL.glDrawArrays(gltype(mode), first-1, count) # first-1 because Julia starts indexing at 1, but OpenGL starts at 0
    checkglerror()
end
