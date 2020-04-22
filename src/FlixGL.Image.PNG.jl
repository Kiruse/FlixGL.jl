export PNGImageFormat

struct PNGImageFormat <: AbstractImageFormat end

function decode(::Type{PNGImageFormat}, data::AbstractArray{UInt8})
    INTERNAL = PNGImageFormatInternal
    buff        = IOBuffer(data)
    has_palette = false
    
    INTERNAL.check_magic(buff)
    
    chunktype, chunkdata = INTERNAL.readchunk(buff)
    if chunktype != "IHDR" throw(DecoderError("IHDR chunk must occur first")) end
    width, height, bits, colortype, compression, filter, interlacing = INTERNAL.readchunk_IHDR(chunkdata)
    
    # TODO: Interlacing currently not supported
    if interlacing != 0 throw(DecoderError("Interlacing is currently not supported")) end
    
    # Parse palette if any
    # Required if color type 3
    chunktype, chunkdata = INTERNAL.find_next_critical_chunk(buff)
    if chunktype == "PLTE"
        palette = readchunk_PLTE(chunkdata)
        has_palette = true
        chunktype, chunkdata = INTERNAL.find_next_critical_chunk(buff)
    elseif colortype == 3
        throw(DecoderError("No palette found for indexed color type"))
    end
    
    # Accumulate compressed pixel data
    if chunktype != "IDAT" throw(DecoderError("No IDAT chunk found")) end
    pixeldata = UInt8[]
    while chunktype == "IDAT"
        pixeldata = vcat(pixeldata, chunkdata)
        chunktype, chunkdata = INTERNAL.readchunk(buff)
    end
    
    # Decompress pixel data
    pixeldata = transcode(ZlibDecompressor, pixeldata)
    
    # Decode pixel data
    if has_palette
        pixels = INTERNAL.decode_pixeldata(pixeldata, width, height, bits, colortype, palette)
    else
        pixels = INTERNAL.decode_pixeldata(pixeldata, width, height, bits, colortype)
    end
    
    # Skip any ancillary chunks
    if !INTERNAL.isupper(chunktype[1])
        chunktype, chunkdata = INTERNAL.find_next_critical_chunk(buff)
    end
    
    if chunktype != "IEND"
        if chunktype == "IDAT"
            throw(DecoderError("IDAT chunks must be consecutive without any other chunk interspersed"))
        end
        throw(DecoderError("Unexpected critical chunk that is not IEND"))
    end
    INTERNAL.readchunk_IEND(chunkdata)
    return Image2D(pixels)
end


module PNGImageFormatInternal
using ..FlixGL

function check_magic(buff::IOBuffer)
    magic = (0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)
    readmagic = read(buff, length(magic))
    
    for i ∈ 1:length(magic)
        if magic[i] != readmagic[i] throw(DecoderError("Magic bytes mismatch")) end
    end
end

function find_next_critical_chunk(data::IOBuffer)
    chunktype, chunkdata = readchunk(data)
    while !isupper(chunktype[1])
        chunktype, chunkdata = readchunk(data)
    end
    return chunktype, chunkdata
end

function readchunk(data::IOBuffer)
    chunklen  = ntoh(read(data, UInt32))
    chunktype = read(data, 4)
    chunkdata = read(data, chunklen)
    chunkcrc  = read(data, 4)
    if length(chunktype) == 0 || length(chunkdata) != chunklen throw(EOFError()) end
    chunktype = unsafe_string(pointer(chunktype))
    # TODO: Option to compute CRC
    return (chunktype, chunkdata, chunkcrc)
end

