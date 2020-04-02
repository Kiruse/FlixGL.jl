import GLFW

struct DontCareType end
const DontCare = DontCareType()

@enum FullscreenMode Windowed Fullscreen Borderless

mutable struct WindowCreationArgs
    title::AbstractString
    monitor::Integer
    width::Union{<:Integer, DontCareType}
    height::Union{<:Integer, DontCareType}
    fullscreen::FullscreenMode
    bits::Union{Tuple{<:Integer, <:Integer, <:Integer}, DontCareType}
    refresh_rate::Union{<:Integer, DontCareType}
end
WindowCreationArgs() = WindowCreationArgs("<untitled window>", 1, DontCare, DontCare, Borderless, DontCare, DontCare)

struct Window
    handle::GLFW.Window
end

function Window(args::WindowCreationArgs)
    monitors = GLFW.GetMonitors()
    args.monitor = clamp(args.monitor, 1, length(monitors))
    monitor = Nothing
    
    if args.fullscreen == Borderless
        monitor = monitors[args.monitor]
        vidmode = GLFW.GetVideoMode(monitor)
        
        args.width  = vidmode.width
        args.height = vidmode.height
        args.bits   = vidmode.redbits, vidmode.greenbits, vidmode.bluebits
        args.refresh_rate = vidmode.refreshrate
    end
    
    if typeof(args.bits) != DontCareType
        red, green, blue = args.bits
        GLFW.WindowHint(GLFW.RED_BITS,   red)
        GLFW.WindowHint(GLFW.GREEN_BITS, green)
        GLFW.WindowHint(GLFW.BLUE_BITS,  blue)
    else
        GLFW.WindowHint(GLFW.RED_BITS,   GLFW.DONT_CARE)
        GLFW.WindowHint(GLFW.GREEN_BITS, GLFW.DONT_CARE)
        GLFW.WindowHint(GLFW.BLUE_BITS,  GLFW.DONT_CARE)
    end
    if typeof(args.refresh_rate) != DontCareType
        GLFW.WindowHint(GLFW.REFRESH_RATE, args.refresh_rate)
    else
        GLFW.WindowHint(GLFW.REFRESH_RATE, GLFW.DONT_CARE)
    end
    
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
    #GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT, GLFW.TRUE)
    
    Window(GLFW.CreateWindow(args.width, args.height, args.title, monitor))
end
Window() = Window(WindowCreationArgs())

use(wnd::Window) = GLFW.MakeContextCurrent(wnd.handle)
destroy(wnd::Window) = GLFW.DestroyWindow(wnd.handle)

flip(wnd::Window) = GLFW.SwapBuffers(wnd.handle)
