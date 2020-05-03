push!(LOAD_PATH, @__DIR__)

using FlixGL

wnd = FlixGL.Window(title="FlixGL Fiddle")
FlixGL.use(wnd)
initwindow()
setbgcolor(Cyan3)

cam = Camera2D()
img = load_image(PNGImageFormat, "./assets/textures/test.png")
tex = texture(img)
sprite = Sprite2D(200, 200, tex)

while !wantsclose()
    pollevents()
    render(ForwardRenderPipeline, cam, [sprite])
    FlixGL.flip()
end