function readchunk_IHDR(data)
    data    = IOBuffer(data)
    width   = ntoh(read(data, Int32))
    height  = ntoh(read(data, Int32))
    bits    = read(data, Int8)
    coltype = read(data, Int8)
    compr   = read(data, Int8)
    filter  = read(data, Int8)
    interl  = read(data, Int8)
    
    # Simple validation
    if bits ∉ (1, 2, 4, 8, 16) throw(DecoderError("Unexpected bit depth: must be 1, 2, 4, 8 or 16")) end
    if coltype ∉ (0, 2, 3, 4, 6) throw(DecoderError("Unexpected color type: must be 0, 2, 3, 4 or 6")) end
    if compr != 0 throw(DecoderError("Unexpected compression method: must be 0")) end
    if filter != 0 throw(DecoderError("Unexpected filter method: must be 0")) end
    if interl ∉ (0, 1) throw(DecoderError("Unexpected interlace method: must be either 0 or 1")) end
    
    # Dependent validation
    if coltype == 2
        if bits ∉ (8, 16) throw(DecoderError("Truecolor color type must have either 8 or 16 bits depth")) end
    elseif coltype == 3
        if bits ∉ (1, 2, 4, 8) throw(DecoderError("Indexed color type must have either 1, 2, 4 or 8 bits depth")) end
    elseif coltype == 4
        if bits ∉ (8, 16) throw(DecoderError("Grayscale/Alpha color type requires 8 or 16 bits depth")) end
    elseif coltype == 6
        if bits ∉ (8, 16) throw(DecoderError("Truecolor w/ alpha color type requires 8 or 16 bits depth")) end
    end
    
    return width, height, bits, coltype, compr, filter, interl
end

function readchunk_PLTE(data, bitdepth::Integer)
    if length(data) % 3 != 0
        throw(DecoderError("Invalid chunk data length"))
    end
    
    count    = length(chunkdata) / 3
    maxcount = typemax(inttype_from_bitdepth(bitdepth))
    data     = IOBuffer(data)
    
    palette = ByteColor3[]
    if count > maxcount
        throw(DecoderError("Expected at max $maxcount palette entries for bit depth $bitdepth, but got $count"))
    end
    
    for i ∈ 1:count
        red   = read(io, UInt8)
        green = read(io, UInt8)
        blue  = read(io, UInt8)
        push!(palette, ByteColor3(red, green, blue))
    end
    
    return palette
end

function readchunk_IEND(data)
    if length(data) != 0
        throw(DecoderError("Unexpected data in IEND chunk"))
    end
end

function decode_pixeldata(pixeldata::AbstractArray{UInt8}, width::Integer, height::Integer, bitdepth::Integer, colortype::Integer, palette::AbstractVector{ByteColor3} = ByteColor3[])
    io = IOBuffer(pixeldata)
    components = get_components_count(colortype)
    bpp        = bytes_per_pixel_for_filter(bitdepth, colortype)
    bpr        = bytes_per_scanline(bitdepth, colortype, width)
    pixeldata  = zeros(UInt8, height, bpr)
    filters    = zeros(UInt8, height)
    
    # Build filtered matrix
    for row ∈ 1:height
        filters[row] = read(io, UInt8)
        pixeldata[row, 1:bpr] = read(io, bpr)
    end
    
    # Revert filter -> build unfiltered matrix
    for row ∈ 1:height
        filter = filters[row]
        
        for col ∈ 1:bpr
            if filter == 1
                pixeldata[row, col] = unfilter_sub!(pixeldata, row, col, bpp)
            elseif filter == 2
                pixeldata[row, col] = unfilter_up!(pixeldata, row, col, bpp)
            elseif filter == 3
                pixeldata[row, col] = unfilter_average!(pixeldata, row, col, bpp)
            elseif filter == 4
                pixeldata[row, col] = unfilter_paeth!(pixeldata, row, col, bpp)
            else
                throw(DecoderError("Unknown filter algorithm $filter for scanline $row"))
            end
        end
    end
    
    # Build pixel matrix
    if colortype ∈ (4, 6)
        pixels = zeros(NormColor, height, width)
    else
        pixels = zeros(NormColor3, height, width)
    end
    
    if bitdepth < 8
        bits = bitpattern(bitdepth)
        for row ∈ 1:height
            for col ∈ 1:width
                byteidx = col ÷ 8 + 1 # Add one because Julia starts indexing at 1
                bitidx  = col % 8     # No need to add 1 because bit shifting by 0 addresses the first pixel in the byte
                value   = (pixeldata[row, byteidx] >> (8-bitidx-bitdepth)) & bits
                
                if colortype == 0
                    value = value / bits
                    pixels[row, col] = NormColor3(value, value, value)
                elseif colortype == 3
                    pixels[row, col] = palette[value]
                else
                    throw(DecoderError("Unknown color type $colortype with bitdepth $bitdepth < 8"))
                end
            end
        end
    else
        io = IOBuffer(transpose(pixeldata)[:])
        comp_t = inttype_from_bitdepth(bitdepth)
        
        for row ∈ 1:height
            for col ∈ 1:width
                if colortype == 0
                    value = read(io, comp_t)
                    pixels[row, col] = OpaqueColor{comp_t}(value, value, value)
                elseif colortype == 2
                    pixels[row, col] = OpaqueColor{comp_t}([read(io, comp_t) for _ ∈ 1:3]...)
                elseif colortype == 3
                    idx = read(io, comp_t)
                    pixels[row, col] = palette[idx]
                elseif colortype == 4
                    value = read(io, comp_t)
                    alpha = read(io, comp_t)
                    pixels[row, col] = Color{comp_t}(value, value, value, alpha)
                elseif colortype == 6
                    pixels[row, col] = Color{comp_t}([read(io, comp_t) for _ ∈ 1:4]...)
                else
                    throw(DecoderError("Unknown color type $colortype"))
                end
            end
        end
    end
    
    return pixels
