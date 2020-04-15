export AbstractRenderPipeline, ForwardRenderPipeline, DeferredRenderPipeline
export render

abstract type AbstractRenderPipeline end
struct ForwardRenderPipeline <: AbstractRenderPipeline end
struct DeferredRenderPipeline <: AbstractRenderPipeline end

render(pipe_t::Type{<:AbstractRenderPipeline}, args...; kwargs...) = error("Render Pipeline $pipe_t not implemented")
