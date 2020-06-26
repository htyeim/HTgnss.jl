


@enum TimeSystemType begin
    # add new systems BEFORE count, then
    # *** add to Strings[] in TimeSystem.cpp and make parallel to this enum. ***

    # Unknown MUST BE FIRST, and must = 0
    tstUnknown       # /< unknown time frame; for legacy code compatibility
    tstAny           # /< wildcard; allows comparison with any other type
    tstGPS           # /< GPS system time
    tstGLO           # /< GLONASS system time
    tstGAL           # /< Galileo system time
    tstQZS           # /< QZSS system Time
    tstBDT           # /< BeiDou system Time
    tstIRN           # /< IRNSS system Time
    tstUTC           # /< Coordinated Universal Time (e.g., from NTP)
    tstTAI           # /< International Atomic Time
    tstTT            # /< Terrestrial time (used in IERS conventions)
    tstTDB           # /< Barycentric dynamical time (JPL ephemeris); very near TT
        # count MUST BE LAST
    tstcount         # /< the number of systems - not a system
end

# struct GNSSDatTime <: GNSSDatTime
#     dt::DateTime
#     tst::TimeSystemType
# end 

const stt2tst = Dict{SatelliteSystemType,TimeSystemType}(
    sstGPS => tstGPS,           # /< GPS system time
    sstGeosync => tstGPS,           # /< GPS system time
    sstGlonass => tstGLO,           # /< GLONASS system time
    sstGalileo => tstGAL,           # /< Galileo system time
    sstQZSS => tstGPS,           # /< QZSS system Time
    sstBeiDou => tstBDT,           # /< BeiDou system Time
    sstIRNSS => tstIRN,           # /< IRNSS system Time
    # "UT" => tstUTC,           # /< Coordinated Universal Time (e.g., from NTP)
    # "TA" => tstTAI,           # /< International Atomic Time

)
const str2tst = Dict{String,TimeSystemType}(
    "GP" => tstGPS,           # /< GPS system time
    "GL" => tstGLO,           # /< GLONASS system time
    "GA" => tstGAL,           # /< Galileo system time
    "QZ" => tstQZS,           # /< QZSS system Time
    "BD" => tstBDT,           # /< BeiDou system Time
    "IR" => tstIRN,           # /< IRNSS system Time
    "UT" => tstUTC,           # /< Coordinated Universal Time (e.g., from NTP)
    "TA" => tstTAI,           # /< International Atomic Time
)

function str2TimeSystemType(str::String,
        str2tst::Dict{String,TimeSystemType}=str2tst,
)::TimeSystemType
    haskey(str2tst, str) ||
        throw(error("no such TimeSystemType: $str"))
    str2tst[str]
end




# Time system conversions constants
const TAI_minus_GPSGAL_EPOCH = 19.0
const TAI_minus_BDT_EPOCH = 33.0
# const TAI_minus_TT_EPOCH = -32.184

function diff2UTC(indt::DateTime, inTS::TimeSystemType)
    # -----------------------------------------------------------
    # conversions: first convert inTS->TAI ...
    # TAI = GPS + 19s
    # TAI = UTC + getLeapSeconds()
    # TAI = TT - 32.184s
    if inTS == tstGPS ||       # GPS -> TAI
        inTS == tstGAL ||       # GAL -> TAI
        inTS == tstIRN         # IRN -> TAI 
        dt = TAI_minus_GPSGAL_EPOCH
    elseif inTS == tstUTC ||  # UTC -> TAI
        inTS == tstGLO    # GLO -> TAI
        dt = -offset_utc_tai(indt)
    elseif inTS == tstBDT    # BDT -> TAI
        dt = TAI_minus_BDT_EPOCH;
    elseif inTS == tstTAI    # TAI
        dt  = 0.0
    # elseif inTS == TT     # TT -> TAI
    #     dt = TAI_minus_TT_EPOCH;
    # elseif inTS == tstTDB    # TDB -> TAI
    #     dt = TAI_minus_TT_EPOCH + TDBmTT
    else                               # other
        throw(error("no such TimeSystem: $inTS"))
    end

    # -----------------------------------------------------------
    # ... then convert TAI->outTS
    # GPS = TAI - 19s
    # UTC = TAI - getLeapSeconds()
    # TT = TAI + 32.184s
    # if outTS == tstGPS ||      # TAI -> GPS
    # outTS == tstGAL ||      # TAI -> GAL
    # outTS == tstIRN         # TAI -> IRN
    #     dt -= TAI_minus_GPSGAL_EPOCH
    # elseif outTS == tstUTC || # TAI -> UTC
    #     outTS == tstGLO   # TAI -> GLO
    dt += offset_utc_tai(indt)
    # elseif outTS == tstBDT   # TAI -> BDT
    #     dt -= TAI_minus_BDT_EPOCH
    # elseif outTS == tstTAI   # TAI
    #     dt += 0.0
    # elseif outTS == TT    # TAI -> TT
    #     dt -= TAI_minus_TT_EPOCH;
    # elseif outTS == tstTDB   # TAI -> TDB
    #     dt -= TAI_minus_TT_EPOCH + TDBmTT
    # else                               # other
    #     throw(error("no such TimeSystem: $inTS"))
    # end

    return Millisecond(dt * 1000.0)
end