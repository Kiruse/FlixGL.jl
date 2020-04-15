export DecoderError

struct DecoderError <: Exception
    msg::Union{AbstractString, Missing}
end
DecoderError() = DecoderError(missing)

function Base.show(io::IO, err::DecoderError)
    if err.msg == missing
        write(io, "Decoder error")
    else
        write(io, "Decoder error: $(err.msg)")
    end
end
