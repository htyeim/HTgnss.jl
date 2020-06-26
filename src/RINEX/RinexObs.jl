


function read_obsheader(f::IOStream,
                obs_hstrings_set::Set{String}=obs_hstrings_set,
        )::Dict{String,String}
    header_hs = Dict{String,String}()
    if get_header!(header_hs, f, obs_hstrings_set)
        haskey(header_hs, ohsVersion) ||
            throw(error("header error, not $ohsVersion"))
        return header_hs
    end
    throw(error("read header error!"))
end

function read_obsheader(filename::String)
    open(filename, "r") do f
        return read_obsheader(f)
    end
end


function parse_obsheader(header_hs::Dict{String,String})
    Version           = parse_ohsVersion(get(header_hs, ohsVersion, ""))
    RunBy             = parse_ohsRunBy(get(header_hs, ohsRunBy, ""))
    Comment           = parse_ohsComment(get(header_hs, ohsComment, ""))
    MarkerName        = parse_ohsMarkerName(get(header_hs, ohsMarkerName, ""))
    MarkerNumber      = parse_ohsMarkerNumber(get(header_hs, ohsMarkerNumber, ""))
    MarkerType        = parse_ohsMarkerType(get(header_hs, ohsMarkerType, ""))
    Observer          = parse_ohsObserver(get(header_hs, ohsObserver, ""))
    Receiver          = parse_ohsReceiver(get(header_hs, ohsReceiver, ""))
    AntennaType       = parse_ohsAntennaType(get(header_hs, ohsAntennaType, ""))
    AntennaPosition   = parse_ohsAntennaPosition(get(header_hs, ohsAntennaPosition, ""))
    AntennaDeltaHEN   = parse_ohsAntennaDeltaHEN(get(header_hs, ohsAntennaDeltaHEN, ""))
    AntennaDeltaXYZ   = parse_ohsAntennaDeltaXYZ(get(header_hs, ohsAntennaDeltaXYZ, ""))
    AntennaPhaseCtr   = parse_ohsAntennaPhaseCtr(get(header_hs, ohsAntennaPhaseCtr, ""))
    AntennaBsightXYZ  = parse_ohsAntennaBsightXYZ(get(header_hs, ohsAntennaBsightXYZ, ""))
    AntennaZeroDirAzi = parse_ohsAntennaZeroDirAzi(get(header_hs, ohsAntennaZeroDirAzi, ""))
    AntennaZeroDirXYZ = parse_ohsAntennaZeroDirXYZ(get(header_hs, ohsAntennaZeroDirXYZ, ""))
    CenterOfMass      = parse_ohsCenterOfMass(get(header_hs, ohsCenterOfMass, ""))
    NumObs            = parse_ohsNumObs(get(header_hs, ohsNumObs, ""))
    if Version[1] > 2.99
        SystemNumObs  = parse_ohsSystemNumObs3(get(header_hs, ohsSystemNumObs, ""))
    else
        SystemNumObs  = parse_ohsSystemNumObs2(get(header_hs, ohsNumObs, ""), Version[3])
    end
    WaveFact          = parse_ohsWaveFact(get(header_hs, ohsWaveFact, ""))
    SigStrengthUnit   = parse_ohsSigStrengthUnit(get(header_hs, ohsSigStrengthUnit, ""))
    Interval          = parse_ohsInterval(get(header_hs, ohsInterval, ""))
    FirstTime         = parse_ohsFirstTime(get(header_hs, ohsFirstTime, ""))
    LastTime          = parse_ohsLastTime(get(header_hs, ohsLastTime, ""))
    ReceiverOffset    = parse_ohsReceiverOffset(get(header_hs, ohsReceiverOffset, ""))
    SystemDCBSapplied = parse_ohsSystemDCBSapplied(get(header_hs, ohsSystemDCBSapplied, ""))
    SystemPCVSapplied = parse_ohsSystemPCVSapplied(get(header_hs, ohsSystemPCVSapplied, ""))
    SystemScaleFac    = parse_ohsSystemScaleFac(get(header_hs, ohsSystemScaleFac, ""))
    SystemPhaseShift  = parse_ohsSystemPhaseShift(get(header_hs, ohsSystemPhaseShift, ""))
    GlonassSlotFreqNo = parse_ohsGlonassSlotFreqNo(get(header_hs, ohsGlonassSlotFreqNo, ""))
    GlonassCodPhsBias = parse_ohsGlonassCodPhsBias(get(header_hs, ohsGlonassCodPhsBias, ""))
    LeapSeconds       = parse_ohsLeapSeconds(get(header_hs, ohsLeapSeconds, ""))
    NumSats           = parse_ohsNumSats(get(header_hs, ohsNumSats, ""))
    PrnObs            = parse_ohsPrnObs(get(header_hs, ohsPrnObs, ""))
    EoH               = parse_ohsEoH(get(header_hs, ohsEoH, ""))
    RinexObsHeader(
        Version, RunBy, Comment,
        MarkerName, MarkerNumber, MarkerType,
        Observer, Receiver,
        AntennaType, AntennaPosition, AntennaDeltaHEN,
        AntennaDeltaXYZ, AntennaPhaseCtr, AntennaBsightXYZ,
        AntennaZeroDirAzi, AntennaZeroDirXYZ,
        CenterOfMass,
        NumObs, SystemNumObs, WaveFact,
        SigStrengthUnit, Interval,
        FirstTime, LastTime, ReceiverOffset,
        SystemDCBSapplied, SystemPCVSapplied,
        SystemScaleFac, SystemPhaseShift,
        GlonassSlotFreqNo, GlonassCodPhsBias,
        LeapSeconds, NumSats, PrnObs,
        EoH, haskey(header_hs, rchsVersion),
    )
