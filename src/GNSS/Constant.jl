
#= /**
* @ingroup Geodetic
* @name GNSS Constants
* Time constants are in TimeConstants.hpp
*/ =#

# ---------------- independent of GNSS ----------------------
# / GPS value of PI; also specified by GAL
const PI        = 3.141592653589793238462643383280
# / GPS value of PI*2
const TWO_PI    = 6.283185307179586476925286766559
# / GPS value of PI**0.5
const SQRT_PI   = 1.772453850905516027298167483341
# / relativity constant (sec/sqrt(m))
const REL_CONST = -4.442807633e-10
# / m/s, speed of light; this value defined by GPS but applies to GAL and GLO.
const C_MPS = 2.99792458e8

# ---------------- GPS --------------------------------------
# / Hz, GPS Oscillator or chip frequency
const OSC_FREQ_GPS  = 10.23e6
# / Hz, GPS chip rate of the P & Y codes
const PY_CHIP_FREQ_GPS = OSC_FREQ_GPS
# / Hz, GPS chip rate of the C/A code
const CA_CHIP_FREQ_GPS = OSC_FREQ_GPS / 10.0
# / Hz, GPS Base freq w/o relativisitic effects
const RSVCLK_GPS    = 10.22999999543e6
# / GPS L1 carrier frequency in Hz
const L1_FREQ_GPS   = 1575.42e6
# / GPS L2 carrier frequency in Hz
const L2_FREQ_GPS   = 1227.60e6
# / GPS L5 carrier frequency in Hz.
const L5_FREQ_GPS   = 1176.45e6
# / GPS L1 carrier wavelength in meters
const L1_WAVELENGTH_GPS  = 0.190293672798
# / GPS L2 carrier wavelength in meters
const L2_WAVELENGTH_GPS  = 0.244210213425
# / GPS L5 carrier wavelength in meters.
const L5_WAVELENGTH_GPS  = 0.254828049
# / GPS L1 frequency in units of oscillator frequency
const L1_MULT_GPS   = 154.0
# / GPS L2 frequency in units of oscillator frequency
const L2_MULT_GPS   = 120.0
# / GPS L5 frequency in units of oscillator frequency.
const L5_MULT_GPS   = 115.0
# / GPS Gamma constant
const GAMMA_GPS = 1.646944444
# / Reference Semi-major axis. From IS-GPS-800 Table 3.5-2 in meters.
const A_REF_GPS = 26559710.0
# / Omega reference value from Table 30-I converted to radians
const OMEGADOT_REF_GPS = -2.6e-9 * PI; 

@inline function getLegacyFitInterval(iodc::Int64, fiti::Int64)::Int64
   # /* check the IODC */
   # /* error in iodc, return minimum fit */
    if iodc < 0 || iodc > 1023 return 4 end
    if ((fiti == 0) && (iodc & 0xFF) < 240 ) ||
      (iodc & 0xFF) > 255
        return 4 # /* fit interval of 4 hours */
    elseif fiti == 1
        if (iodc & 0xFF) < 240 || (iodc & 0xFF) > 255
            return 6 #   /* fit interval of 6 hours */
        elseif iodc >= 240 && iodc <= 247
            return 8 #   /* fit interval of 8 hours */
        elseif ( (iodc >= 248) && (iodc <= 255) ) || iodc == 496
            return 14 #   /* fit interval of 14 hours */
        elseif (iodc >= 497 && iodc <= 503) || (iodc >= 1021 && iodc <= 1023)
            return 26 #   /* fit interval of 26 hours */
        elseif iodc >= 504 && iodc <= 510
            return 50 #   /* fit interval of 50 hours */
        elseif iodc == 511 || ( (iodc >= 752) && (iodc <= 756))
            return 74 #   /* fit interval of 74 hours */
        elseif iodc == 757
            return 98 #   /* fit interval of 98 hours */
        else throw(error("Invalid IODC Value For sv Block"))
        end
    else
        return 4 #   /* error in ephemeris/iodc, return minimum fit */
    end
    return 0 # never reached
end


