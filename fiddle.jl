import Base.Filesystem
const PROJDIR = Filesystem.abspath(@__DIR__)
const SHADERDIR = "$(PROJDIR)/assets/shaders"
push!(LOAD_PATH, PROJDIR)

using FlixGL
import ModernGL

wnd = FlixGL.Window()
FlixGL.use(wnd)

cam = Camera2D()
img = load_image(PNGImageFormat, "./assets/textures/test.png")
tex = texture(img)
sprite = Sprite2D(200, 200, tex)

start_time = time()
while time() - start_time < 5
    render(ForwardRenderPipeline, cam, [sprite])
    FlixGL.flip(wnd)
    sleep(1/60)
end
