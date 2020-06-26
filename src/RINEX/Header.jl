const rchsVersion    = "CRINEX VERS   / TYPE"
const rchsProg       = "CRINEX PROG / DATE"
# Nav
const nhsVersion     = "RINEX VERSION / TYPE"
const nhsRunBy       = "PGM / RUN BY / DATE"
const nhsComment     = "COMMENT"
const nhsIonoCorr    = "IONOSPHERIC CORR"
const nhsTimeSysCorr = "TIME SYSTEM CORR"
const nhsLeapSeconds = "LEAP SECONDS"
    # R2.10GLO
const nhsCorrSysTime = "CORR TO SYSTEM TIME"
    # R2.11GPS
const nhsDeltaUTC    = "DELTA-UTC: A0,A1,T,W"
    # R2.11GEO
const nhsDUTC        = "D-UTC A0,A1,T,W,S,U"
    # R2.11
const nhsIonAlpha    = "ION ALPHA"
    # R2.11
const nhsIonBeta     = "ION BETA"
const nhsEoH         = "END OF HEADER"


# Obs
const ohsVersion           = nhsVersion
const ohsRunBy             = nhsRunBy
const ohsComment           = nhsComment
const ohsMarkerName        = "MARKER NAME"
const ohsMarkerNumber      = "MARKER NUMBER"
const ohsMarkerType        = "MARKER TYPE"
const ohsObserver          = "OBSERVER / AGENCY"
const ohsReceiver          = "REC # / TYPE / VERS"
const ohsAntennaType       = "ANT # / TYPE"
const ohsAntennaPosition   = "APPROX POSITION XYZ"
const ohsAntennaDeltaHEN   = "ANTENNA: DELTA H/E/N"
const ohsAntennaDeltaXYZ   = "ANTENNA: DELTA X/Y/Z"
const ohsAntennaPhaseCtr   = "ANTENNA: PHASECENTER"
const ohsAntennaBsightXYZ  = "ANTENNA: B.SIGHT XYZ"
const ohsAntennaZeroDirAzi = "ANTENNA: ZERODIR AZI"
const ohsAntennaZeroDirXYZ = "ANTENNA: ZERODIR XYZ"
const ohsCenterOfMass      = "CENTER OF MASS: XYZ"
const ohsNumObs            = "# / TYPES OF OBSERV"
const ohsSystemNumObs      = "SYS / # / OBS TYPES"
const ohsWaveFact          = "WAVELENGTH FACT L1/2"
const ohsSigStrengthUnit   = "SIGNAL STRENGTH UNIT"
const ohsInterval          = "INTERVAL"
const ohsFirstTime         = "TIME OF FIRST OBS"
const ohsLastTime          = "TIME OF LAST OBS"
const ohsReceiverOffset    = "RCV CLOCK OFFS APPL"
const ohsSystemDCBSapplied = "SYS / DCBS APPLIED"
const ohsSystemPCVSapplied = "SYS / PCVS APPLIED"
const ohsSystemScaleFac    = "SYS / SCALE FACTOR"
const ohsSystemPhaseShift  = "SYS / PHASE SHIFT"
const ohsGlonassSlotFreqNo = "GLONASS SLOT / FRQ #"
const ohsGlonassCodPhsBias = "GLONASS COD/PHS/BIS"
const ohsLeapSeconds       = nhsLeapSeconds
const ohsNumSats           = "# OF SATELLITES"
const ohsPrnObs            = "PRN / # OF OBS"
const ohsEoH               = nhsEoH


function get_header!(header_hs::Dict{String,String},
    f::IOStream,
    hstrings_set::Set{String},
    end_label::String=ohsEoH)::Bool

    while !eof(f)
        line = rstrip(readline(f))
        label = line[61:end]
        if !in(label, hstrings_set)
            @warn "don't have such label in rinex |$label|"
        end
        if haskey(header_hs, label)
            header_hs[label] = string(header_hs[label], "\n", line[1:60], )
        else
            header_hs[label] = line[1:60]
        end
        if isequal(label, end_label)
            return true
        end
    end
    throw(error("file no $end_label"))
    false
