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
    @assert ModernGL.glGetError() == 0
    return shdr
end

function load_shader_source(path::AbstractString)
    open(path, "r") do file
        read(file, String)
    end
end

function shader_source(shdr::AbstractShader, src::AbstractString)
    sources = [src]
    ModernGL.glShaderSource(glid(shdr), length(sources), pointer(sources), C_NULL)
    @assert ModernGL.glGetError() == 0
end

function shader_compile(shdr::AbstractShader)
    ModernGL.glCompileShader(glid(shdr))
    @assert ModernGL.glGetError() == 0
end

function destroy(shdr::AbstractShader)
    ModernGL.glDeleteShader(glid(shdr))
    @assert ModernGL.glGetError() == 0
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
    @assert ModernGL.glGetError() == 0
    return prog
end

function program_attach(prog::Program, shdr::AbstractShader)
    ModernGL.glAttachShader(glid(prog), glid(shdr))
    @assert ModernGL.glGetError() == 0
end

function program_link(prog::Program)
    ModernGL.glLinkProgram(glid(prog))
    @assert ModernGL.glGetError() == 0
end

function program_detach(prog::Program, shdr::AbstractShader)
    ModernGL.glDetachShader(glid(prog), glid(shdr))
    @assert ModernGL.glGetError() == 0
end

function destroy(prog::Program)
    ModernGL.glDeleteProgram(glid(prog))
    @assert ModernGL.glGetError() == 0
end

function use(prog::Program)
    ModernGL.glUseProgram(glid(prog))
    @assert ModernGL.glGetError() == 0
end
