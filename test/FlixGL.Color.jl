include("../src/FlixGL.Color.jl")

using Test

function test_construction()
    color = Color(0x042069FF)
    @assert color.r == 0x04 && color.g == 0x20 && color.b == 0x69 && color.a == 0xFF
    
    color = Color(1, 0, 0, 0.1)
    @assert isapprox(color.r, 1) && isapprox(color.g, 0) && isapprox(color.b, 0) && isapprox(color.a, 0.1)
    
    color = OpaqueColor(0x042069)
    @assert color.r == 0x04 && color.g == 0x20 && color.b == 0x69
    
    color = OpaqueColor(0.4, 0.2, 0.0)
    @assert isapprox(color.r, 0.4) && isapprox(color.g, 0.2) && isapprox(color.b, 0)
    
    return true
end

function test_conversion()
    # Convert between numeric data types
    color = convert(Color{Float32}, Color(0x042069FF))
    @assert isapprox(color.r, 0.015, atol=1e-3) && isapprox(color.g, 0.125, atol=1e-3) && isapprox(color.b, 0.411, atol=1e-3) && isapprox(color.a, 1, atol=1e-3)
    
    color = convert(OpaqueColor{Float32}, OpaqueColor(0x042069))
    @assert isapprox(color.r, 0.015, atol=1e-3) && isapprox(color.g, 0.125, atol=1e-3) && isapprox(color.b, 0.411, atol=1e-3)
    
    color = convert(Color{UInt8}, Color(0.1, 0.2, 0.3, 0.4))
    @assert color.r == 25 && color.g == 51 && color.b == 76 && color.a == 102
    
    color = convert(OpaqueColor{UInt8}, OpaqueColor(0.1, 0.2, 0.3))
    @assert color.r == 25 && color.g == 51 && color.b == 76
    
    # Convert from 3 comps to 4 comps & vice versa
    color = convert(Color{UInt8}, OpaqueColor{UInt8}(4, 20, 69))
    @assert color.r == 4 && color.g == 20 && color.b == 69 && color.a == 0
    
    color = convert(OpaqueColor{UInt8}, Color{UInt8}(4, 20, 69, 0))
    @assert color.r == 4 && color.g == 20 && color.b == 69
    
    # Convert from 3 comps to 4 with mixed underlying numeric types
    color = convert(Color{Float32}, OpaqueColor(0xFF8844))
    @assert isapprox(color.r, 1) && isapprox(color.g, 0.533, atol=1e-3) && isapprox(color.b, 0.266, atol=1e-3) && isapprox(color.a, 0)
    
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
