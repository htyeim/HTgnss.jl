


function computeRelativityCorrection(x::Float64,y::Float64,z::Float64,
    vx::Float64,vy::Float64,vz::Float64,)
    relcorr = -2.0 * (x * vx + y * vy + z * vz) / C_MPS^2
    return relcorr
end

function getSidTime(dt::DateTime)
    jd = datetime2julian(DateTime(year(dt),
                            month(dt), day(dt)))
    jc = (jd - 2451545.0) / 36525.0
    sid = 24110.54841 + jc * (8640184.812866 +
                            jc * (0.093104 - 
                                jc * 0.0000062 ) )
    sid /= 3600.0
    sid = sid % 24.0
    if sid < 0.0 sid += 24.0 end
    return sid
end

function secondofday(dt::DateTime)
    return hour(dt) * 3600.0 + minute(dt) * 60.0 +
                second(dt) + millisecond(dt) / 100000.0
end



function derivative(inState::Array{Float64,1},
                    accel::Array{Float64,1},
                    j20::Float64=PZ90Ellipsoid.j20,
                    mu::Float64=PZ90Ellipsoid.gm_km,
                    ae::Float64=PZ90Ellipsoid.a_km,)
    x  = inState[1]
    y  = inState[3]
    z  = inState[5]
    r² = x^2 + y^2 + z^2
    r  = sqrt(r²)
    xmu = mu / r²
    rho = ae / r
    xr  = x / r
    yr  = y / r
    zr  = z / r
    zr2 = zr^2
    k1  = j20 * xmu * 1.5 * rho^2
    cm  = k1 * (1.0 - 5.0 * zr2)
    cmz = k1 * (3.0 - 5.0 * zr2)
    k2  = cm - xmu

    gloAx = k2 * xr + accel[1]
    gloAy = k2 * yr + accel[2]
    gloAz = (cmz - xmu) * zr + accel[3]

    dxt = zeros(6)

    dxt[1] = inState[2]
    dxt[2] = gloAx
    dxt[3] = inState[4]
    dxt[4] = gloAy
    dxt[5] = inState[6]
    dxt[6] = gloAz
    dxt
end

