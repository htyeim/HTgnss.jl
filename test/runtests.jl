using HTgnss
using Test

using Dates
using Glob


@testset "HTgnss.jl" begin
    # Write your own tests here.
    # fn = "/home/t/RD/GNSS/STEC/-1_00_01/2015/115/FINS00ALA_R_20151160000_01D_30S_MO.rnx"
    # fn = "/home/t/RD/GNSS/STEC/-1_00_01/2015/115/NYA200SJM_R_20151140000_01D_30S_MO.rnx"

    # HTgnss.load_obs(fn)


    include("read_obsnav.jl")
    test_pos()
end
