export AbstractCamera
export Camera2D

abstract type AbstractCamera end

struct Camera2D{T} <: AbstractCamera
    transform::Transform2D{T}
end
Camera2D{T}() where T = Camera2D{T}(Transform2D{T}())
Camera2D() = Camera2D{Float64}()

VPECore.obj2world(cam::AbstractCamera) = obj2world(cam.transform)
VPECore.world2obj(cam::AbstractCamera) = world2obj(cam.transform)
VPECore.update(cam::AbstractCamera) = update(cam.transform)
