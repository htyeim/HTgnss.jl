using HTgnss
using Test

using Dates
using Glob


@testset "HTgnss.jl" begin
    # Write your own tests here.
    include("read_obsnav.jl")
    test_pos()
end
