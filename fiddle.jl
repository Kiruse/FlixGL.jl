push!(LOAD_PATH, @__DIR__)

using FlixGL
using VPEWorlds
using GLFW

wnd = FlixGL.Window(title="FlixGL Fiddle", fullscreen=Windowed, width=800, height=600)
FlixGL.use(wnd)
initwindow()
setbgcolor(Cyan3)

world = World{Transform2D{Float64}}()

cam = Camera2D()
img = load_image(PNGImageFormat, "./assets/textures/test.png")
tex = texture(img)
sprite = Sprite2D(200, 200, tex)
translate!(sprite, Vector2(50, 0))
rotate!(sprite, deg2rad(45))
scale!(sprite, Vector2(1.5, 1.5))
push!(world, sprite.transform)
ntts = [sprite]

t0 = time()
while !wantsclose()
    global t0
    t1 = time()
    dt = t1-t0
    t0 = t1
    
    rotate!(sprite, deg2rad(10) * dt)
    
    GLFW.PollEvents()
    update(cam.transform)
    update(world)
    render(ForwardRenderPipeline, cam, ntts)
    FlixGL.flip()
end
