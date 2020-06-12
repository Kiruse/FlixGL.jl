using LinearAlgebra

"""
Render a simple background color. This differs from the clear color as it allows transparency on objects above nothing else.
"""
function render_background(::Type{ForwardRenderPipeline})
    render(ForwardRenderPipeline, ScreenRenderSpace, getbgsprite())
    
end

function render(::Type{ForwardRenderPipeline}, ::Type{ScreenRenderSpace}, ntts)
    foreach(ntt->render(ForwardRenderPipeline, ScreenRenderSpace, ntt), ntts)
end

function render(::Type{ForwardRenderPipeline}, ::Type{ScreenRenderSpace}, ntt::AbstractEntity)
    vphalfsize = size(activewindow()) ./ 2
    screenscalemat = scalematrix3(Float32, 1 ./ vphalfsize) * obj2world(ntt)
    
    mat = materialof(ntt)
    vao = vaoof(ntt)
    
    use(mat)
    LowLevel.uniform(LowLevel.finduniform(programof(mat), "uniScreenTransform"), screenscalemat)
    LowLevel.draw(internalvao(vao), drawmodeof(ntt), countverts(ntt))
end

function render(::Type{ForwardRenderPipeline}, ::Type{WorldRenderSpace}, cam::Camera2D, ntts)
    vphalfsize = size(activewindow()) ./ 2
    
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
    scalematrix3(Float32, scale) * world2obj(cam) * obj2world(ntt)
end
screentransformmatrix(ntt::AbstractEntity2D, cam::Camera2D) = screentransformmatrix(ntt, cam, size(activewindow())./2)
