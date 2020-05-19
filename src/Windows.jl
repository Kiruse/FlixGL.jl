import ModernGL
import GLFW
export Window, WindowCreationArgs
export DontCare, dontcare
export initwindow, activewindow, resize!, flip, setvsync, clearvsync, enabletransparency, disabletransparency, wantsclose, pollevents
export setfullscreen!, clearfullscreen!, isfullscreen, setmonitor!, getmonitor
export FullscreenMode, Windowed, Fullscreen, Borderless

struct DontCare end
const dontcare = DontCare()

@enum FullscreenMode Windowed Fullscreen Borderless

active_wnd = nothing

mutable struct WindowCreationArgs
    title::AbstractString
    monitor::Optional{Integer}
    width::Union{<:Integer, DontCare}
    height::Union{<:Integer, DontCare}
    fullscreen::FullscreenMode
    bits::Union{NTuple{3, <:Integer}, DontCare}
    refresh_rate::Union{<:Integer, DontCare}
end
WindowCreationArgs(title::AbstractString = "<untitled window>") = WindowCreationArgs(title, 1, dontcare, dontcare, Borderless, dontcare, dontcare)

mutable struct Window
    handle::GLFW.Window
    monitor::Optional{Monitor}
    
    function Window(handle, monitor)
        wnd = new(handle, monitor)
        GLFW.SetWindowSizeCallback(handle, curry(wndresizecallback, wnd))
        wnd
    end
end

function Window(args::WindowCreationArgs)
    if args.monitor !== nothing && args.monitor > length(Monitors) args.monitor = 1 end
    monitor = nothing
    
    if args.monitor !== nothing && args.fullscreen == Borderless
        monitor = Monitor(args.monitor)
        vidmode = getvideomode(monitor)
        
        args.width  = vidmode.width
        args.height = vidmode.height
        args.bits   = (vidmode.redbits, vidmode.greenbits, vidmode.bluebits)
        args.refresh_rate = vidmode.refreshrate
    elseif args.monitor !== nothing
        monitor = Monitor(args.monitor)
    end
    
    if args.bits != dontcare
        red, green, blue = args.bits
        GLFW.WindowHint(GLFW.RED_BITS,   red)
        GLFW.WindowHint(GLFW.GREEN_BITS, green)
        GLFW.WindowHint(GLFW.BLUE_BITS,  blue)
    else
        GLFW.WindowHint(GLFW.RED_BITS,   GLFW.DONT_CARE)
        GLFW.WindowHint(GLFW.GREEN_BITS, GLFW.DONT_CARE)
        GLFW.WindowHint(GLFW.BLUE_BITS,  GLFW.DONT_CARE)
    end
    if args.refresh_rate != dontcare
        GLFW.WindowHint(GLFW.REFRESH_RATE, args.refresh_rate)
    else
        GLFW.WindowHint(GLFW.REFRESH_RATE, GLFW.DONT_CARE)
    end
    
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
    #GLFW.WindowHint(GLFW.OPENGL_DEBUG_CONTEXT, GLFW.TRUE)
    
    if monitor == nothing || args.fullscreen == Windowed
        Window(GLFW.CreateWindow(args.width, args.height, args.title), monitor)
    else
        Window(GLFW.CreateWindow(args.width, args.height, args.title, monitor.handle), monitor)
    end
end
function Window(; title::AbstractString = "<untitled window>", width::Union{DontCare, Integer} = dontcare, height::Union{DontCare, Integer} = dontcare, monitor::Optional{Integer} = 1, fullscreen::FullscreenMode = Borderless, bits::Union{DontCare, NTuple{3, <:Integer}} = dontcare, refresh_rate::Union{DontCare, <:Integer} = dontcare)
    Window(WindowCreationArgs(title, monitor, width, height, fullscreen, bits, refresh_rate))
end

Base.size(wnd::Window) = (dims = GLFW.GetWindowSize(wnd.handle); (dims.width, dims.height))
resize!(wnd::Window, width::Integer, height::Integer) = (GLFW.SetWindowSize(wnd.handle, width, height); wnd)

function wndresizecallback(wnd, _, width, height)
    ModernGL.glViewport(0, 0, width, height)
end

activewindow() = active_wnd
use(wnd::Window) = (global active_wnd; active_wnd = wnd; GLFW.MakeContextCurrent(wnd.handle))
destroy(wnd::Window) = GLFW.DestroyWindow(wnd.handle)

function setfullscreen!(wnd::Window, monitor::Monitor)
    wnd.monitor = monitor
    vidmode = getvideomode(monitor)
    GLFW.SetWindowMonitor(wnd.handle, monitor.handle, 0, 0, vidmode.width, vidmode.height, vidmode.refreshrate)
    wnd
end
function clearfullscreen!(wnd::Window)
    wnd.monitor = nothing
    width, height = size(wnd)
    GLFW.SetWindowMonitor(wnd.handle, C_NULL, 0, 0, width, height, GLFW.DONT_CARE)
    wnd
end
isfullscreen(wnd::Window) = wnd.monitor !== nothing

setmonitor!(wnd::Window, monitor::Monitor) = setfullscreen!(wnd, monitor)
setmonitor!(wnd::Window, ::Nothing) = clearfullscreen!(wnd)
getmonitor(wnd::Window) = wnd.monitor

setvsync(interval::Integer = 1) = GLFW.SwapInterval(interval)
clearvsync() = setvsync(0)
flip() = GLFW.SwapBuffers(activewindow().handle)

function enabletransparency()
    ModernGL.glEnable(ModernGL.GL_BLEND)
    ModernGL.glBlendFunc(ModernGL.GL_SRC_ALPHA, ModernGL.GL_ONE_MINUS_SRC_ALPHA)
end
function disabletransparency()
    ModernGL.glDisable(ModernGL.GL_BLEND)
end

"""
Initializes the currently active window. Sets VSync to 1, enables transparency and sets
background color to black.
"""
function initwindow()
    setvsync()
    enabletransparency()
    setbgcolor(Black3)
end

wantsclose() = _wantsclose || GLFW.WindowShouldClose(activewindow().handle)
wantsclose(value::Bool) = (global _wantsclose; _wantsclose = value)
_wantsclose = false
