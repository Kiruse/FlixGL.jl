export AbstractRenderPipeline, ForwardRenderPipeline, DeferredRenderPipeline
export render

abstract type AbstractRenderPipeline end
struct ForwardRenderPipeline <: AbstractRenderPipeline end
struct DeferredRenderPipeline <: AbstractRenderPipeline end
