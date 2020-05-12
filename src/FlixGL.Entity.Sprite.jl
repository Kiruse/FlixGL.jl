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
    LowLevel.destroy(vao.internal)
    LowLevel.destroy(vao.vbo_coords)
    LowLevel.destroy(vao.vbo_uvs)
end


mutable struct Sprite2DMaterial <: AbstractMaterial
    texture::AbstractTexture
    taint::NormColor
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


mutable struct Sprite2D <: AbstractEntity2D
    vao::Sprite2DVAO
    transform::Transform2D
    material::AbstractMaterial
    vertices::Vector{Sprite2DVertex}
    
    function Sprite2D(vao, transform, material, vertices)
        inst = new(vao, transform, material, vertices)
        transform.customdata = inst
        inst
    end
end

function Sprite2D(width::Integer,
                  height::Integer,
                  tex::Texture2D;
                  frame::Rect = Rect{Float32}(0, 0, 1, 1),
                  taint::Color = White+Alpha,
                  originoffset::Union{Vector2, NTuple{2, <:Real}} = (0, 0),
                  static::Bool = true,
                  transform::Transform2D = Transform2D{Float64}()
                 )
    verts = getspriteverts((width, height), originoffset, frame)
    Sprite2D(upload(verts, static=static), transform, Sprite2DMaterial(tex, taint), verts)
end

countverts(::Sprite2D) = 4
drawmodeof(::Sprite2D) = LowLevel.TriangleFanDrawMode

function upload(coords, uvs; static::Bool = true)
    frequency, nature = getbufferusage(static, false)
    
    vao = LowLevel.vertexarray()
    vbo_coords = LowLevel.buffer(coords, frequency, nature)
    vbo_uvs    = LowLevel.buffer(uvs,    frequency, nature)
    bind(vao, vbo_coords, 0, 2)
    bind(vao, vbo_uvs,    1, 2)
    Sprite2DVAO(vao, vbo_coords, vbo_uvs, static)
end

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

function update!(sprite::Sprite2D; size = nothing, originoffset = (0, 0), uvs::Optional{Rect} = nothing, tex::Optional{Texture2D} = nothing, taint::Optional{<:Color} = nothing)
    if size != nothing && uvs != nothing
        @assert !sprite.vao.static
        coords = update_sprite_coords(sprite, size, originoffset)
        uvs    = update_sprite_uvs(sprite, uvs)
        for i ∈ 1:4
            x, y = coords[2i-1:2i]
            u, v = uvs[   2i-1:2i]
            sprite.vertices[i] = Sprite2DVertex(x, y, u, v)
        end
    elseif size != nothing
        @assert !sprite.vao.static
        coords = update_sprite_coords(sprite, size, originoffset)
        for i ∈ 1:4
            x, y = coords[2i-1:2i]
            u, v = sprite.vertices[i].uvs
            sprite.vertices[i] = Sprite2DVertex(x, y, u, v)
        end
    elseif uvs != nothing
        @assert !sprite.vao.static
        uvs = update_sprite_uvs(sprite, uvs)
        for i ∈ 1:4
            x, y = sprite.vertices[i].coords
            u, v = uvs[2i-1:2i]
            sprite.vertices[i] = Sprite2DVertex(x, y, u, v)
        end
    end
    
    if tex != nothing
        sprite.material.texture = tex
    end
    
    if taint != nothing
        sprite.material.taint = taint
    end
    
    sprite
end

function update_sprite_coords(sprite::Sprite2D, size, originoffset)
    coords = getspritecoords(size, originoffset)
    LowLevel.buffer_update(sprite.vao.vbo_coords, coords)
    coords
end

function update_sprite_uvs(sprite::Sprite2D, frame::Rect)
    uvs = getspriteuvs(frame)
    LowLevel.buffer_update(sprite.vao.vbo_uvs, uvs)
    uvs
end

function getspriteverts(size, originoffset, frame::Rect)
    coords = getspritecoords(size, originoffset)
    uvs    = getspriteuvs(frame)
    [((x, y) = coords[i:i+1]; (u, v) = uvs[i:i+1]; Sprite2DVertex(x, y, u, v)) for i ∈ 1:2:8]
end

function getspritecoords(size, originoffset)
    halfwidth, halfheight = size ./ 2
    offx, offy = originoffset .* (halfwidth, halfheight)
    Float32[
        -halfwidth + offx, -halfheight + offy,
         halfwidth + offx, -halfheight + offy,
         halfwidth + offx,  halfheight + offy,
        -halfwidth + offx,  halfheight + offy
    ]
end

function getspriteuvs(frame::Rect)
    Float32[
        frame.min[1], frame.min[2],
        frame.max[1], frame.min[2],
        frame.max[1], frame.max[2],
        frame.min[1], frame.max[2]
    ]
end


# Globals

prog_sprite2d = nothing

# Constants

const unidTaint = UniformIdentifier("uniTaint")
