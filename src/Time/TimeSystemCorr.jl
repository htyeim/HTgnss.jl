


@enum TimeCorrectionType begin
    tctUnknown
    tctGPUT  # /< GPS  to UTC using A0, A1
    tctGAUT  # /< GAL  to UTC using A0, A1
    tctSBUT  # /< SBAS to UTC using A0, A1, incl. provider and UTC ID
    tctGLUT  # /< GLO  to UTC using A0 = -TauC , A1 = 0
    tctGPGA  # /< GPS  to GAL using A0 = A0G   , A1 = A1G
    tctGAGP  # /< GPS  to GAL using A0 = A0G   , A1 = A1G
    tctGLGP  # /< GLO  to GPS using A0 = -TauGPS, A1 = 0
    tctQZGP  # /< QZS  to GPS using A0, A1
    tctQZUT  # /< QZS  to UTC using A0, A1
    tctBDUT  # /< BDT  to UTC using A0, A1
    tctBDGP  # /< BDT  to GPS using A0, A1  !! not in RINEX
    tctIRUT  # /< IRN  to UTC using A0, A1
    tctIRGP  # /< IRN  to GPS using A0, A1 
end

const str2tct = Dict{String,TimeCorrectionType}(
    "GPUT" => tctGPUT,
    "GAUT" => tctGAUT,
    "SBUT" => tctSBUT,
    "GLUT" => tctGLUT,
    "GPGA" => tctGPGA,
    "GAGP" => tctGAGP,
    "GLGP" => tctGLGP,
    "QZGP" => tctQZGP,
    "QZUT" => tctQZUT,
    "BDUT" => tctBDUT,
    "BDGP" => tctBDGP,
    "IRUT" => tctIRUT,
    "IRGP" => tctIRGP, 

)
function str2TimeCorrectionType(str::String,
    str2tct::Dict{String,TimeCorrectionType}=str2tct)
    haskey(str2tct, str) || throw(error("no such TimeSystemType: $str"))
    str2tct[str]
end

const tct2tsts = Dict(
    tctGPUT => (tstGPS, tstUTC),
    tctGAUT => (tstGAL, tstUTC),
    tctSBUT => (tstGPS, tstUTC),
    tctGLUT => (tstGLO, tstUTC),
    tctGPGA => (tstGPS, tstGAL),
    tctGAGP => (tstGAL, tstGPS),
    tctGLGP => (tstGLO, tstGPS),
    tctQZGP => (tstQZS, tstGPS),
    tctQZUT => (tstQZS, tstUTC),
    tctBDUT => (tstBDT, tstUTC),
    tctBDGP => (tstBDT, tstGPS),
    tctIRUT => (tstIRN, tstUTC),
    tctIRGP => (tstIRN, tstGPS), 
)
function tct2TimeSystemTypes(tct::TimeCorrectionType,
    tct2tsts::Dict{TimeCorrectionType,Tuple{TimeSystemType,TimeSystemType}}=tct2tsts,
)::Tuple{TimeSystemType,TimeSystemType}
    haskey(tct2tsts, tct) ||
        throw(error("no such TimeCorrectionType: $tct"))
    tct2tsts[tct]
end
@with_kw struct TimeSystemCorrection
    type::TimeCorrectionType
    frTST::TimeSystemType
    toTST::TimeSystemType
    A0::Float64
    A1::Float64
        # /< reference time for polynominal (week,sow) - MUST BE GPS TIME
    refWeek::Int64 
    refSOW::Int64
        # /< reference time (yr,mon,day) for RINEX ver 2 GLO
    refYr::Int64
    refMon::Int64
    refDay::Int64
        # /< string 'EGNOS' 'WAAS' or 'MSAS'
    geoProvider::String
        # /< UTC Identifier [0 unknown, 1=UTC(NIST),
        # /<  2=UTC(USNO), 3=UTC(SU), 4=UTC(BIPM),
        # /<  5=UTC(Europe), 6=UTC(CRL)]
    geoUTCid::String
    
end

function getTimeSystemCorrection(tp::TimeCorrectionType,
    A0::Float64,A1::Float64,
    refWeek::Int64, refSOW::Int64,
    geoProvider::String, geoUTCid::String)
    frTST, toTST = tct2TimeSystemTypes(tp)
    
    dt = gpsws2datetime(refWeek, refSOW)

    TimeSystemCorrection(tp, frTST, toTST,
                    A0, A1, refWeek, refSOW,
                    year(dt), month(dt), day(dt),
                    geoProvider, geoUTCid,)
    # if in(tp, Set([tctGLGP, tctGLUT, tctBDUT,
    #         tctGPUT, tctGPGA, tctQZGP, tctQZUT, ]))
    # end
    #  if(tc.type == TimeSystemCorrection::GLGP ||
    #     tc.type == TimeSystemCorrection::GLUT ||        // TD ?
    #     tc.type == TimeSystemCorrection::BDUT ||        // TD ?
    #     tc.type == TimeSystemCorrection::GPUT ||
    #     tc.type == TimeSystemCorrection::GPGA ||
    #     tc.type == TimeSystemCorrection::QZGP ||
    #     tc.type == TimeSystemCorrection::QZUT)

    #  {
    #     GPSWeekSecond gws(tc.refWeek,tc.refSOW);
    #     CivilTime ct(gws);
    #     tc.refYr = ct.year;
    #     tc.refMon = ct.month;
    #     tc.refDay = ct.day;
    #  }

    #  if(tc.type == TimeSystemCorrection::GAUT)
    #  {
    #     GALWeekSecond gws(tc.refWeek,tc.refSOW);
    #     CivilTime ct(gws);
    #     tc.refYr = ct.year;
    #     tc.refMon = ct.month;
    #     tc.refDay = ct.day;
    #  }

    #     //if(tc.type == TimeSystemCorrection::GLUT)
    #     // {
    #     //   tc.refYr =  1980;
    #     //   tc.refMon = 1;
    #     //   tc.refDay = 6;
    #     //   tc.refWeek = 0;
    #     //   tc.refSOW = 0;
    #     //}

end