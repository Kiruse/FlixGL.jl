function render(::Type{ForwardRenderPipeline}, ntts::AbstractArray{<:AbstractEntity})
    for ntt ∈ ntts
        mat = materialof(ntt)
        vao = vaoof(ntt)
        
        LowLevel.use(programof(mat))
        LowLevel.draw(vao.vao, drawmodeof(ntt), length(ntt.vertices))
    end
end