# ---------------- GLONASS ----------------------------------
# / GLO Fundamental chip rate in Hz.
const OSC_FREQ_GLO  = 5.11e6
# / GLO Chip rate of the P & Y codes in Hz.
const PY_CHIP_FREQ_GLO = OSC_FREQ_GLO
# / GLO Chip rate of the C/A code in Hz.
const CA_CHIP_FREQ_GLO = OSC_FREQ_GLO / 10.0

# / GLO Fundamental oscillator freq in Hz.
const PSC_FREQ_GLO  = 5.00e6
# / GLO Base freq w/o relativisitic effects in Hz.
const RSVCLK_GLO    = 4.99999999782e6

# GLO Frequency(Hz)
#   f1 is 1602.0e6 + n*562.5e3 Hz = 9 * (178 + n*0.0625) MHz
#   f2    1246.0e6 + n*437.5e3 Hz = 7 * (178 + n*0.0625) MHz
# where n is the time- and satellite-dependent 'frequency channel'
# -7 <= n <= 7
# / GLO L1 carrier base frequency in Hz.
const L1_FREQ_GLO       = 1602.0e6
# / GLO L1 carrier frequency step size in Hz.
const L1_FREQ_STEP_GLO  = 562.5e3
# / GLO L1 carrier wavelength in meters.
const L1_WAVELENGTH_GLO = 0.187136365793
# / GLO L2 carrier base frequency in Hz.
const L2_FREQ_GLO       = 1246.0e6
# / GLO L2 carrier frequency step size in Hz.
const L2_FREQ_STEP_GLO  = 437.5e3
# / GLO L2 carrier wavelength in meters.
const L2_WAVELENGTH_GLO = 0.240603898876
# / GLO L1 multiplier.
const L1_MULT_GLO   = 320.4
# / GLO L2 multiplier.
const L2_MULT_GLO   = 249.2
# / GLO L3 carrier frequency in Hz.
const L3_FREQ_GLO       = 1202.025e6
# / GLO L3 carrier wavelength in meters.
const L3_WAVELENGTH_GLO = 0.249406175412

# / Constant for the max array index in SV accuracy table.
const SV_ACCURACY_GLO_INDEX_MAX = 15
# / Map from SV accuracy/URA flag to NOMINAL accuracy values in m.
# / Further details in ICD-GLO-v5.0, Table 4.4 in Section 4.4.
const SV_ACCURACY_GLO_INDEX = [ 1.0,  2.0,   2.5,   4.0,   5.0,
                                       7.0, 10.0,  12.0,  14.0,  16.0,
                                       32.0, 64.0, 128.0, 256.0, 512.0,
                                       9.999999999999e99               ]

# ---------------- Galileo ----------------------------------
# / GAL L1 (E1) carrier frequency in Hz
const L1_FREQ_GAL   = L1_FREQ_GPS
# / GAL L5 (E5a) carrier frequency in Hz.
const L5_FREQ_GAL   = L5_FREQ_GPS
# / GAL L6 (E6) carrier frequency in Hz.
const L6_FREQ_GAL   = 1278.75e6
# / GAL L7 (E5b) carrier frequency in Hz.
const L7_FREQ_GAL   = 1207.140e6
# / GAL L8 (E5a+E5b) carrier frequency in Hz.
const L8_FREQ_GAL   = 1191.795e6

# / GAL L1 carrier wavelength in meters
const L1_WAVELENGTH_GAL  = L1_WAVELENGTH_GPS
# / GAL L5 carrier wavelength in meters.
const L5_WAVELENGTH_GAL  = L5_WAVELENGTH_GPS
# / GAL L6 carrier wavelength in meters.
const L6_WAVELENGTH_GAL  = 0.234441805
# / GAL L7 carrier wavelength in meters.
const L7_WAVELENGTH_GAL  = 0.24834937
# / GAL L8 carrier wavelength in meters.
const L8_WAVELENGTH_GAL  = 0.251547001

# ---------------- Geostationary (SBAS) ---------------------
# / GEO L1 carrier frequency in Hz
const L1_FREQ_GEO   = L1_FREQ_GPS
# / GEO L5 carrier frequency in Hz.
const L5_FREQ_GEO   = L5_FREQ_GPS

