import GLFW
export Monitor, Monitors
export getvideomode, getvideomodes, getphysicalsize, getdpi

struct Monitors end

struct Monitor
    handle::GLFW.Monitor
end

function Base.iterate(::Type{Monitors})
    monitors = GLFW.GetMonitors()
    Monitor(monitors[1]), (monitors, 1)
end

function Base.iterate(::Type{Monitors}, state)
    monitors, idx = state
    idx += 1
    if idx > length(monitors)
        nothing
    else
        Monitor(monitors[idx]), (monitors, idx)
    end
end

getvideomode(monitor::Monitor)  = GLFW.GetVideoMode(monitor.handle)
getvideomodes(monitor::Monitor) = GLFW.GetVideoModes(monitor.handle)

getphysicalsize(monitor::Monitor) = (size = GLFW.GetMonitorPhysicalSize(monitor.handle); (size.width, size.height))
getdpi(monitor::Monitor, videomode::GLFW.VidMode) = (videomode.width, videomode.height) .÷ getphysicalsize(monitor)
getdpi(monitor::Monitor) = getdpi(monitor, getvideomode(monitor))
