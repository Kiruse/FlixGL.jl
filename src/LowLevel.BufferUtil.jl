import ModernGL

module BufferParameter
    import ModernGL
    @enum(Values,
        Access      = ModernGL.GL_BUFFER_ACCESS,
        AccessFlags = ModernGL.GL_BUFFER_ACCESS_FLAGS,
        Mapped      = ModernGL.GL_BUFFER_MAPPED,
        MapLength   = ModernGL.GL_BUFFER_MAP_LENGTH,
        MapOffset   = ModernGL.GL_BUFFER_MAP_OFFSET,
        Size        = ModernGL.GL_BUFFER_SIZE,
        Usage       = ModernGL.GL_BUFFER_USAGE
    )
end
import .BufferParameter

function getiv(buff::AbstractBuffer, param::BufferParameter.Values)
    res = Ref{Int64}()
    use(buff)
    ModernGL.glGetBufferParameteri64v(gltype(typeof(buff)), param, res)
    checkglerror()
    res[]
end
