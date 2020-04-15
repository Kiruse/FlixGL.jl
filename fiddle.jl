import Base.Filesystem
const PROJDIR = Filesystem.abspath(@__DIR__)
const SHADERDIR = "$(PROJDIR)/assets/shaders"
push!(LOAD_PATH, PROJDIR)

using FlixGL
using FlixGL.LowLevel
import FlixGL.LowLevel.BufferUsage
import ModernGL

# Constants

const dir_shaders = "$(@__DIR__)/assets/shaders"

# Globals

testprog = nothing


# Test Vertex

struct TestVertex <: AbstractVertex
    coords::Vector2{Float32}
    color::NormColor
end

struct TestVertexVAO <: AbstractVertexArrayData
    vao::LowLevel.VertexArray
    vbo_coords::LowLevel.PrimitiveArrayBuffer
    vbo_colors::LowLevel.PrimitiveArrayBuffer
    static::Bool
    readable::Bool
end

function FlixGL.upload(verts::AbstractArray{TestVertex}; static::Bool = true, readable::Bool = false)
    frequency, nature = FlixGL.getbufferusage(static, readable)
    
    vao = LowLevel.vertexarray()
    buffercurry = curry(LowLevel.buffer, LowLevel.PrimitiveArrayBuffer{Float32}, verts, frequency, nature)
    vbo_coords = buffercurry(mapper=vert->vert.coords)
    vbo_colors = buffercurry(mapper=vert->vert.color)
    bind(vao, vbo_coords, 0, 2)
    bind(vao, vbo_colors, 1, 4)
    TestVertexVAO(vao, vbo_coords, vbo_colors, static, readable)
end

function FlixGL.upload(vao::TestVertexVAO, verts::AbstractArray{TestVertex})
    @assert !vao.static
    LowLevel.buffer_update(vao.vbo_coords, verts, mapper=vert->vert.coords)
    LowLevel.buffer_update(vao.vbo_colors, verts, mapper=vert->vert.color)
end

function FlixGL.destroy(vao::TestVertexVAO)
    LowLevel.delete(vao)
    LowLevel.delete(vbo_coords)
    LowLevel.delete(vbo_colors)
end

# Test Material & low level Program

struct TestMaterial <: AbstractMaterial end

function FlixGL.programof(::Type{TestMaterial})
    global testprog
    if testprog == nothing
        testprog = LowLevel.program(LowLevel.shader(LowLevel.VertexShader, "$dir_shaders/test.vertex.glsl"), LowLevel.shader(LowLevel.FragmentShader, "$dir_shaders/test.fragment.glsl"))
    else
        testprog
    end
end

# Test Entity (vertex-colored polygon)
struct TestPoly <: AbstractEntity2D
    vao::TestVertexVAO
    transform::Transform2D
    material::TestMaterial
    vertices::AbstractArray{TestVertex}
end
function TestPoly(verts::AbstractArray{TestVertex}; transform::Transform2D = Transform2D(), static::Bool = true, readable::Bool = false)
    TestPoly(FlixGL.upload(verts, static=static, readable=readable), transform, TestMaterial(), verts)
end
FlixGL.drawmodeof(ntt::TestPoly) = LowLevel.TriangleFanDrawMode


FlixGL.init()
wnd = FlixGL.Window()
FlixGL.use(wnd)

verts = [
    TestVertex(Vector2{Float32}(-0.85, -1),   NormColor(1, 0, 0)),
    TestVertex(Vector2{Float32}( 0.85, -1),   NormColor(1, 0, 0)),
    TestVertex(Vector2{Float32}( 1,     0.8), NormColor(0, 1, 0)),
    TestVertex(Vector2{Float32}( 0,     1),   NormColor(0, 0, 1)),
    TestVertex(Vector2{Float32}(-1,     0.8), NormColor(0, 1, 0))
]
poly = TestPoly(verts)

start_time = time()
while time() - start_time < 3
    render(ForwardRenderPipeline, [poly])
    FlixGL.flip(wnd)
    sleep(1/60)
end

FlixGL.destroy(wnd)
FlixGL.terminate()
