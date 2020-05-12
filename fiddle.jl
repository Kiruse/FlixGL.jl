push!(LOAD_PATH, @__DIR__)

using FlixGL
using GLFW

wnd = FlixGL.Window(title="FlixGL Fiddle", fullscreen=Windowed, width=800, height=600)
FlixGL.use(wnd)
initwindow()
setbgcolor(Cyan3)

world = World{Transform2D{Float64}}()

cam = Camera2D()

img1 = load_image(PNGImageFormat, "./assets/textures/test.png")
sprite1 = Sprite2D(200, 200, texture(img1), originoffset=(-0.9, -0.9))
translate!(sprite1, Vector2(50, 0))
rotate!(sprite1, deg2rad(45))
# scale!(sprite1, Vector2(1.5, 1.5))
push!(world, sprite1)

img2 = load_image(PNGImageFormat, "./assets/textures/test2.png")
img2w, img2h = size(img2)
s2driver = FrameDriver(img2w, img2h, img2w÷2, img2h÷2, count=4, interval=2, callback=(_, uvs)->update!(sprite2, uvs=uvs))
println(getframeuvs(s2driver))

sprite2 = Sprite2D(50, 50, texture(img2), frame=getframeuvs(s2driver), static=false)
parent!(sprite2, sprite1)
rotate!(sprite2, deg2rad(-45))
translate!(sprite2, Vector2(150, 0))

ntts = [sprite1, sprite2]

t0 = time()
while !wantsclose()
    global t0
    t1 = time()
    dt = t1-t0
    t0 = t1
    
    tick!(s2driver, dt)
    rotate!(sprite1, deg2rad( 10) * dt)
    rotate!(sprite2, deg2rad(-10) * dt)
    
    GLFW.PollEvents()
    update(cam.transform)
    update(world)
    render_background(ForwardRenderPipeline)
    render(ForwardRenderPipeline, WorldRenderSpace, cam, ntts)
    FlixGL.flip()
end