end




function returninput(input::String)::String
    return input
end

#####################################
function parse_rchsVersion(input::String)::String
    return input
end
function parse_rchsProg(input::String)::String
    return input
end
#####################################
# nav header parse start
begin

    function setFileSystem(c::Char, v::Float64)
        if c == "M" && v < 3.0
            throw(error("rinex 2 'Mixed' Nav files do not existed"))
        end
        char2SatelliteSystemType(c)
    end

    function parse_nhsVersion(input::String)
        version  = parse(Float64, input[ 1:20])
        fileType = input[21:40]
        ftc  = uppercase(fileType[1])
        fileSys  = input[41:60]
        
        if version > 2.99
            if ftc != 'N'
                throw(error("File type is not Nav $fileType"))
            end
            ssc = uppercase(fileSys[1])
        else
            if ftc == 'N'     ssc = 'G'
            elseif ftc == 'G' ssc = 'R'
            elseif ftc == 'H' ssc = 'S'
            else
                throw(error("version 2 file type is invalid $fileType"))
            end
        end
        ss = setFileSystem(ssc, version)

        # fileType = strip(input[21:40])
        # fileSys  = strip(input[41:60])
        return version, fileType, fileSys, ss
    end
    # Nav
    function parse_nhsRunBy(input::String)
        return strip(input[1:20]), strip(input[21:40]), strip(input[41:60])
    end
    parse_nhsComment(input::String)     = returninput(input)
    parse_nhsIonoCorr(input::String)    = returninput(input)
    function parse_nhsTimeSysCorr(input::String)
        len = length(input) ÷ 60
        arr = Dict{TimeCorrectionType,TimeSystemCorrection}()
        for i in 1:len
            start_index = (i - 1) * 61 + 1
            line = SubString(input, start_index, start_index + 59)
            t = string(line[1:4])
            tp = str2TimeCorrectionType(t)
            A0 = parse(Float64, line[6:22])
            A1 = parse(Float64, line[23:38])
            refSOW = parse(Int64, line[39:45])
            refWeek = parse(Int64, line[46:51])
            geoProvider = string(line[52:57])
            geoUTCid = string(line[58:60])
            arr[tp]  = getTimeSystemCorrection(tp, A0, A1,
                                        refSOW, refWeek,
                                        geoProvider, geoUTCid)
        end
        arr
    end

    function parse_lpn(s::SubString)
        a = strip(s)
        if a == ""
            return 0
        else
            return parse(Int64, a)
        end
    end
    function parse_nhsLeapSeconds(line::String)
        if line == "" return 0, 0, 0, 0 end        
        leapSeconds = parse(Int64, SubString(line, 1, 6))
        leapDelta = parse_lpn(SubString(line, 7, 12))
        leapWeek  = parse_lpn(SubString(line, 13, 18))
        leapDay   = parse_lpn(SubString(line, 19, 20))
        leapSeconds, leapDelta, leapWeek, leapDay
    end
    # R2.10GLO
    function parse_nhsCorrSysTime(line::String)
        arr = Dict{TimeCorrectionType,TimeSystemCorrection}()
        # line =  "  2011    09    08    1.578591763973e-07                    CORR TO SYSTEM TIME"
        tp = str2TimeCorrectionType("GLUT")
        A0 = parse(Float64, line[22:40])
        A1 = 0.0
        refYr  = parse(Int64, line[1:6])
        refMon = parse(Int64, line[7:12])
        refDay = parse(Int64, line[13:18])
        gldt = DateTime(refYr, refMon, refDay, 0, 0, 0)

        utdt = gldt + diff2UTC(gldt, tstGLO)
        
        refWeek, refSOW = HTgnss.datetime2gpsws(utdt)
        # @show gldt, utdt, refWeek, refSOW                                
        geoProvider = "    "
        geoUTCid = " 3"
        frTST, toTST = tct2TimeSystemTypes(tp)
        arr[tp] = TimeSystemCorrection(tp, frTST, toTST,
                        A0, A1, refWeek, refSOW,
                        refYr, refMon, refDay,
                        geoProvider, geoUTCid)
        arr
    end
    # R2.11GPS
    function parse_nhsDeltaUTC(line::String)
        arr = Dict{TimeCorrectionType,TimeSystemCorrection}()
        # line =  "   -0.186264514923D-08-0.106581410364D-13   503808     1652 DELTA-UTC: A0,A1,T,W"
        tp = str2TimeCorrectionType("GPUT")
        A0 = parse(Float64, replace(line[4:22], 'D' => 'E'))
        A1 = parse(Float64, replace(line[23:41], 'D' => 'E'))

        refSOW = parse(Int64, line[42:50])
        refWeek = parse(Int64, line[51:59])
        
        
        geoProvider = "    "
        geoUTCid = " 0"

        arr[tp]  = getTimeSystemCorrection(tp, A0, A1,
                            refSOW, refWeek,
                            geoProvider, geoUTCid)
        arr
    end
    # R2.11GEO
    function parse_nhsDUTC(line::String)
        arr = Dict{TimeCorrectionType,TimeSystemCorrection}()
        # line =  
        tp = str2TimeCorrectionType("SBUT")
        A0 = parse(Float64, line[1:19])
        A1 = parse(Float64, line[20:38])

        refSOW = parse(Int64, line[38:45])
        refWeek = parse(Int64, line[46:51])

        geoProvider = line[52:57]
        geoUTCid = line[58:59]

        arr[tp]  = getTimeSystemCorrection(tp, A0, A1,
                            refSOW, refWeek,
                            geoProvider, geoUTCid)
        arr
    end
    # R2.11
    parse_nhsIonAlpha(input::String)    = returninput(input)
    # R2.11
    parse_nhsIonBeta(input::String)     = returninput(input)
    parse_nhsEoH(input::String)         = returninput(input)

