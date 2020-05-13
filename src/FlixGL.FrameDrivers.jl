export FrameDriver
export getframesize, getframeuvs, setframe!, getframe

mutable struct FrameDriver
    imgw::Integer
    imgh::Integer
    framew::Integer
    frameh::Integer
    idx::Integer
    count::Integer
    interval::Integer
    time::AbstractFloat
    callback
    
    function FrameDriver(imgw,
                         imgh,
                         framew,
                         frameh;
                         idx = 1,
                         count = 1,
                         interval = 0,
                         time = 0,
                         callback = nothing
                        )
        fpr = imgw ÷ framew
        nr  = imgh ÷ frameh
        @assert fpr * nr >= count  "Frame count ($count) exceeds total number of frames ($(fpr*nr))"
        idx = clamp(idx, 1, count)
        new(imgw, imgh, framew, frameh, idx, count, interval, time, callback)
    end
end

function VPECore.tick!(driver::FrameDriver, dt::AbstractFloat)
    if driver.interval > 0
        driver.time += dt
        if driver.time >= driver.interval
            driver.time -= driver.interval
            
            driver.idx += 1
            if driver.idx > driver.count
                driver.idx = 1
            end
            if driver.callback != nothing
                driver.callback(driver.idx, getframeuvs(driver))
            end
        end
    end
end

getframesize(driver::FrameDriver) = (driver.framew/driver.imgw, driver.frameh/driver.imgh)
setframe!(driver::FrameDriver, idx::Integer) = (@assert(driver.count >= idx, "Frame out of bounds"); driver.idx = idx)
getframe(driver::FrameDriver) = driver.idx

function getframeuvs(driver::FrameDriver)
    du, dv = getframesize(driver)
    fpr = driver.imgw ÷ driver.framew
    
    idx = driver.idx - 1
    row = idx ÷ fpr
    idx = idx % fpr
    
    u0 = du * idx
    v0 = 1 - dv * (row+1)
    Rect{Float32}(u0, v0, u0+du, v0+dv)
end
