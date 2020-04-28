import Base.Filesystem
const PROJDIR = Filesystem.abspath(@__DIR__)
const SHADERDIR = "$(PROJDIR)/assets/shaders"
push!(LOAD_PATH, PROJDIR)

using FlixGL
import GLFW
import ModernGL

wnd = FlixGL.Window(title="FlixGL Fiddle")

FlixGL.use(wnd)
setvsync()

cam = Camera2D()
img = load_image(PNGImageFormat, "./assets/textures/test.png")
tex = texture(img)
sprite = Sprite2D(200, 200, tex)

while !GLFW.WindowShouldClose(wnd.handle)
    pollevents()
    render(ForwardRenderPipeline, cam, [sprite])
    FlixGL.flip(wnd)
end
