import Base.Filesystem
const PROJDIR = Filesystem.abspath(@__DIR__)
const SHADERDIR = "$(PROJDIR)/assets/shaders"
push!(LOAD_PATH, PROJDIR)

using FlixGL
using FlixGL.LowLevel
import FlixGL.LowLevel.BufferUsage
import ModernGL


FlixGL.init()
wnd = FlixGL.Window()
FlixGL.use(wnd)

prog = program(shader(VertexShader, "$(SHADERDIR)/test.vertex.glsl"), shader(FragmentShader, "$(SHADERDIR)/test.fragment.glsl"))

vao = vertexarray()

buff_verts = buffer(PrimitiveArrayBuffer{Float32}, Float32[-1, -1, 0, 1, -1, 0, 0, 1, 0], BufferUsage.Static, BufferUsage.Draw)
bind(vao, buff_verts, 0, 3)

start_time = time()
while time() - start_time < 3
    LowLevel.use(prog)
    draw(vao, TrianglesDrawMode, 3)
    FlixGL.flip(wnd)
end

LowLevel.destroy(prog)
FlixGL.destroy(wnd)
FlixGL.terminate()
