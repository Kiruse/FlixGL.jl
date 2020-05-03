export DecoderError

struct DecoderError <: Exception
    msg::Optional{AbstractString}
end
DecoderError() = DecoderError(nothing)

function Base.show(io::IO, err::DecoderError)
    if err.msg == nothing
        write(io, "Decoder error")
    else
        write(io, "Decoder error: $(err.msg)")
    end
end