# / GEO L1 carrier wavelength in meters
const L1_WAVELENGTH_GEO  = L1_WAVELENGTH_GPS
# / GEO L5 carrier wavelength in meters.
const L5_WAVELENGTH_GEO  = L5_WAVELENGTH_GPS

# ---------------- BeiDou ----------------------------------
# / The maximum number of active satellites in the Compass constellation.
const MAX_PRN_COM     = 30
# / BDS L1 (B1) carrier frequency in Hz.
const L1_FREQ_BDS   = 1561.098e6
# / BDS L2 (B2) carrier frequency in Hz.
const L2_FREQ_BDS   = L7_FREQ_GAL
# / BDS L3 (B3) carrier frequency in Hz.
const L3_FREQ_BDS   = 1268.52e6

# / BDS L1 carrier wavelength in meters.
const L1_WAVELENGTH_BDS  = 0.192039486310276
# / BDS L2 carrier wavelength in meters.
const L2_WAVELENGTH_BDS  = L7_WAVELENGTH_GAL
# / BDS L3 carrier wavelength in meters.
const L3_WAVELENGTH_BDS  = 0.236332464604421

# ---------------- QZSS ----------------------------------
# / QZS L1 carrier frequency in Hz.
const L1_FREQ_QZS   = L1_FREQ_GPS
# / QZS L2 carrier frequency in Hz.
const L2_FREQ_QZS   = L2_FREQ_GPS
# / QZS L5 carrier frequency in Hz.
const L5_FREQ_QZS   = L5_FREQ_GPS
# / QZS LEX(6) carrier frequency in Hz.
const L6_FREQ_QZS   = L6_FREQ_GAL

# / QZS L1 carrier wavelength in meters.
const L1_WAVELENGTH_QZS   = L1_WAVELENGTH_GPS
# / QZS L2 carrier wavelength in meters.
const L2_WAVELENGTH_QZS   = L2_WAVELENGTH_GPS
# / QZS L5 carrier wavelength in meters.
const L5_WAVELENGTH_QZS   = L5_WAVELENGTH_GPS
# / QZS LEX(6) carrier wavelength in meters.
const L6_WAVELENGTH_QZS   = L6_WAVELENGTH_GAL



# ---------------- IRNSS ----------------------------------
const L5_FREQ_IRN = L5_FREQ_GPS
const L9_FREQ_IRN = 2492.028e6
# ---------------- Convenience routines ---------------------

#= /** Compute wavelength for the given satellite system (sat.id is
* ignored) at the given RINEX frequency band
* n(=1,2,5,6,7,8). Return 0 if the frequency n is not valid for
* the system.
* Calls for system GLO must include the frequency channel number N
* (-7<=N<=7). */ =#
const basefrequencies = Dict{SatelliteSystemType,Dict{CarrierBand,Tuple{Float64,Float64}}}(
    sstGPS     => Dict(cbL1 => (L1_FREQ_GPS, 0.0), # TODO CarrierBand
                        cbL2   => (L2_FREQ_GPS, 0,) ,
                        cbL5   => (L5_FREQ_GPS, 0,) ),
    sstGlonass => Dict(cbG1 =>    (L1_FREQ_GLO, L1_FREQ_STEP_GLO,) ,
                        cbG2   => (L2_FREQ_GLO, L2_FREQ_STEP_GLO,) ,
                        cbG3   => (L3_FREQ_GLO, 0,) ,),
    sstGalileo => Dict(cbL1 =>    (L1_FREQ_GAL, 0,) ,
                        cbL5   => (L5_FREQ_GAL, 0,) ,
                        cbE6   => (L6_FREQ_GAL, 0,) ,
                        cbE5b  => (L7_FREQ_GAL, 0,) ,
                        cbE5ab => (L8_FREQ_GAL, 0,) ,),
    sstGeosync => Dict(cbL1 =>    (L1_FREQ_GEO, 0,) ,
                        cbL5   => (L5_FREQ_GEO, 0,) ),
    sstBeiDou  => Dict(cbB1 =>    (L1_FREQ_BDS, 0,) ,
                        cbB2   => (L2_FREQ_BDS, 0,) ,
                        cbG3   => (L3_FREQ_BDS, 0,) ,
                        cbB3   => (L3_FREQ_BDS, 0,) ,
                        cbE5b  => (L2_FREQ_BDS, 0,) ,),
    sstQZSS    => Dict(cbL1 =>    (L1_FREQ_QZS, 0,) ,
                        cbL2   => (L2_FREQ_QZS, 0,) ,
                        cbL5   => (L5_FREQ_QZS, 0,) ,),
    sstIRNSS   => Dict(cbL5 =>    (L5_FREQ_IRN, 0,) ,
                        cbI9   => (L9_FREQ_IRN, 0,) ),
)
@inline function getBaseFrequency(sys::SatelliteSystemType, cb::CarrierBand;
        basefrequencies::Dict{SatelliteSystemType,Dict{CarrierBand,Float64}}=basefrequencies,
)::Tuple{Float64,Float64}
    haskey(basefrequencies, sys) || throw(error("no such SatelliteSystemType: $sys"))
    thissys = basefrequencies[sys]
    haskey(thissys, cb) || throw(error("system $sys no such CarrierBand: $cb"))
    return thissys[cb]
