include("../src/FlixGL.Color.jl")

function isapproxcoll(arr1, arr2; atol::Real=0)
    @assert length(arr1) == length(arr2)
    
    for i ∈ 1:length(arr1)
        if !isapprox(arr1[i], arr2[i], atol=atol)
            return false
        end
    end
    return true
end

using Test

function test_construction()
    color = ByteColor(0x042069FF)
    @assert collect(color) == [0x04, 0x20, 0x69, 0xFF]
    
    color = NormColor(1, 0, 0, 0.1)
    @assert isapproxcoll(collect(color), (1, 0, 0, 0.1))
    
    color = ByteColor3(0x042069)
    @assert collect(color) == [0x04, 0x20, 0x69]
    
    color = NormColor3(0.4, 0.2, 0.0)
    @assert isapproxcoll(collect(color), (0.4, 0.2, 0))
    
    color = ByteGrayscaleA(0x55, 0xa0)
    @assert collect(color) == [0x55, 0xa0]
    
    color = NormGrayscaleA(0.5, 0.75)
    @assert isapproxcoll(collect(color), (0.5, 0.75))
    
    color = ByteGrayscale(0x55)
    @assert color.v == 0x55
    
    color = NormGrayscale(0.5)
    @assert isapproxcoll(color.v, 0.5)
    
    return true
end

function test_conversion()
    # Convert between integer data types
    color = convert(Color{Int32}, Color(0x042069FF))
    @assert collect(color) == [33686017, 269488143, 884257972, 2147483647]
    
    color = convert(OpaqueColor{Int32}, OpaqueColor(0x042069))
    @assert collect(color) == [33686017, 269488143, 884257972]
    
    # Convert between decimal data types
    color = convert(Color{Float16}, Color(0.1, 0.2, 0.3, 0.4))
    @assert isapproxcoll(collect(color), (0.1, 0.2, 0.3, 0.4))
    
    color = convert(OpaqueColor{Float16}, OpaqueColor(0.1, 0.2, 0.3))
    @assert isapproxcoll(collect(color), (0.1, 0.2, 0.3))
    
    # Convert RGB->RGBA
    color = convert(Color{UInt8}, OpaqueColor{UInt8}(4, 20, 69))
    @assert collect(color) == [4, 20, 69, 0]
    
    # Convert RGBA->RGB
    color = convert(OpaqueColor{UInt8}, Color{UInt8}(4, 20, 69, 0))
    @assert collect(color) == [4, 20, 69]
    
    # Convert Gray(A)->RGBA
    color = convert(Color{UInt8}, ByteGrayscaleA(0xA0, 0x66))
    @assert collect(color) == [0xA0, 0xA0, 0xA0, 0x66]
    
    color = convert(Color{UInt8}, ByteGrayscale(0xA0))
    @assert collect(color) == [0xA0, 0xA0, 0xA0, 0x0]
    
    # Convert Gray(A)->RGB
    color = convert(OpaqueColor{UInt8}, ByteGrayscaleA(0xA0, 0x66))
    @assert collect(color) == [0xA0, 0xA0, 0xA0]
    
    color = convert(OpaqueColor{UInt8}, ByteGrayscale(0xA0))
    @assert collect(color) == [0xA0, 0xA0, 0xA0]
    
    # Convert RGB->RGBA w/ mixed channel types
    color = convert(Color{Float32}, OpaqueColor(0xFF8844))
    @assert isapproxcoll(collect(color), (1, 0.533, 0.266, 0), atol=1e-3)
    
    # Convert RGBA->RGB w/ mixed channel types
    color = convert(OpaqueColor{Float32}, Color(0xFF884422))
    @assert isapproxcoll(collect(color), (1, 0.533, 0.266), atol=1e-3)
    
    # Convert ByteGrayscale to NormGrayscale
    color = convert(NormGrayscale, ByteGrayscale(0xA0))
    @assert isapprox(color.v, 0.625, atol=1e-2)
    
    return true
end

function test_arithmetic()
    # If mixed numeric types work, same types definitely work, because numeric types are `promote`d.
    
    color = Color(0xFF000000) + Color(0, 1.0, 0, 0)
    @assert isapprox(color.r, 1) && isapprox(color.g, 1) && isapprox(color.b, 0) && isapprox(color.a, 0)
    
    color = Color(0xFF00DD00) - Color(0.5, 0, 0.25, 0)
    @assert isapprox(color.r, 0.5) && isapprox(color.g, 0) && isapprox(color.b, 0.616, atol=1e-3) && isapprox(color.a, 0)
    
    color = Color(0x042069FF) * Color(0.1, 0.5, 0.25, 0.5)
    @assert isapprox(color.r, 0.0015, atol=1e-4) && isapprox(color.g, 0.0627, atol=1e-4) && isapprox(color.b, 0.1029, atol=1e-4) && isapprox(color.a, 0.5)
    
    color = Color(0xFFFFFFFF) / Color(2, 0.5, 4, 0.25)
    @assert isapprox(color.r, 0.5) && isapprox(color.g, 2) && isapprox(color.b, 0.25) && isapprox(color.a, 4)
    
    return true
end

function test_mix()
    color = mix(Color(1.0, 1.0, 1.0, 1.0), Color(0.5, 0.5, 0.2, 0), 0.75)
    @assert isapprox(color.r, 0.625) && isapprox(color.g, 0.625) && isapprox(color.b, 0.4) && isapprox(color.a, 0.25)
    
    # A single mixed numeric type mix should suffice as arguments are promoted
    # TODO: Mixed color types
    color = mix(Color(0xFFFFFFFF), Color(0.5, 0.5, 0.2), 0.75)
    @assert isapprox(color.r, 0.625) && isapprox(color.g, 0.625) && isapprox(color.b, 0.4) && isapprox(color.a, 0.25)
    
    return true
end

function test_mix_semantic()
    color = Red + Green
    @assert isapprox(color.r, 1) && isapprox(color.g, 1) && isapprox(color.b, 0) && isapprox(color.a, 0)
    
    color = 0.25Red + Green / 2 + Blue + 0.5Alpha
    @assert isapprox(color.r, 0.25) && isapprox(color.g, 0.5) && isapprox(color.b, 1) && isapprox(color.a, 0.5)
    
    return true
end

@testset "FlixGL.Color" begin
    @test test_construction()
    @test test_conversion()
    @test test_arithmetic()
    @test test_mix()
    @test test_mix_semantic()
end