end


const nav_hs_function = Dict{String,Function}(
    rchsVersion    => parse_rchsVersion,
    rchsProg       => parse_rchsProg,
    nhsVersion     => parse_nhsVersion,
    nhsRunBy       => parse_nhsRunBy,
    nhsComment     => parse_nhsComment,
    nhsIonoCorr    => parse_nhsIonoCorr,
    nhsTimeSysCorr => parse_nhsTimeSysCorr,
    nhsLeapSeconds => parse_nhsLeapSeconds, # R2.10GLO
    nhsCorrSysTime => parse_nhsCorrSysTime, # R2.11GPS
    nhsDeltaUTC    => parse_nhsDeltaUTC,    # R2.11GEO
    nhsDUTC        => parse_nhsDUTC,        # R2.11
    nhsIonAlpha    => parse_nhsIonAlpha,    # R2.11
    nhsIonBeta     => parse_nhsIonBeta,
    nhsEoH         => parse_nhsEoH,

)

const nav_hstrings_set = Set(keys(nav_hs_function))
# nav header parse end



#####################################
# obs header parse begin
begin
    function parse_ohsVersion(input::String)
        version  = parse(Float64, input[ 1:20])
        fileType = uppercase(input[21])

        fileSys  = char2SatelliteSystemType(input[41])
        # fileType = strip(input[21:40])
        # fileSys  = strip(input[41:60])
        return version, fileType, fileSys
    end

    parse_ohsRunBy(input::String) = parse_nhsRunBy(input)
    parse_ohsComment(input::String) = parse_nhsComment(input)
    parse_ohsMarkerName(input::String) = returninput(input)
    parse_ohsMarkerNumber(input::String) = returninput(input)
    parse_ohsMarkerType(input::String) = returninput(input)
    function parse_ohsObserver(input::String)
        return strip(input[1:20]), strip(input[21:60])
    end
    parse_ohsReceiver(input::String) = returninput(input)
    parse_ohsAntennaType(input::String) = returninput(input)
    function parse_ohsAntennaPosition(input::String)
        x = parse(Float64, input[1:14])
        y = parse(Float64, input[15:28])
        z = parse(Float64, input[29:42])
        ECEF{Float64}(x, y, z)
    end
    parse_ohsAntennaDeltaHEN(input::String) = returninput(input)
    parse_ohsAntennaDeltaXYZ(input::String) = returninput(input)
    parse_ohsAntennaPhaseCtr(input::String) = returninput(input)
    parse_ohsAntennaBsightXYZ(input::String) = returninput(input)
    parse_ohsAntennaZeroDirAzi(input::String) = returninput(input)
    parse_ohsAntennaZeroDirXYZ(input::String) = returninput(input)
    parse_ohsCenterOfMass(input::String) = returninput(input)
    parse_ohsNumObs(input::String) = returninput(input)
    function NumObs2SystemNumObs(obs_codes::Array{String,1},
            obsn::Int64, sys::SatelliteSystemType,
            obst::D_SystemNumObs)
        this_obst = Array{ObsID,1}(undef, obsn)
        for iot in 1:obsn
            # @show obs_codes[iot]
            this_obst[iot] = ObsID(obs_codes[iot], sys)
        end
        obst[sys] = obsn, this_obst
        return
    end
    function parse_ohsSystemNumObs2(input::String, sys::SatelliteSystemType=sstMixed)
        
        
        obsn = parse(Int64, input[1:6])
        maxObsPerLine = 9
        len_max = obsn ÷ maxObsPerLine
        res     = obsn % maxObsPerLine
        len_max += res == 0 ? 0 : 1
        lines = split(input, "\n")
        length(lines) == len_max ||
                throw(error("line number error for $obsn!\n|$lines|"))
        i_lines = 1

        obs_codes = Array{String,1}()
        this_line = lines[i_lines] 
        start_index = 5
        for iot in  1:obsn
            start_index += 6
            c = this_line[start_index:start_index + 1]
            if c[1] == 'C'     cc = string('C', c[2], 'C')
            elseif c[1] == 'P' cc = string('C', c[2], 'P')
            else cc = string(c, " ")
            end
            push!(obs_codes, cc)
            if iot % maxObsPerLine == 0 && i_lines < len_max
                i_lines += 1
                this_line = lines[i_lines]
                start_index = 5
            end
        end
        # @show obs_codes
        obst = D_SystemNumObs()
        if sys == sstMixed
            for isys in [sstGPS,sstGlonass,sstGalileo,
                            sstGeosync,sstBeiDou,sstQZSS,
                            sstIRNSS]
                NumObs2SystemNumObs(obs_codes, obsn, isys, obst)
            end
        else
            NumObs2SystemNumObs(obs_codes, obsn, sys, obst)
        end
        obst
    end
    function parse_ohsSystemNumObs3(input::String)
        lines = split(input, "\n")
        lines_n = length(lines) + 1
        i_lines = 1
        obst = D_SystemNumObs()
        while i_lines < lines_n
            this_line = lines[i_lines]
            i_lines += 1
            satSysC = this_line[1]
            satSys = char2SatelliteSystemType(satSysC)
            obsn = parse(Int64, this_line[3:6])
            this_obst = Array{ObsID,1}(undef, obsn)
            start_index = 4
            for iot in 1:obsn
                start_index += 4
                this_obst[iot] = 
                    ObsID(this_line[start_index:start_index + 2],
                            satSys)
                if start_index > 55
                    this_line = lines[i_lines]
                    i_lines +=  1
                    start_index = 4
                end
            end
            obst[satSys] = (obsn, this_obst)
        end
        obst
    end

    parse_ohsWaveFact(input::String) = returninput(input)
    parse_ohsSigStrengthUnit(input::String) = returninput(input)
    function parse_ohsInterval(input::String)
        if input == "" return NaN end
        parse(Float64, input[1:10])
    end
    # todo get time system
    
    function parse_ohsFirstTime(input::String)
        # @show SubString(input, 3, 43)
        dtstr = SubString(input, 3, 43)
        y = parse(Int64, dtstr[1:4])
        m = parse(Int64, dtstr[9:10])
        d = parse(Int64, dtstr[15:16])
        H = parse(Int64, dtstr[21:22])
        M = parse(Int64, dtstr[27:28])
        S = parse(Int64, dtstr[32:33])
        s = parse(Int64, dtstr[35:41])
        #  2011     9     8     0     0    0.1330000     GPS         TIME OF FIRST OBS
        dt = DateTime(y, m, d, H, M, S, s ÷ 1e4)
        tststr = input[49:50]
        haskey(str2tst, tststr) || throw(error("no such time system:\n$input"))
        d = diff2UTC(dt, str2tst[tststr])
        dt + d,  d
    end
    parse_ohsLastTime(input::String) = returninput(input)
    parse_ohsReceiverOffset(input::String) = returninput(input)
    parse_ohsSystemDCBSapplied(input::String) = returninput(input)
    parse_ohsSystemPCVSapplied(input::String) = returninput(input)
    parse_ohsSystemScaleFac(input::String) = returninput(input)
    parse_ohsSystemPhaseShift(input::String) = returninput(input)
    parse_ohsGlonassSlotFreqNo(input::String) = returninput(input)
    parse_ohsGlonassCodPhsBias(input::String) = returninput(input)
    parse_ohsLeapSeconds(input::String) = returninput(input)
    parse_ohsNumSats(input::String) = returninput(input)
    parse_ohsPrnObs(input::String) = returninput(input)
    parse_ohsEoH(input::String) = returninput(input)
    function parse_ohsFile(intput::String)
        return basename(intput)
    end