end

const baseWavelength = Dict{SatelliteSystemType,Dict{Int64,Float64}}(
      sstGPS      => Dict(1 => L1_WAVELENGTH_GPS,
                           2  => L2_WAVELENGTH_GPS,
                           5  => L5_WAVELENGTH_GPS),
      sstGlonass  => Dict(1 => L1_WAVELENGTH_GLO,
                           2  => L2_WAVELENGTH_GLO,
                           ),
      sstGalileo  => Dict(1 => L1_WAVELENGTH_GAL,
                           5  => L5_WAVELENGTH_GAL,
                           6  => L6_WAVELENGTH_GAL,
                           7  => L7_WAVELENGTH_GAL,
                           8  => L8_WAVELENGTH_GAL,),
      sstGeosync  => Dict(1 => L1_WAVELENGTH_GEO,
                           5  => L5_WAVELENGTH_GEO),
      sstBeiDou   => Dict(1 => L1_WAVELENGTH_BDS,
                           6  => L3_WAVELENGTH_BDS,
                           7  => L2_WAVELENGTH_BDS,),
      sstQZSS     => Dict(1 => L1_WAVELENGTH_QZS,
                           2  => L2_WAVELENGTH_QZS,
                           5  => L5_WAVELENGTH_QZS,),
)

@inline function getWavelength(satsys::SatelliteSystemType, n::Int64, N::Int64=0,
      baseWavelength::Dict{SatelliteSystemType,Dict{Int64,Float64}}=baseWavelength)::Float64
    if haskey(baseWavelength, satsys)
        this_satbf = baseWavelength[satsys]
        if satsys == sstGlonass
            if haskey(this_satbf, n) && haskey(this_satbf, n + 10)
                return this_satbf[29] / (this_satbf[n] + N * this_satbf[n + 10])
            end
        else return this_satbf[n] end
    end
    return 0.0
end

#= /** Compute beta(a,b), the ratio of 2 frequencies fb/fa for the
* given satellite system (sat.id is ignored). Return 0 if
* either of the input n's are not valid RINEX bands
* (n=1,2,5,6,7,or 8) for the system. */ =#
@inline function getBeta(satsys::SatelliteSystemType, na::Int64, nb::Int64)::Float64
    wla = getWavelength(satsys, na)
    wlb = getWavelength(satsys, nb)
    if wla == 0.0 || wlb == 0.0 return 0.0 end
    return wlb / wla
end

#= /** Compute alpha (also called gamma) = (beta^2-1) =
* ((fa/fb)^2-1) for 2 frequencies fa,fb for the given satellite
* system (sat.id is ignored).
* @return 0 if either of the input n's are not valid RINEX
*   bands (n=1,2,5,6,7,8) for the satellite system. */ =#
@inline function getAlpha(satsys::SatelliteSystemType, na::Int64, nb::Int64)::Float64
    beta = getBeta(sat, na, nb)
    if beta == 0.0 return 0.0 end
    beta^2 - 1.0
end
