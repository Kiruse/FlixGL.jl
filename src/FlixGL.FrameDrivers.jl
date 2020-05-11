export FrameDriver
export getframesize, getframeuvs

mutable struct FrameDriver
    imgw::Integer
    imgh::Integer
    framew::Integer
    frameh::Integer
    frameidx::Integer
    framecount::Integer
    frameinterval::Integer
    frametime::AbstractFloat
    callback
    
    function FrameDriver(imgw,
                         imgh,
                         framew,
                         frameh;
                         frameidx = 1,
                         framecount = 1,
                         frameinterval = 0,
                         frametime = 0,
                         callback = nothing
                        )
        fpr = imgw ÷ framew
        nr  = imgh ÷ frameh
        @assert fpr * nr >= framecount  "Frame count ($framecount) exceeds total number of frames ($(fpr*nr))"
        frameidx = clamp(frameidx, 1, framecount)
        new(imgw, imgh, framew, frameh, frameidx, framecount, frameinterval, frametime, callback)
    end
end

function tick!(driver::FrameDriver, dt::AbstractFloat)
    if driver.frameinterval > 0
        driver.frametime += dt
        if driver.frametime >= driver.frameinterval
            driver.frametime -= driver.frameinterval
            
            driver.frameidx += 1
            if driver.frameidx > driver.framecount
                driver.frameidx = 1
            end
            if driver.callback != nothing
                driver.callback(driver.frameidx, getframeuvs(driver))
            end
        end
    end
end

getframesize(driver::FrameDriver) = (driver.framew/driver.imgw, driver.frameh/driver.imgh)
setframe!(driver::FrameDriver, idx::Integer) = (@assert(driver.framecount >= idx, "Frame out of bounds"); driver.frameidx = idx)
getframe(driver::FrameDriver) = driver.frameidx

function getframeuvs(driver::FrameDriver)
    du, dv = getframesize(driver)
    fpr = driver.imgw ÷ driver.framew
    
    idx = driver.frameidx - 1
    row = idx ÷ fpr
    idx = idx % fpr
    
    u0 = du * idx
    v0 = dv * row
    Rect{Float32}(u0, v0, u0+du, v0+dv)
end
