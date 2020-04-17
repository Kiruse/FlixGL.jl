function render(::Type{ForwardRenderPipeline}, cam::Camera2D, ntts::AbstractArray{<:AbstractEntity2D})
    vpsize = size(activewindow()) .÷ 2
    
    for ntt ∈ ntts
        mat = materialof(ntt)
        vao = vaoof(ntt)
        screentf = screentransform(ntt, cam, vpsize)
        
        LowLevel.use(programof(mat))
        LowLevel.uniform(0, asmatrix(screentf))
        LowLevel.draw(vao.vao, drawmodeof(ntt), length(ntt.vertices))
    end
end

function screentransform(ntt::AbstractEntity2D, cam::Camera2D, vphalfsize)
    transform = transformof(ntt)::Transform2D
    offset    = transform.location - cam.transform.location
    rotation  = transform.rotation - cam.transform.rotation
    scale     = transform.scale ./ cam.transform.scale ./ vphalfsize
    Transform2D(offset, rotation, scale)
end
screentransform(ntt::AbstractEntity2D, cam::Camera2D) = screentransform(ntt, cam, size(activewindow()).÷2)
