using LinearAlgebra

function render(::Type{ForwardRenderPipeline}, cam::Camera2D, ntts::AbstractArray{<:AbstractEntity2D})
    vphalfsize = size(activewindow()) ./ 2
    
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
        screenmat = screentransformmatrix(ntt, cam, vphalfsize)
        
        use(mat)
        # NOTE: Use of global Uniform Identifier is pointless as the uniform location depends on program.
        LowLevel.uniform(LowLevel.finduniform(programof(mat), "uniScreenTransform"), screenmat)
        LowLevel.draw(internalvao(vao), drawmodeof(ntt), countverts(ntt))
    end
end

function screentransformmatrix(ntt::AbstractEntity2D, cam::Camera2D, vphalfsize)
    scale = 1 ./ vphalfsize
    scalematrix(Vector2{Float32}(scale...)) * world2obj(cam) * obj2world(ntt)
end
screentransformmatrix(ntt::AbstractEntity2D, cam::Camera2D) = screentransformmatrix(ntt, cam, size(activewindow())./2)
