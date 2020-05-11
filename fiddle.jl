push!(LOAD_PATH, @__DIR__)

using FlixGL
using GLFW

wnd = FlixGL.Window(title="FlixGL Fiddle", fullscreen=Windowed, width=800, height=600)
FlixGL.use(wnd)
initwindow()
setbgcolor(Cyan3)

world = World{Transform2D{Float64}}()

cam = Camera2D()
img = load_image(PNGImageFormat, "./assets/textures/test.png")
tex = texture(img)

sprite1 = Sprite2D(200, 200, tex, originoffset=(-0.9, -0.9))
translate!(sprite1, Vector2(50, 0))
rotate!(sprite1, deg2rad(45))
# scale!(sprite1, Vector2(1.5, 1.5))
push!(world, sprite1)

sprite2 = Sprite2D(50, 50, tex)
parent!(sprite2, sprite1)
translate!(sprite2, Vector2(150, 0))

ntts = [sprite1, sprite2]

t0 = time()
while !wantsclose()
    global t0
    t1 = time()
    dt = t1-t0
    t0 = t1
    
    rotate!(sprite1, deg2rad( 10) * dt)
    rotate!(sprite2, deg2rad(-20) * dt)
    
    GLFW.PollEvents()
    update(cam.transform)
    update(world)
    render_background(ForwardRenderPipeline)
    render(ForwardRenderPipeline, WorldRenderSpace, cam, ntts)
    FlixGL.flip()
end
