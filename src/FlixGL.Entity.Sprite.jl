export Sprite2D, update!

struct Sprite2DVertex <: AbstractVertex
    coords::Vector2{Float32}
    uvs::Vector2{Float32}
end
Sprite2DVertex(x, y, u, v) = Sprite2DVertex(Vector2(Float32(x), Float32(y)), Vector2(Float32(u), Float32(v)))

struct Sprite2DVAO <: AbstractVertexArrayData
    internal::LowLevel.VertexArray
    vbo_coords::LowLevel.PrimitiveArrayBuffer{Float32}
    vbo_uvs::LowLevel.PrimitiveArrayBuffer{Float32}
    static::Bool
end

function destroy(vao::Sprite2DVAO)
    LowLevel.destroy(internal)
    LowLevel.destroy(vbo_coords)
    LowLevel.destroy(vbo_uvs)
end


struct Sprite2DMaterial <: AbstractMaterial
    texture::AbstractTexture
    taint::Color
end

function programof(::Type{Sprite2DMaterial})
    LL = LowLevel
    global prog_sprite2d
    if prog_sprite2d == nothing
        prog_sprite2d = LL.program(LL.shader(LL.VertexShader, "$dir_shaders/sprite2d.vertex.glsl"), LL.shader(LL.FragmentShader, "$dir_shaders/sprite2d.fragment.glsl"))
    end
    prog_sprite2d
end

function use(mat::Sprite2DMaterial)
    LowLevel.use(programof(mat))
    LowLevel.use(mat.texture.internal)
    LowLevel.uniform(resolve!(unidTaint, mat), collect(mat.taint)...)
end


struct Sprite2D <: AbstractEntity2D
    vao::Sprite2DVAO
    transform::Transform2D
    material::AbstractMaterial
end

function Sprite2D(width::Integer, height::Integer, tex::Texture2D; frame::Rect = Rect{Float32}(0, 0, 1, 1), taint::Color = White+Alpha, static::Bool = true, transform::Transform2D = Transform2D())
    halfwidth  = width/2
    halfheight = height/2
    verts = [
        Sprite2DVertex(-halfwidth, -halfheight, frame.min[1], frame.min[2]),
        Sprite2DVertex( halfwidth, -halfheight, frame.max[1], frame.min[2]),
        Sprite2DVertex( halfwidth,  halfheight, frame.max[1], frame.max[2]),
        Sprite2DVertex(-halfwidth,  halfheight, frame.min[1], frame.max[2])
    ]
    Sprite2D(upload(verts, static=static), transform, Sprite2DMaterial(tex, taint))
end

countverts(::Sprite2D) = 4
drawmodeof(::Sprite2D) = LowLevel.TriangleFanDrawMode

function upload(verts::AbstractVector{Sprite2DVertex}; static::Bool = true)
    frequency, nature = getbufferusage(static, false)
    
    vao = LowLevel.vertexarray()
    buffercurry = curry(LowLevel.buffer, LowLevel.PrimitiveArrayBuffer{Float32}, verts, frequency, nature)
    vbo_coords = buffercurry(mapper=vert->vert.coords)
    vbo_uvs    = buffercurry(mapper=vert->vert.uvs)
    bind(vao, vbo_coords, 0, 2)
    bind(vao, vbo_uvs,    1, 2)
    Sprite2DVAO(vao, vbo_coords, vbo_uvs, static)
end

function update!(sprite::Sprite2D; verts::Optional{AbstractVector{Sprite2DVertex}} = nothing, tex::Optional{Texture2D} = nothing, taint::Optional{<:Color} = nothing)
    if verts != nothing
        @assert !sprite.vao.static
        LowLevel.buffer_update(sprite.vao.vbo_coords, verts, mapper=vert->vert.coords)
        LowLevel.buffer_update(sprite.vao.vbo_uvs,    verts, mapper=vert->vert.uvs)
    end
    
    if tex != nothing
        sprite.material.texture = tex
    end
    
    if taint != nothing
        sprite.material.taint = taint
    end
    
    sprite
end


# Constants
prog_sprite2d = nothing
const unidTaint = UniformIdentifier("uniTaint")
