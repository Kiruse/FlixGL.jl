export AbstractMaterial

abstract type AbstractMaterial end

use(::AbstractMaterial) = nothing


# Material -> low level Program

function programof(mat::AbstractMaterial)
    if hasproperty(mat, :program)
        mat.program
    else
        programof(typeof(mat))
    end
end
programof(::Type{<:AbstractMaterial}) = error("Not implemented")
