import ModernGL

export AbstractShader, VertexShader, FragmentShader, GeometryShader, Program
export shader, program

abstract type AbstractShader <: AbstractGLResource end

struct VertexShader   <: AbstractShader glid::Integer end
struct FragmentShader <: AbstractShader glid::Integer end
struct GeometryShader <: AbstractShader glid::Integer end
gltype(::Type{<:AbstractShader}) = error("Unknown shader type")
gltype(::Type{VertexShader})   = ModernGL.GL_VERTEX_SHADER
gltype(::Type{FragmentShader}) = ModernGL.GL_FRAGMENT_SHADER
gltype(::Type{GeometryShader}) = ModernGL.GL_GEOMETRY_SHADER

struct Program <: AbstractGLResource glid::Integer end


function shader(shader_t::Type{<:AbstractShader}, src::AbstractString; is_filepath::Bool = true)
    shdr = shader(shader_t)
    if is_filepath
        src = load_shader_source(src)
    end
    shader_source(shdr, src)
    shader_compile(shdr)
    return shdr
end

function shader(shader_t::Type{<:AbstractShader})
    shdr = shader_t(ModernGL.glCreateShader(gltype(shader_t)))
    checkglerror()
    return shdr
end

function load_shader_source(path::AbstractString)
    open(path, "r") do file
        read(file, String)
    end
end

function shader_source(shdr::AbstractShader, src::AbstractString)
    sources = [pointer(src)]
    lengths = [length(src)]
    ModernGL.glShaderSource(glid(shdr), length(sources), pointer(sources), pointer(lengths))
    checkglerror()
end

function shader_compile(shdr::AbstractShader)
    ModernGL.glCompileShader(glid(shdr))
    checkglerror()
    if getiv(shdr, ShaderParameter.CompileStatus) == 0
        error("Failed to compile shader: '$(getinfolog(shdr))'")
    end
end

function destroy(shdr::AbstractShader)
    ModernGL.glDeleteShader(glid(shdr))
    checkglerror()
end


function program(shaders::Vararg{<:AbstractShader}; autodelete_shaders::Bool = true)
    prog = program()
    for shdr in shaders
        program_attach(prog, shdr)
    end
    
    program_link(prog)
    
    for shdr in shaders
        program_detach(prog, shdr)
        if autodelete_shaders
            destroy(shdr)
        end
    end
    
    return prog
end

function program()
    prog = Program(ModernGL.glCreateProgram())
    checkglerror()
    return prog
end

function program_attach(prog::Program, shdr::AbstractShader)
    ModernGL.glAttachShader(glid(prog), glid(shdr))
    checkglerror()
end

function program_link(prog::Program)
    ModernGL.glLinkProgram(glid(prog))
    checkglerror()
    if getiv(prog, ProgramParameter.LinkStatus) == 0
        error("Failed to link program: '$(getinfolog(prog))'")
    end
end

function program_detach(prog::Program, shdr::AbstractShader)
    ModernGL.glDetachShader(glid(prog), glid(shdr))
    checkglerror()
end

function destroy(prog::Program)
    ModernGL.glDeleteProgram(glid(prog))
    checkglerror()
end

function use(prog::Program)
    ModernGL.glUseProgram(glid(prog))
    checkglerror()
end
