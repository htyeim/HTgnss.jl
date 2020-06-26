


abstract type RinexBase end
abstract type RinexHeader <: RinexBase end
abstract type RinexData <: RinexBase end

#= =========================== =#


@with_kw struct RinexNavHeader <: RinexHeader
    version::Tuple{Float64,String,String,SatelliteSystemType}
    runBy::Tuple{String,String,String}
    comment::String
    ionoCorr::String
    timeSysCorr::Dict{TimeCorrectionType,TimeSystemCorrection}
    leapSeconds::Tuple{Int64,Int64,Int64,Int64} 
    corrSysTime::String 
    deltaUTC::String
    dUTC::String
    ionAlpha::String
    ionBeta::String
    eoH::String
end

@with_kw struct EphEpoch
    si::SatID
    dt::DateTime
    d::Array{Float64,1}
end

@with_kw mutable struct EphEpochStore
    si::SatID
    keys::Array{DateTime,1}
    eph::Dict{DateTime,EphEpoch}
end
    

@with_kw struct RinexNavData <: RinexData
    data::Dict{SatID,EphEpochStore}
end


@with_kw struct RinexNav <: RinexBase
    filename::String
    header::RinexHeader
    data::RinexNavData
end

# TODO multiple data files

#= =========================== =#

D_SystemNumObs = Dict{SatelliteSystemType,Tuple{Int64,Array{ObsID,1}}}

@with_kw struct RinexObsHeader <: RinexHeader
    version::Tuple{Float64,Char,SatelliteSystemType}
    runBy::Tuple{String,String,String}
    comment::String
    markerName::String
    markerNumber::String
    markerType::String
    observer::Tuple{String,String}
    receiver::String
    antennaType::String
    antennaPosition::ECEF{Float64}
    antennaDeltaHEN::String
    antennaDeltaXYZ::String
    antennaPhaseCtr::String
    antennaBsightXYZ::String
    antennaZeroDirAzi::String
    antennaZeroDirXYZ::String
    centerOfMass::String
    numObs::String
    systemNumObs::D_SystemNumObs
    waveFact::String
    sigStrengthUnit::String
    interval::Float64
    firstTime::Tuple{DateTime,Millisecond}
    lastTime::String
    receiverOffset::String
    systemDCBSapplied::String
    systemPCVSapplied::String
    systemScaleFac::String
    systemPhaseShift::String
    glonassSlotFreqNo::String
    glonassCodPhsBias::String
    leapSeconds::String
    numSats::String
    prnObs::String
    eoH::String
    iscrx::Bool = false
    # recommend_length::Int64 
    # depended on first obs last obs and interval
    # 2400 => 1 days 15 s interval
end


struct RinexDatum
    obs::Float64 # empty -> NaN
    lli::Char
    ssi::Char 
    function RinexDatum(str::Union{String,SubString})
        v = strip(SubString(str, 1, 13))
        if isempty(v)
            obs = NaN
        else
            obs = parse(Float64, v)
        end
        llic = str[14]
        ssic = str[15]
        new(obs, llic, ssic)
    end
end

struct EpochHeader
    dt::DateTime
    flag::Char
    numObs::Int64
    RCO::Float64
end

@with_kw struct SatelliteObsData
    satid::SatID
    obsids::Array{ObsID,1}
    dts::Array{DateTime,1}
    obs::Array{Array{RinexDatum,1},1}
end
@with_kw struct RinexObsData <: RinexData
    epochs::Dict{DateTime,EpochHeader}
    comments::Dict{DateTime,String}
    obs::Dict{SatID,SatelliteObsData}
end

struct RinexObs <: RinexBase
    filename::String
    header::RinexObsHeader
    data::RinexObsData
end

# TODO multiple data files => cat?
