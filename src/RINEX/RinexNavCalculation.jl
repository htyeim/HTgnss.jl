
@enum HealthStatus begin
    hsMinValue
    hsUninitialized  # /< Health status has not been set.
    hsUnavailable    # /< Orbit information was not available, PVT invalid.
    hsUnused        # /< Sat health is not used in computing this PVT. 
    hsUnknown       # /< Health state is unknown.
    hsUnhealthy     # /< Sat is marked unhealthy, do not use PVT.
    hsDegraded      # /< Sat is in a degraded state, recommend do not use.
    hsHealthy       # /< Satellite is healthy, PVT valid.
    hsMaxValue
end


@enum Frames begin
    # add new frames BEFORE count, then add to Strings[] in ReferenceFrame.cpp
    # and make parallel to this enum.

    # Unknown MUST BE FIRST, and MUST = 0
    fmUnknown    # /< unknown frame
    fmWGS84      # /< WGS84, assumed to be the latest version
    fmWGS84G730  # /< WGS84, GPS week 730 version
    fmWGS84G873  # /< WGS84, GPS week 873 version
    fmWGS84G1150 # /< WGS84, GPS week 1150 version
    fmITRF       # /< ITRF, assumed to be the latest version
    fmPZ90       # /< PZ90 (GLONASS)
    fmPZ90KGS    # /< PZ90 the "original"
    fmCGCS2000   # /< CGCS200 (BDS)
    # count MUST BE LAST
    fmcount        # /< the number of frames - not a frame
end

struct Xvt
    x::ECEF
    v::Tuple{Float64,Float64,Float64}
    clkbias::Float64
    clkdrift::Float64
    relcorr::Float64
    frame::Frames
    health::HealthStatus
    
end


@with_kw struct GNSSEllipsoid
    # / Defined in TR8350.2, Appendix A.1
    # / @return semi-major axis of Earth in meters.
    # a= 6378137.0,
    # / Derived from TR8350.2, Appendix A.1
    # / @return semi-major axis of Earth in km.
    # a_km = a / 1000.0,
    #= /**
    * Derived from TR8350.2, Appendix A.1
    * @return flattening (ellipsoid parameter).
    */ =#
    # flattening = 0.335281066475e-2,
    # / Defined in TR8350.2, Table 3.3
    # / @return eccentricity (ellipsoid parameter).
    # eccentricity= 8.1819190842622e-2,
    # / Defined in TR8350.2, Table 3.3
    # / @return eccentricity squared (ellipsoid parameter).
    # eccSquared = 6.69437999014e-3,
    ell::Ellipsoid = wgs84_ellipsoid
    # / Defined in TR8350.2, 3.2.4 line 3-6, or Table 3.1
    # / @return angular velocity of Earth in radians/sec.
    angVelocity::Float64 = 7.292115e-5
    # / Defined in TR8350.2, Table 3.1
    # / @return geocentric gravitational constant in m**3 / s**2
    gm::Float64 = 3986004.418e8
    # / Defined in TR8350.2, 3.3.2 line 3-11
    # / @return Speed of light in m/s.
    c::Float64 =  299792458.0
end
const WGS84Ellipsoid = GNSSEllipsoid()
const GPSEllipsoid = GNSSEllipsoid(wgs84_ellipsoid,
                    7.2921151467e-5, 3.986005e14, C_MPS)
const PZ90Ellipsoid = (ge = GNSSEllipsoid(Ellipsoid(a="6378136.0",
                        f_inv="298.25784",),
                    7.292115e-5, 398600.4418e9, 299792458.0,),
                    j20 = -1.08262575e-3,
                    gm_km = 398600.4418,
                    a_km = 6378136.0 / 1000.0,)


include("RinexNavCalcOrb.jl")
include("RinexNavCalcFit.jl")

function calculate_pos(ees::EphEpochStore, dt::DateTime, )
    if ees.si.ss == sstGlonass
        return calculate_Fit_pos(ees, dt)
    elseif ees.si.ss == sstGeosync
        for (k, v) in ees.eph
            vd = v.d
            return ECEF(vd[4], vd[8], vd[12], )
        end
    else
        return calculate_Orbit_pos(ees, dt)
    end
    return ECEF{Float64}(NaN, NaN, NaN)
end
# function calculate_pos(nav::RinexNav, sat::SatID, jd::Float64)

# end