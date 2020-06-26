module HTgnss
using Debugger
using Geodesy
using Dates
using TimesDates
using LeapSeconds
using Parameters
using Printf
using HTrg

include("GNSS/Systems.jl")
include("Time/Systems.jl")
include("Position/Systems.jl")



# println(GNSSBase.ObsID)
# ObsID = GNSSBase.ObsID
include("RINEX/Rinex.jl")


greet() = print("Hello World!")

end # module
