

const epoch_dt_format3 = Dates.DateFormat("yyyy mm dd HH MM SS.sssssss")

function parse_3epoch_time(ephs::String,toUTC::Millisecond,
    epoch_dt_format3::DateFormat=epoch_dt_format3)
    
    dtstr = SubString(ephs, 3, 29)
    y = parse(Int64, dtstr[1:4])
    m = parse(Int64, dtstr[6:7])
    d = parse(Int64, dtstr[9:10])
    H = parse(Int64, dtstr[12:13])
    M = parse(Int64, dtstr[15:16])
    S = parse(Int64, dtstr[18:19])
    s = parse(Int64, dtstr[21:23])
    this_dt = Dates.DateTime(y, m, d, H, M, S, s)
    # @show ephs
    # @show this_dt
    this_dt += toUTC
    this_dt
end


function add_epoch_line3!(sods::Dict{SatID,SatelliteObsData},
                line::String, this_dt::DateTime, 
                systemNumObs::D_SystemNumObs,
                recommend_length::Int64, )

    satid = SatID(SubString(line, 1, 3))
    obsNum, obsIds = get(systemNumObs, satid.ss, (0, Array{ObsID,1}()))
    
    obsNum == 0 && throw(error("no such system $satid"))
    line = rpad(line, 3 + 16 * obsNum)

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

    push!(this_dts, this_dt)
    si = 4
    for ion in 1:obsNum
        push!(this_obs[ion],
                RinexDatum(SubString(line, si, si + 15)), )
        si += 16
    end

end

function add_this_epoch_comments3!(comments::Dict{DateTime,String},
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


function read_one_epoch3(f::IOStream,
    epochs::Dict{DateTime,EpochHeader},
    comments::Dict{DateTime,String},
    add_this_epoch_line3::Function,
    toUTC::Millisecond,
    ephs_dr_set::Set{Int64},
    dt_before::DateTime,)::DateTime

    ephs = readline(f)

    if ephs[1] != '>'
        throw(error("epoch doesn't start with > ! \n$ephs"))
    end

    epf = parse(Int64, ephs[32])
    numSVs = parse(Int64, ephs[33:35])

    if epf in ephs_dr_set # 0,1,6 data record
        this_dt = parse_3epoch_time(ephs, toUTC)
        if haskey(epochs, this_dt) 
            @warn "duplicate epoch? $ephs"
            delete!(epochs, this_dt) 
        end
        len_ephs = length(ephs)
        if len_ephs > 41
            index_end = len_ephs > 55 ? 55 : len_ephs
            rco = parse(Float64, ephs[42:index_end])
        else
            rco = 0.0
        end
        epochs[this_dt] = EpochHeader(this_dt, epf, numSVs, rco)

        for ii_el in 1:numSVs
            line = readline(f)
            add_this_epoch_line3(line, this_dt)
        end
    else
        add_this_epoch_comments3!(comments, dt_before, f, numSVs)
        this_dt = dt_before
    end
    this_dt
end



function read_3obsdata(f::IOStream, sysNumObs::D_SystemNumObs,
    toUTC::Millisecond=Millisecond(0),
    recommend_length::Int64=4800,
    ephs_dr_set::Set{Int64}=Set([0, 1, 6]))

    epochs  = Dict{DateTime,EpochHeader}()
    comments = Dict{DateTime,String}()

    sods = Dict{SatID,SatelliteObsData}()

    add_this_epoch_line3(line::String,
        this_dt::DateTime) = add_epoch_line3!( 
                                sods,
                                line, this_dt,
                                sysNumObs, recommend_length, )

    dt_before = DateTime(0, 1, 1, 0, 0, 0)
    while !eof(f)
        dt_before = read_one_epoch3(f,
                epochs, comments,
                add_this_epoch_line3,
                toUTC,
                ephs_dr_set, dt_before)
    end
    
    RinexObsData(epochs, comments, sods)
end
