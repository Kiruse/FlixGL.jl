import ModernGL

module ProgramParameter
    import ModernGL
    @enum(Values,
        DeleteStatus                = ModernGL.GL_DELETE_STATUS,
        LinkStatus                  = ModernGL.GL_LINK_STATUS,
        ValidateStatus              = ModernGL.GL_VALIDATE_STATUS,
        InfoLogLength               = ModernGL.GL_INFO_LOG_LENGTH,
        AttachedShaders             = ModernGL.GL_ATTACHED_SHADERS,
        ActiveAtomicCounterBuffers  = ModernGL.GL_ACTIVE_ATOMIC_COUNTER_BUFFERS,
        ActiveAttributes            = ModernGL.GL_ACTIVE_ATTRIBUTES,
        ActiveAttributeMaxLength    = ModernGL.GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
        ActiveUniforms              = ModernGL.GL_ACTIVE_UNIFORMS,
        ActiveUniformMaxLength      = ModernGL.GL_ACTIVE_UNIFORM_MAX_LENGTH,
        ProgramBinaryLength         = ModernGL.GL_PROGRAM_BINARY_LENGTH,
        TransformFeedbackBufferMode = ModernGL.GL_TRANSFORM_FEEDBACK_BUFFER_MODE,
        TransformFeedbackVaryings   = ModernGL.GL_TRANSFORM_FEEDBACK_VARYINGS,
        GeometryVerticesOut         = ModernGL.GL_GEOMETRY_VERTICES_OUT,
        GeometryInputType           = ModernGL.GL_GEOMETRY_INPUT_TYPE,
        GeometryOutputType          = ModernGL.GL_GEOMETRY_OUTPUT_TYPE
    )
end
module ShaderParameter
    import ModernGL
    @enum(Values,
        ShaderType         = ModernGL.GL_SHADER_TYPE,
        DeleteStatus       = ModernGL.GL_DELETE_STATUS,
        CompileStatus      = ModernGL.GL_COMPILE_STATUS,
        InfoLogLength      = ModernGL.GL_INFO_LOG_LENGTH,
        ShaderSourceLength = ModernGL.GL_SHADER_SOURCE_LENGTH
    )
end
import .ProgramParameter
import .ShaderParameter


function getiv(prog::Program, param::ProgramParameter.Values)
    res = Ref{Int32}(0)
    ModernGL.glGetProgramiv(glid(prog), param, res)
    res[]
end

function getiv(shdr::AbstractShader, param::ShaderParameter.Values)
    res = Ref{Int32}(0)
    ModernGL.glGetShaderiv(glid(shdr), param, res)
    res[]
end

function getinfolog(prog::Program)
    len = getiv(prog, ProgramParameter.InfoLogLength)
    res = zeros(UInt8, len)
    ModernGL.glGetProgramInfoLog(glid(prog), len, C_NULL, pointer(res))
    checkglerror()
    return unsafe_string(pointer(res))
end

function getinfolog(shdr::AbstractShader)
    len = getiv(shdr, ShaderParameter.InfoLogLength)
    res = zeros(UInt8, len)
    ModernGL.glGetShaderInfoLog(glid(shdr), len, C_NULL, pointer(res))
    checkglerror()
    return unsafe_string(pointer(res))
end

function getshadersource(shdr::AbstractShader)
    srclen = getiv(shdr, ShaderParameter.ShaderSourceLength)
    srcbytes = zeros(UInt8, srclen)
    ModernGL.glGetShaderSource(glid(shdr), srclen, C_NULL, pointer(srcbytes))
    checkglerror()
    return unsafe_string(pointer(srcbytes))
end
