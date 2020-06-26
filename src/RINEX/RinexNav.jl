


function read_navheader(f::IOStream,
            nav_hstrings_set::Set{String}=nav_hstrings_set,
        )::Dict{String,String}
    header_hs = Dict{String,String}()
    if get_header!(header_hs, f, nav_hstrings_set)
        haskey(header_hs, ohsVersion) ||
        throw(error("header error, not $ohsVersion"))
    
        return header_hs
    end
    throw(error("read header error!"))
end

function read_navheader(filename::String)
    open(filename, "r") do f
        return read_navheader(f)
    end
end



function parse_navheader(header_hs::Dict{String,String})

    version     = parse_nhsVersion(get(header_hs, nhsVersion, ""))
    runBy       = parse_nhsRunBy(get(header_hs, nhsRunBy, ""))
    comment     = parse_nhsComment(get(header_hs, nhsComment, ""))
    ionoCorr    = parse_nhsIonoCorr(get(header_hs, nhsIonoCorr, ""))
    corrSysTime = get(header_hs, nhsCorrSysTime, "")
    deltaUTC    = get(header_hs, nhsDeltaUTC, "")
    dUTC        = get(header_hs, nhsDUTC, "")
    if version[1] < 3
        if version[4] == sstGlonass
            timeSysCorr = parse_nhsCorrSysTime(corrSysTime) # R2.11GPS
        elseif version[4] == sstGPS
            timeSysCorr = parse_nhsDeltaUTC(deltaUTC) 
        elseif version[4] == sstGeosync
            timeSysCorr = parse_nhsDUTC(dUTC) # R2.11GEO
        
        end
    else
        timeSysCorr = parse_nhsTimeSysCorr(get(header_hs, nhsTimeSysCorr, ""))
    end
    leapSeconds = parse_nhsLeapSeconds(get(header_hs, nhsLeapSeconds, "")) # R2.10GLO
    ionAlpha    = parse_nhsIonAlpha(get(header_hs, nhsIonAlpha, "")) # R2.11
    ionBeta     = parse_nhsIonBeta(get(header_hs, nhsIonBeta, ""))
    eoH         = parse_nhsEoH(get(header_hs, nhsEoH, ""))

    RinexNavHeader(version,runBy,comment,
                ionoCorr,timeSysCorr,
                leapSeconds,corrSysTime,deltaUTC,dUTC,
                ionAlpha,ionBeta,eoH )
end
function parse_navd(str::SubString)
    if str[16] == ' ' return 0.0 end
    
    # b = parse(Float64, str[1:15])
    # e = parse(Float64, str[17:19])
    # b * 10^e
    parse(Float64, replace(str, 'D' => 'e'))
end

function read_navline(line::SubString, d::Array{Float64,1})
    len = length(line)
    start = 1
    # @show line
    while start < len
        push!(d, parse_navd(line[start:start + 18]))
        start += 19
    end
    return
end

const pvaSSTs = Set([sstGlonass,sstGeosync])

function parse_2navdt(sbdt::SubString)
    # @show sbdt
    y  = parse(Int64, sbdt[1:2])
    if y < 70
        y += 2000
    else
        y += 1900
    end
    m  = parse(Int64, sbdt[4:5])
    d  = parse(Int64, sbdt[7:8])
    H  = parse(Int64, sbdt[10:11])
    M  = parse(Int64, sbdt[13:14])
    S  = parse(Float64, sbdt[15:19])
    ds = Millisecond(0)
    if S >= 60.0
        ds = Millisecond(S * 1000)
        S = 0.0
    end
    DateTime(y, m, d, H, M, S) + ds
end

function parse_3navdt(sbdt::SubString)
    # @show sbdt
    y  = parse(Int64, sbdt[1:4])

    m  = parse(Int64, sbdt[6:7])
    d  = parse(Int64, sbdt[9:10])
    H  = parse(Int64, sbdt[12:13])
    M  = parse(Int64, sbdt[15:16])
    S  = parse(Int64, sbdt[18:19])
    ds = Second(0)
    if S >= 60
        ds = Second(S)
        S = 0
    end
    DateTime(y, m, d, H, M, S) + ds
end