end

const obs_hs_function = Dict{String,Function}(
    rchsVersion          => parse_rchsVersion,
    rchsProg             => parse_rchsProg,
    ohsVersion           => parse_ohsVersion,
    ohsRunBy             => parse_ohsRunBy,
    ohsComment           => parse_ohsComment,
    ohsMarkerName        => parse_ohsMarkerName,
    ohsMarkerNumber      => parse_ohsMarkerNumber,
    ohsMarkerType        => parse_ohsMarkerType,
    ohsObserver          => parse_ohsObserver,
    ohsReceiver          => parse_ohsReceiver,
    ohsAntennaType       => parse_ohsAntennaType,
    ohsAntennaPosition   => parse_ohsAntennaPosition,
    ohsAntennaDeltaHEN   => parse_ohsAntennaDeltaHEN,
    ohsAntennaDeltaXYZ   => parse_ohsAntennaDeltaXYZ,
    ohsAntennaPhaseCtr   => parse_ohsAntennaPhaseCtr,
    ohsAntennaBsightXYZ  => parse_ohsAntennaBsightXYZ,
    ohsAntennaZeroDirAzi => parse_ohsAntennaZeroDirAzi,
    ohsAntennaZeroDirXYZ => parse_ohsAntennaZeroDirXYZ,
    ohsCenterOfMass      => parse_ohsCenterOfMass,
    ohsNumObs            => parse_ohsNumObs,
    ohsSystemNumObs      => parse_ohsSystemNumObs3,
    ohsWaveFact          => parse_ohsWaveFact,
    ohsSigStrengthUnit   => parse_ohsSigStrengthUnit,
    ohsInterval          => parse_ohsInterval,
    ohsFirstTime         => parse_ohsFirstTime,
    ohsLastTime          => parse_ohsLastTime,
    ohsReceiverOffset    => parse_ohsReceiverOffset,
    ohsSystemDCBSapplied => parse_ohsSystemDCBSapplied,
    ohsSystemPCVSapplied => parse_ohsSystemPCVSapplied,
    ohsSystemScaleFac    => parse_ohsSystemScaleFac,
    ohsSystemPhaseShift  => parse_ohsSystemPhaseShift,
    ohsGlonassSlotFreqNo => parse_ohsGlonassSlotFreqNo,
    ohsGlonassCodPhsBias => parse_ohsGlonassCodPhsBias,
    ohsLeapSeconds       => parse_ohsLeapSeconds,
    ohsNumSats           => parse_ohsNumSats,
    ohsPrnObs            => parse_ohsPrnObs,
    ohsEoH               => parse_ohsEoH,
)

const obs_hstrings_set = Set(keys(obs_hs_function))

# obs header parse end