function calculate_Fit_pos(epoch::DateTime,
        ephTime::DateTime,
        clkbias::Float64, # tau
        clkdrift::Float64, # gamma
        ix::Float64,iy::Float64,iz::Float64,
        ivx::Float64,ivy::Float64,ivz::Float64,
        iax::Float64,iay::Float64,iaz::Float64,
        health::Float64=-1.0,
        step::Float64=1.0,
        we::Float64=PZ90Ellipsoid.ge.angVelocity,
)
    elapte = (epoch - ephTime).value / 1000.0 # TODO  second?
    # Values to be returned will be stored here
    # If the exact epoch is found, let's return the values
    if epoch == ephTime        # exact match for epoch
        oxx = ix * 1.e3;   # m
        oxy = iy * 1.e3;   # m
        oxz = iz * 1.e3;   # m
        ovx = ivx * 1.e3;  # m/sec
        ovy = ivy * 1.e3;  # m/sec
        ovz = ivz * 1.e3;  # m/sec
    # In the GLONASS system, 'clkbias' already includes the
    # relativistic correction, therefore we must substract the late
    # from the former.
        relcorr = computeRelativityCorrection(oxx, oxy, oxz, ovx, ovy, ovz)
        clkbias = clkbias + clkdrift * elapte - relcorr;
        clkdrift = clkdrift;
        frame = fmPZ90;

    # We are done, let's return
        return Xvt(ECEF(oxx, oxy, oxz), (ovx, ovy, ovz),
    relcorr,clkbias,clkdrift,frame,
    health == 1.0 ? hsHealthy : hsUnhealthy)
    end

    # Get the data out of the GloRecord structure
    px = ix   # X coordinate (km)
    vx = ivx   # X velocity   (km/s)
    ax = iax   # X acceleration (km/s^2)

    py = iy   # Y coordinate
    vy = ivy   # Y velocity
    ay = iay   # Y acceleration

    pz = iz   # Z coordinate
    vz = ivz   # Z velocity
    az = iaz   # Z acceleration

    # We will need some PZ-90 ellipsoid parameters

    # Get sidereal time at Greenwich at 0 hours UT

    gst = getSidTime(ephTime) 
    s0 =  gst * π / 12.0
    numSeconds = secondofday(ephTime)

    s =  s0 + we * numSeconds
    cs =  cos(s)
    ss =  sin(s)

    # Initial state matrix
    initialState = zeros(6)
    accel = zeros(3)
    # dxt1  = zeros(6)
    # dxt2  = zeros(6)
    # dxt3  = zeros(6)
    # dxt4  = zeros(6)
    tempRes = zeros(6)

    # Get the reference state out of GloEphemeris object data. Values
    # must be rotated from PZ-90 to an absolute coordinate system
    # Initial x coordinate (m)
    initialState[1]  = (px * cs - py * ss);
    # Initial y coordinate
    initialState[3]  = (px * ss + py * cs);
    # Initial z coordinate
    initialState[5]  = pz;

    # Initial x velocity   (m/s)
    initialState[2]  = (vx * cs - vy * ss - we * initialState[3] );
    # Initial y velocity
    initialState[4]  = (vx * ss + vy * cs + we * initialState[1] );
    # Initial z velocity
    initialState[6]  = vz;


    # Integrate satellite state to desired epoch using the given step
    rkStep = step

    if epoch < ephTime
        rkStep = step * (-1.0)
    end

    rkStepNs = Nanosecond(rkStep * 1e9)
    workEpoch = TimeDate(ephTime)
    tolerance = Nanosecond(1) # 1e-9
    
    while true
    # If we are about to overstep, change the stepsize appropriately
    # to hit our target final time.
        if rkStep > 0.0 
            if (workEpoch + rkStepNs) > epoch 
                rkStepNs = epoch - workEpoch
                rkStep = rkStepNs.value / 1e9
            end
        else
            if (workEpoch + rkStepNs) < epoch 
                rkStepNs = (epoch - workEpoch)
                rkStep = rkStepNs.value / 1e9
            end
        end

        numSeconds += rkStep;
        s = s0 + we * ( numSeconds );
        cs = cos(s);
        ss = sin(s);

        # Accelerations are computed once per iteration
        accel[1] = ax * cs - ay * ss
        accel[2] = ax * ss + ay * cs
        accel[3] = az
        dxt1 = derivative(initialState, accel)
        for j = 1:6
            tempRes[j] = initialState[j] + rkStep * dxt1[j] / 2.0
        end
        dxt2 = derivative(tempRes, accel)
        for j = 1:6
            tempRes[j] = initialState[j] + rkStep * dxt2[j] / 2.0
        end
        dxt3 = derivative(tempRes, accel)
        for j = 1:6
            tempRes[j] = initialState[j] + rkStep * dxt3[j];
        end
        dxt4 = derivative(tempRes, accel)
        for j = 1:6
            initialState[j] = initialState[j] + rkStep * 
                            ( dxt1[j] +
                                2.0 * ( dxt2[j] + dxt3[j] ) +
                                dxt4[j] ) / 6.0;
        end
        # @bp
        # If we are within tolerance of the target time, we are done.
        workEpoch += rkStepNs
        if ( abs(epoch - workEpoch) < tolerance )
            break
        end
    end
    # End of 'while (!done)...'
    px = initialState[1]
    py = initialState[3]
    pz = initialState[5]
    vx = initialState[2]
    vy = initialState[4]
    vz = initialState[6]
    # @bp

    oxx = 1000.0 * ( px * cs + py * ss );         # X coordinate
    oxy = 1000.0 * (-px * ss + py * cs);          # Y coordinate
    oxz = 1000.0 * pz;                        # Z coordinate

    ovx = 1000.0 * ( vx * cs + vy * ss + we * (oxy / 1000.0) ) # X velocity
    ovy = 1000.0 * (-vx * ss + vy * cs - we * (oxx / 1000.0) ) # Y velocity
    ovz = 1000.0 * vz;                        # Z velocity

    # In the GLONASS system, 'clkbias' already includes the relativistic
    # correction, therefore we must substract the late from the former.
    ox = ECEF(oxx, oxy, oxz)

    relcorr = computeRelativityCorrection(oxx, oxy, oxz, ovx, ovy, ovz)
    clkbias = clkbias + clkdrift * elapte - relcorr
    clkdrift = clkdrift;
    frame = fmPZ90;

    # We are done, let's return
    return Xvt(ECEF(oxx, oxy, oxz), (ovx, ovy, ovz),
                    relcorr,clkbias,clkdrift,frame,
                    health == 1.0 ? hsHealthy : hsUnhealthy)

end



function calculate_Fit_pos(ees::EphEpochStore, dt::DateTime,
                            vaild_d::Minute=Minute(15),)
    k = ees.keys
    if length(k) == 0
        return ECEF{Float64}(NaN, NaN, NaN)
    end
    d = k .- dt
    i = argmin(abs.(d))
                        
    md = d[i]
    if md > vaild_d || md < -vaild_d
        return ECEF{Float64}(NaN, NaN, NaN)
    end

    mk = k[i]
    me = ees.eph[mk].d
    
    xvt = calculate_Fit_pos(dt, mk,
                        me[1], me[2],

                        me[4], me[8],  me[12],
                        me[5], me[9],  me[13],
                        me[6], me[10], me[14], 

                        me[7],)
    return xvt.x
end