function read_navdata(nh::RinexNavHeader, f::IOStream, fc::IOStream)

    if nh.version[1] > 2.99
        s = sstUnknown
        index_plus = 1
        check_index = [4,9,12,15,18,21]
    else
        s = nh.version[4]
        index_plus = 0
        check_index = [3, 6, 9, 12, 15, 18]
    end
    index_health = 25
    rnd = Dict{SatID,EphEpochStore}()
    
    
    while !eof(f)
        time_existed = false
        line = readline(f)
        for i in check_index
            line[i] == ' ' ||
                throw(error("no valid epoch line:\n|$line|"))
        end
        if index_plus == 0
            id = parse(Int64, line[1:2])
            si = SatID(s, id)
            dto = parse_2navdt(SubString(line, 4, 22), )
        else
            si = SatID(line[1:3])
            s = si.ss
            dto = parse_3navdt(SubString(line, 5, 23), )
        end
     
        # @show stt2tst[s]
        # @show diff2UTC(dto, stt2tst[s])
        dt = dto + diff2UTC(dto, stt2tst[s])
        if in(s, pvaSSTs)
            n = 3
            index_health = 7
        else 
            n = 7
            index_health = 25
        end
        if haskey(rnd, si)
            # @show si "haskey rnd si"
            ees = rnd[si]
            if haskey(ees.eph, dt)
                # @show ees.keys, dt, line
                # @show dt "haskey ees.eph dt"
                # @show line
                existed_arr = ees.eph[dt].d
                time_existed = true
                # throw(error("duplicate epoch? $si-$dt"))
            end
            # @show dt "this dt"
        else
            ees = EphEpochStore(si, Array{DateTime,1}(),
                            Dict{DateTime,EphEpoch}(),)
            rnd[si] = ees
        end
        arr = Array{Float64,1}()
        sizehint!(arr, 3 + n * 4)
        read_navline(SubString(line, 23 + index_plus,
                                        79 + index_plus),
                    arr, )
        for i in 1:n
            line = readline(f)
            len = length(line)
            read_navline(SubString(line, 4 + index_plus, len),
                            arr, )
        end

        arr[index_health] == 0 || continue
        if second(dto) != 0 continue end
        
        if s == sstGlonass
            if minute(dto) != 15 && minute(dto) != 45
                continue
            end
        elseif s == sstGalileo
            if minute(dto) % 10 != 0 continue end
        end
        
        if time_existed
            # @show si "time_existed"
            # @show dt "time_existed"
            # @show ees.eph[dt].d
            time_existed = false
            for (iien, (iex, inow)) in enumerate(zip(existed_arr, arr, ))
                if iex == inow continue end
                iienstr = @sprintf("%02d",iien)
                warnline = "$si $dto NO.$iienstr data different: $iex, $inow"
                write(fc, warnline, "\n")
                if s == sstGlonass 
                    # @warn warnline
                    continue
                end
                if s == sstGalileo
                    # @warn warnline
                    continue 
                #  Test this by comparing Toe values. OrbitEphStore.cpp Line 276
                end
                if s == sstBeiDou
                    # @warn warnline
                    continue 
                end
                # throw(error(warnline))
                @warn warnline
            end
            continue
        end
        push!(ees.keys, dt)
        sort!(ees.keys)
        ees.eph[dt] = EphEpoch(si, dt, arr)
    end
    # @show rnd
    RinexNavData(rnd)
end


function load_nav(filename::String)
    open(filename, "r") do f
        check_file = string(filename, ".check")
        open(check_file, "w") do fc
            nhd = read_navheader(f)
            nh  = parse_navheader(nhd)
            nd  = read_navdata(nh, f, fc)
            return RinexNav(basename(filename), nh, nd)
        end
    end
end

function merge_navs(navs::Array{RinexNav,1})

    data = Dict{SatID,EphEpochStore}()
    mheaders = Array{RinexNavHeader,1}()

    for inav in navs
        push!(mheaders, inav.header)
        for (isat, ees) in inav.data.data
            if haskey(data, isat)
                this_data = data[isat]
                this_keys = this_data.keys
                this_eph = this_data.eph
            else
                data[isat] = EphEpochStore(ees.si, ees.keys, ees.eph)
                continue
            end
            for (idt, iee) in ees.eph
                if haskey(this_eph, idt)
                    continue
                end
                this_eph[idt] = iee
                push!(this_keys, idt)
            end
            sort!(this_keys)
        end
    end
    mheaders, data
end

function load_navs(nav_files::Array{String,1})
    navs = Array{RinexNav,1}(undef, length(nav_files))
    for (i, this_nav_file) in enumerate(nav_files)
        navs[i] = load_nav(this_nav_file)
    end
    merge_navs(navs)
end


function get_freq(navdata::Dict{SatID,EphEpochStore},
    basefrequencies::Dict{SatelliteSystemType,Dict{CarrierBand,Tuple{Float64,Float64}}}=basefrequencies)
    freq = Dict{SatID,Dict{CarrierBand,Float64}}()
    for (isat, ees) in navdata
        
        freqn = 0.0
        if isat.ss == sstGlonass
            freqng = NaN
            for (idt, iee) in ees.eph
                if isnan(freqng) freqng = iee.d[11]
                elseif freqng == iee.d[11] continue
                else @warn string("$isat frequency number is different? $freqng ", iee[11])
                end
            end
            if !isnan(freqng) freqn = freqng end
        end
        this_freq = Dict{CarrierBand,Float64}()
        for (icb, ibf) in basefrequencies[isat.ss]
            this_freq[icb] = ibf[1]  + ibf[2] * freqn
        end
        freq[isat]  = this_freq
    end
    freq
end