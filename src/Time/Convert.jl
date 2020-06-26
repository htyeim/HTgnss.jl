

# UT


function datetime2gpsws(dt::DateTime)
    d = diff2UTC(dt, tstGPS)
    jd = datetime2julian(dt - d)
    jd -= GPS_EPOCH_JD
    w = floor(Int64, jd) ÷ 7
    s = round(Int64, (jd - w * 7) * 86400)
    return w, s
end



function gpsws2datetime(w::Int64, s::Union{Int64,Float64})
    dow =  s ÷ 86400
    jd = w * 7 + dow + GPS_EPOCH_JD +
            (s - dow * 86400) / 86400.0
    dt = julian2datetime(jd)
    dt + diff2UTC(dt, tstGPS)
end



