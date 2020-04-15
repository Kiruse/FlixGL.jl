export curry

curry(fn, curryargs...; kwcurryargs...) = (moreargs...; kwargs...) -> fn(curryargs..., moreargs...; kwcurryargs..., kwargs...)