end

function inttype_from_bitdepth(bitdepth::Integer)
    if bitdepth <= 8
        return UInt8
    elseif bitdepth == 16
        return UInt16
    elseif bitdepth == 32
        return UInt32
    elseif bitdepth == 64
        return UInt64
    else
        error("Unknown bit depth $bitdepth")
    end
end

function bitpattern(bitdepth::Integer)
    res = 1
    for _ ∈ 2:bitdepth
        res <<= 1 | 1
    end
    res
end

function filterpixel(bytes::AbstractArray{UInt8}, row::Integer, col::Integer)
    if row < 1 || col < 1
        return 0
    else
        return bytes[row, col]
    end
end

function get_components_count(colortype::Integer)
    if colortype == 0
        return 1
    elseif colortype == 2
        return 3
    elseif colortype == 3
        return 1
    elseif colortype == 4
        return 2
    elseif colortype == 6
        return 4
    else
        error("Unknown color type $colortype")
    end
end

unfilter_sub!(    bytes::AbstractArray{UInt8, 2}, row, col, bpp) = (bytes[row, col] + filterpixel(bytes, row, col-bpp)) % 256
unfilter_up!(     bytes::AbstractArray{UInt8, 2}, row, col, bpp) = (bytes[row, col] + filterpixel(bytes, row-1, col)) % 256
unfilter_average!(bytes::AbstractArray{UInt8, 2}, row, col, bpp) = (bytes[row, col] + floor((filterpixel(bytes, row, col-bpp) + filterpixel(bytes, row-1, col)) / 2)) % 256
unfilter_paeth!(  bytes::AbstractArray{UInt8, 2}, row, col, bpp) = (bytes[row, col] + paeth_predictor(filterpixel(bytes, row, col-bpp), filterpixel(bytes, row-1, col), filterpixel(bytes, row-1, col-bpp))) % 256

function paeth_predictor(l, u, ul)
    p   = Int64(l) + u - ul # Initial estimate
    pl  = abs(p - l)
    pu  = abs(p - u)
    pul = abs(p - ul)
    if pl <= pu && pl <= pul
        return l
    elseif pu <= pul
        return u
    else
        return ul
    end
end

function bytes_per_pixel(bitdepth, colortype)
    if colortype ∈ (0, 3) # The only color types that can have more than one pixel per byte
        bitdepth / 8
    else
        bitdepth ÷ 8 * get_components_count(colortype)
    end
end
function bytes_per_pixel_for_filter(bitdepth, colortype)
    if colortype ∈ (0, 3)
        if bitdepth <= 8
            return 1
        else
            return bitdepth ÷ 8
        end
    else
        return bitdepth ÷ 8 * get_components_count(colortype)
    end
end

bytes_per_scanline(bitdepth, colortype, width) = ceil(Int, bytes_per_pixel(bitdepth, colortype)) * width

isupper(char::UInt8) = char & (1<<5) == 0
isupper(char::Char)  = isupper(UInt8(char))
end # module PNGImageFormatInternal