end


function read_obsdata(oh::RinexObsHeader, f::IOStream)
    v = oh.version[1]
    sysNumObs = oh.systemNumObs
    interval = isnan(oh.interval) ? 10.0 : oh.interval
    toUTC =  oh.firstTime[2]
    
    recommend_length = round(Int64, interval * 160)
    if v > 2.99
        return read_3obsdata(f, sysNumObs, toUTC, recommend_length)
    else
        return read_2obsdata(f, sysNumObs, toUTC, recommend_length)
    end
end

function load_obs(filename::String)
    open(filename, "r") do f
        ohd = read_obsheader(f)
        oh  = parse_obsheader(ohd)
        if haskey(ohd, rchsVersion)
            @warn "crx, convert to rnx first!"
            return nothing
        end
        od  = read_obsdata(oh, f)
        return RinexObs(basename(filename), oh, od)
    end
end

function merge_obs(obss::Array{RinexObs,1})
    len_obss = length(obss)
    tp = Array{Tuple{DateTime,ECEF{Float64}}}(undef, len_obss)
    mheaders = Array{RinexObsHeader,1}()

    for (i, iobs) in enumerate(obss)
        firstT = iobs.header.firstTime[1]
        pos = iobs.header.antennaPosition
        tp[i] = (firstT, pos)
    end
    sort!(tp, by=x->x[1])
    center_pos = tp[ceil(Int64, len_obss / 2)][2]

    data1 = Dict{SatID,Tuple{Array{ObsID,1},Array{SatelliteObsData,1}}}()
    lens = Dict{SatID,Int64}()
    for iobs in obss
        this_pos = iobs.header.antennaPosition
        if 10 < distance(this_pos,
                            center_pos)
            @warn "same sation different position?:\n$center_pos; $this_pos"
            continue
        end
        push!(mheaders, iobs.header)
        for (isat, sod) in iobs.data.obs
            if haskey(data1, isat)
                intersect!(data1[isat][1], sod.obsids)
                if length(data1[isat][1]) > 4
                    lens[isat] += length(sod.dts)
                else
                    lens[isat] = 0
                end
                push!(data1[isat][2], sod)
            else
                data1[isat] = (sod.obsids, [sod])
                sizehint!(data1[isat][2], len_obss)
                lens[isat] = length(sod.dts)
                continue
            end
        end
    end
    data = Dict{SatID,SatelliteObsData}()
    for (isat, (ioids, sods)) in data1
        len = lens[isat]
        len_oids = length(ioids)
        dts = Array{DateTime,1}()
        sizehint!(dts, len)
        obs = Array{Array{RinexDatum,1},1}(undef, len_oids)
        for i in 1:len_oids
            obs[i] = Array{RinexDatum,1}()
            sizehint!(obs[i], len)
        end
        for isod in sods
            append!(dts, isod.dts)
            this_oids = isod.obsids
            this_obss = isod.obs
            for (i, ioid) in enumerate(ioids)
                j = findfirst(x->x == ioid, this_oids)
                append!(obs[i], this_obss[j])
            end
        end
        p = sortperm(dts)
        dts = dts[p]
        for i in 1:len_oids
            obs[i] = obs[i][p]
        end
        data[isat] = SatelliteObsData(isat, ioids, dts, obs)
    end
    mheaders, data, center_pos
end

function load_obss(obs_files::Array{String,1})
    obss = Array{RinexObs,1}(undef, length(obs_files))
    for (i, this_nav_file) in enumerate(obs_files)
        obss[i] = load_obs(this_nav_file)
    end
    merge_obs(obss)
end

function get_rnx3_filename(file::String, roh::RinexObsHeader)
    
    bf = basename(file)
    if bf[10] == '-'
        return  bf
    end

    sn = uppercase(bf[1:4])
    mr = "00"
    cc = HTrg.reverse_geocode(roh.antennaPosition)[4][1]
    s = "R"
    ft = roh.firstTime[1] - roh.firstTime[2]
    fts = string(@sprintf("%04d",year(ft)),
                    @sprintf("%03d",dayofyear(ft)),
                    Dates.format(ft, "HHMM") )
    fp = "01D" # TODO
    fre = roh.interval > 0.99 ? 
                @sprintf("%02.0fS",roh.interval) :
                "00U"
    if length(roh.systemNumObs) == 1
        type = HTgnss.mapSS2C[collect(keys(roh.systemNumObs))[1]]
    else
        type = 'M'
    end

    fmt = roh.iscrx ? "crx" : "rnx"
    filename = string(sn, mr,cc,"_",s,"_",fts,"_",fp,"_",
                        fre,"_",type,"O",".",fmt )
    # NAIN00CAN_R_20112520000_01D_30S_GO.crx.gz
    # MILP00LHT_R_20151150000_01D_01S_GO.crx
    return filename
end
