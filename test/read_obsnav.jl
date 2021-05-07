

# include("HTgnss.jl")

path_rinex = abspath("../data_test/")


function test_obs()

    files = vcat(
                glob("*.rnx", path_rinex),
                glob("*.*o", path_rinex),
                    )

    sort!(files)
    ifile = files[1]
    this_file = abspath(ifile)
    ohd = HTgnss.read_obsheader(this_file)
    oh = HTgnss.parse_obsheader(ohd)
    # @show oh
    @time iobs = HTgnss.load_obs(this_file);
end
function test_nav()
    files = vcat(
                # glob("*.*[nN]", path_rinex),
                # glob("*.*[gG]", path_rinex),
                glob("*.*[pP]", path_rinex),
                )
    sort!(files)
    ifile = files[1]
    this_file = abspath(ifile)

    # nhd = HTgnss.read_navheader(this_file)
    # nh  = HTgnss.parse_navheader(nhd)
    @time inav = HTgnss.load_nav(this_file);
end

function test_pos()

    oh = test_obs()
    nh = test_nav()
    ndata = nh.data.data
    ks = sort!(collect(keys(oh.data.obs)), by=x -> x.str)
    isat = ks[30]
    idata = oh.data.obs[isat]
    dt = idata.dts[2]
    ees = ndata[isat]
    # merge(dict1,dict2)   data::Dict{SatID,EphEpochStore}
    x = HTgnss.calculate_pos(ees, dt)
    @show ees.si, dt
    @test x[1] ≈ 1.764682259684179e7
    @test x[2] ≈ 3.452196727133614e6
    @test x[3] ≈ 1.935522316823225e7

    for (isat, idata) in oh.data.obs
        break
    end
    
    # keys(nh.data.data)
    # nh.data.data[HTgnss.SatID("G11")].eph

end
function test_2017251()
    #= 
    using Glob
    using HTgnss 
    using Dates =#
    p = "/home/t/RD/GNSS/STEC/-1_00_01/2017/251/"
    fs = glob("brdm*.17p", p)
    mnh, mnd = HTgnss.load_navs(fs)
    dt = DateTime("2017-09-06T23:59:42")
    sats = sort!(collect(keys(mnd)), by=x -> x.str)
    for (i, k) in enumerate(sats)
        if string(k) == "S36"
            @show i, k #  (111, S36)
        end
    end
    isat = sats[111]
    ees = mnd[isat]
    # merge(dict1,dict2)   data::Dict{SatID,EphEpochStore}
    x = HTgnss.calculate_pos(ees, dt)


    
end