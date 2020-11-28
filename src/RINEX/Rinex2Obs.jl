

# const epoch_dt_format2 = Dates.DateFormat("yy mm dd HH MM SS.sssssss")
function parse_2epoch_time(ephs::String, toUTC::Millisecond)
    
    dtstr = SubString(ephs, 2, 26)
    y = parse(Int64, dtstr[1:2])
    if y < 70 y += 2000
    else y += 1900
    end

    m = parse_Int_or_Empty(dtstr[4:5])
    d = parse_Int_or_Empty(dtstr[7:8])
    H = parse_Int_or_Empty(dtstr[10:11])
    M = parse_Int_or_Empty(dtstr[13:14])
    S = parse_Int_or_Empty(dtstr[16:17])
    # s = parse(Int64, dtstr[19:25])
    # TODO only Millisecond three digit maybe later use TimeDates Nanosecond.
    s = parse_Int_or_Empty(dtstr[19:21]) 
    this_dt = Dates.DateTime(y, m, d, H, M, S, s)
    # @show "  $ephs"
    # @show "$this_dt"
    this_dt += toUTC
    this_dt
end


function add_epoch_line2!(sods::Dict{SatID,SatelliteObsData},
                f::IOStream, satid::SatID, this_dt::DateTime, 
                systemNumObs::D_SystemNumObs,
                recommend_length::Int64, )
    
    obsNum, obsIds = get(systemNumObs, satid.ss, (0, Array{ObsID,1}()))
    if obsNum == 0
        ss = collect(keys(systemNumObs))[1]
        obsNum, _ = systemNumObs[ss]
        nl = ceil(Int64, obsNum / 5.0)
        # @show obsNum, nl
        for i in 1:nl
            # @show i, 
            readline(f)
        end
        return 
        throw(error("no such system $satid"))
    end

    if haskey(sods, satid)
        this_sod = sods[satid]
        this_dts = this_sod.dts
        this_obs = this_sod.obs
    else
        this_dts  = Array{DateTime,1}()
        sizehint!(this_dts, recommend_length)
        this_obs = Array{Array{RinexDatum,1},1}(undef, obsNum)
        for ion in 1:obsNum
            this_obs[ion] = Array{RinexDatum,1}()
            sizehint!(this_obs[ion], recommend_length)
        end
        sods[satid] = SatelliteObsData(satid, obsIds,
                                        this_dts, this_obs)
    end
    si = 81
    line = ""
    for ion in 1:obsNum
        # @show ion, si
        if si > 80
            line = rpad(readline(f), 80)
            si = 1
        end
        push!(this_obs[ion],
                RinexDatum(SubString(line, si, si + 15)), )
        si += 16
    end
    push!(this_dts, this_dt)
    return
end

function add_this_epoch_comments2!(comments::Dict{DateTime,String},
                dt_before::DateTime, f::IOStream, numSVs::Int64, )
    this_comments = Array{String,1}(undef, numSVs)
    for ii_el in 1:numSVs
        this_comments[ii_el]  = readline(f)
    end
    if haskey(comments, dt_before)
        comments[dt_before] = string(comments[dt_before],"\n",
                                join(this_comments, "\n"))
    else
        comments[dt_before] = join(this_comments, "\n")
    end
end


function read_one_epoch2(f::IOStream,
    epochs::Dict{DateTime,EpochHeader},
    comments::Dict{DateTime,String},
    add_this_epoch_line2::Function,
    toUTC::Millisecond,
    ephs_dr_set::Set{Int64},
    dt_before::DateTime,)::DateTime
    ephs = readline(f)
    
    if ephs[1] != ' ' || ephs[4] != ' ' || ephs[7] != ' '
        throw(error("epoch line seems wrong! \n|$ephs|"))
    end

    epf = parse(Int64, ephs[29])


    numSVs = parse(Int64, ephs[30:32])
    
    if numSVs == 0 
        @warn "0 satellite? \n|$ephs|"
    end
    
    if epf in ephs_dr_set # 0,1,6 data record
        this_dt = parse_2epoch_time(ephs, toUTC)

        if haskey(epochs, this_dt) 
            @warn "duplicate epoch? $ephs"
            delete!(epochs, this_dt) 
        end
        len_ephs = length(ephs)
        if len_ephs > 68
            index_end = len_ephs > 80 ? 80 : len_ephs
            rco = parse(Float64, ephs[69:index_end])
        else
            rco = 0.0
        end

        epochs[this_dt] = EpochHeader(this_dt, epf, numSVs, rco)

        # ephs_arr = Array{String,1}()
        
        satIndex = Array{SatID,1}(undef, numSVs)
        start_index = 30
        for ndx in 1:numSVs
            if start_index > 65
                ephs = readline(f)
                start_index = 30
            end
            start_index += 3
            satIndex[ndx] = SatID(ephs[start_index:start_index + 2])
        end
        for ii_el in 1:numSVs
            add_this_epoch_line2(f, satIndex[ii_el], this_dt)
        end
    else
        add_this_epoch_comments2!(comments, dt_before, f, numSVs)
        this_dt = dt_before
    end
    this_dt
end



function read_2obsdata(f::IOStream, sysNumObs::D_SystemNumObs,
    toUTC::Millisecond=Millisecond(0),
    recommend_length::Int64=4800,
    ephs_dr_set::Set{Int64}=Set([0, 1, 6]))
    # rod = RinexObsData()
    # @unpack_RinexObsData rod
    # epochs, comments, obs, flag, dt

    epochs  = Dict{DateTime,EpochHeader}()
    comments = Dict{DateTime,String}()

    sods = Dict{SatID,SatelliteObsData}()

    add_this_epoch_line2(f::IOStream,
        satid::SatID, this_dt::DateTime) =
                    add_epoch_line2!(sods, f, satid, this_dt,
                                sysNumObs, recommend_length, )

    dt_before = DateTime(0, 1, 1, 0, 0, 0)
    while !eof(f)
        dt_before = read_one_epoch2(f,
                epochs, comments,
                add_this_epoch_line2,
                toUTC, ephs_dr_set, dt_before)
    end
    # sys = Dict{SatSys,Array{SatID,1}}()
    # # , sys length of each sat
    # init_sys!(sys, dts)
    # RinexObsData(epochs, comments, obs, flags, dts, sys)

    # @bp
    # @show epochs
    # @show comments
    # @show sods
    RinexObsData(epochs, comments, sods)
end
