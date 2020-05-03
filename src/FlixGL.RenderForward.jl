using LinearAlgebra

function render(::Type{ForwardRenderPipeline}, cam::Camera2D, ntts::AbstractArray{<:AbstractEntity2D})
    vpsize = size(activewindow()) ./ 2
    
    # Render background sprite
    bgsprite = getbgsprite()
    mat = materialof(bgsprite)
    vao = vaoof(bgsprite)
    
    use(mat)
    LowLevel.uniform(LowLevel.finduniform(programof(mat), "uniScreenTransform"), Matrix3{Float32}(I))
    LowLevel.draw(internalvao(vao), drawmodeof(bgsprite), countverts(bgsprite))
    
    # Render given entities
    for ntt ∈ ntts
        mat = materialof(ntt)
        vao = vaoof(ntt)
        screentf = screentransform(ntt, cam, vpsize)
        
        use(mat)
        # NOTE: Use of global Uniform Identifier is pointless as the uniform location depends on program.
        LowLevel.uniform(LowLevel.finduniform(programof(mat), "uniScreenTransform"), asmatrix(screentf))
        LowLevel.draw(internalvao(vao), drawmodeof(ntt), countverts(ntt))
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
