import GLFW
export Monitor, Monitors
export getname, getvideomode, getvideomodes, getphysicalsize, getdpi

struct Monitors end

struct Monitor
    handle::GLFW.Monitor
    index::UInt8
end
Monitor(idx::Integer) = Monitor(GLFW.GetMonitors()[idx], idx)

Base.length(::Type{Monitors}) = length(GLFW.GetMonitors())

function Base.iterate(::Type{Monitors})
    monitors = GLFW.GetMonitors()
    Monitor(monitors[1], 1), (monitors, 1)
end

function Base.iterate(::Type{Monitors}, state)
    monitors, idx = state
    idx += 1
    if idx > length(monitors)
        nothing
    else
        Monitor(monitors[idx], idx), (monitors, idx)
    end
end

getname(monitor::Monitor) = GLFW.GetMonitorName(monitor.handle)

getvideomode(monitor::Monitor)  = GLFW.GetVideoMode(monitor.handle)
getvideomodes(monitor::Monitor) = GLFW.GetVideoModes(monitor.handle)

getphysicalsize(monitor::Monitor) = (size = GLFW.GetMonitorPhysicalSize(monitor.handle); (size.width, size.height))
getdpi(monitor::Monitor, videomode::GLFW.VidMode) = round.(Int, (videomode.width, videomode.height) ./ mm2in.(getphysicalsize(monitor)))
getdpi(monitor::Monitor) = getdpi(monitor, getvideomode(monitor))
