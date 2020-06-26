
function svRelativity(dt::DateTime)
    return 0.0
end

function svClockBias(dt::DateTime)
    return 0.0
end

function svClockDrift(dt::DateTime)
    return 0.0
end


function calculate_Orbit_pos_BDGEO( dt::DateTime, 
    ctToe::DateTime,
    af0::Float64, af1::Float64, af2::Float64,
    Ahalf::Float64, ecc::Float64, idot::Float64, dn::Float64,
    M0::Float64, ω::Float64, i0::Float64,
    Ω0::Float64, Ωdot::Float64,
    Cuc::Float64,  Cus::Float64,
    Crc::Float64,  Crs::Float64,
    Cic::Float64,  Cis::Float64,
    health::Float64=-1.0,
    Adot::Float64=0.0,
    dndot::Float64=0.0,
    gm::Float64=WGS84Ellipsoid.gm,
    angVelocity::Float64=WGS84Ellipsoid.angVelocity,
    )

    sqrtgm = sqrt(gm)
    twoPI = 2.0 * PI
    # lecc;            # eccentricity
    # tdrinc;          # dt inclination
    A = Ahalf^2
    # Ahalf = sqrt(A)  # A is semi-major axis of orbit
    
    _, ToeSOW = datetime2gpsws(ctToe)    # SOW is time-system-independent
    
    lecc = ecc
    tdrinc = idot
    
    # Compute time since ephemeris & clock epochs
    elapte = (dt - ctToe).value / 1000.0 # TODO  second?
    # Compute A at time of interest (LNAV: Adot==0)
    Ak = A + Adot * elapte
    
    # Compute mean motion (LNAV: dndot==0)
    dnA = dn + 0.5 * dndot * elapte
    amm  = (sqrtgm / (A * Ahalf)) + dnA     # Eqn specifies A0, not Ak
    
    # In-plane angles
    #     meana - Mean anomaly
    #     ea    - Eccentric anomaly
    #     truea - True anomaly
    meana = M0 + elapte * amm
    meana = meana % twoPI
    ea = meana + lecc * sin(meana)
    
    
    for loop_cnt in 1:20
        F = meana - (ea - lecc * sin(ea))
        G = 1.0 - lecc * cos(ea)
        delea = F / G
        ea = ea + delea
        abs(delea) < 1.0e-11 && break
    end
    
    # Compute clock corrections
    relcorr = svRelativity(dt)
    clkbias = svClockBias(dt)
    clkdrift = svClockDrift(dt)
    frame = fmWGS84;
    
    # Compute true anomaly
    q     = sqrt(1.0e0 - lecc * lecc)
    sinea = sin(ea)
    cosea = cos(ea)
    G     = 1.0e0 - lecc * cosea
    
    #  G*SIN(TA) AND G*COS(TA)
    GSTA  = q * sinea
    GCTA  = cosea - lecc
    
    #  True anomaly
    truea = atan(GSTA, GCTA)
    
    # Argument of lat and correction terms (2nd harmonic)
    alat  = truea + ω
    talat = 2.0e0 * alat
    c2al  = cos(talat)
    s2al  = sin(talat)
    
    du  = c2al * Cuc +  s2al * Cus
    dr  = c2al * Crc +  s2al * Crs
    di  = c2al * Cic +  s2al * Cis
    
    # U = updated argument of lat, R = radius, AINC = inclination
    U    = alat + du
    R    = Ak * G  + dr
    AINC = i0 + tdrinc * elapte  +  di
    
    #  Longitude of ascending node (ANLON)
    # ANLON = Ω0 + (Ωdot - WGS84Ellipsoid.angVelocity) *
    #         elapte - WGS84Ellipsoid.angVelocity * ToeSOW
    ANLON = Ω0 + Ωdot * elapte - 
            angVelocity * ToeSOW
    # In plane location
    cosu = cos(U)
    sinu = sin(U)
    xip  = R * cosu
    yip  = R * sinu
    
    #  Angles for rotation to earth fixed
    can  = cos(ANLON)
    san  = sin(ANLON)
    cinc = cos(AINC)
    sinc = sin(AINC)
    
    # Earth fixed coordinates in meters
    # xef  =  xip * can  -  yip * cinc * san
    # yef  =  xip * san  +  yip * cinc * can
    # zef  =              yip * sinc
    # GEO satellite coordinates in user-defined inertial system
    xGK  =  xip * can  -  yip * cinc * san
    yGK  =  xip * san  +  yip * cinc * can
    zGK  =              yip * sinc

    # Rz matrix
    angleZ = angVelocity * elapte
    cosZ   = cos(angleZ)
    sinZ   = sin(angleZ)

    matZ = [ cosZ sinZ 0.0;
            -sinZ cosZ 0.0;
            0.0    0.0 1.0;]
    
    angleX = deg2rad(-5.0)
    cosX   = cos(angleX)
    sinX   = sin(angleX)
    matX = [1.0   0.0  0.0;
            0.0  cosX sinX;
            0.0 -sinX cosX;]

    inertialPos = [xGK; yGK; zGK]
    # @warn "matrix multiply check!"
    # @show matZ
    # @show matX
    # @show inertialPos
    
    result = matZ * matX * inertialPos

    x = ECEF(result[1], result[2], result[3])
    # sv.x[0] = xef
    # sv.x[1] = yef
    # sv.x[2] = zef
    # derivatives of true anamoly and arg of latitude
    dek = amm / G; 
    dlk =  Ahalf * q * sqrtgm / (R * R);

    # in-plane, cross-plane, and radial derivatives
    div = tdrinc - 2.0e0 * dlk * (Cis  * c2al - Cic * s2al)
    duv = dlk * (1.e0 + 2.e0 * (Cus * c2al - Cuc * s2al))
    drv = A * lecc * dek * sinea + 2.e0 * dlk * (Crs * c2al - Crc * s2al)


    #
    dxp = drv * cosu - R * sinu * duv
    dyp = drv * sinu + R * cosu * duv
    
    # time-derivative of Rz matrix
    dmatZ = [sinZ * -angVelocity -cosZ * -angVelocity 0.0;
             cosZ * angVelocity   sinZ * -angVelocity 0.0;
                            0.0                   0.0 0.0;]

    dIntPos = [- xip * san * Ωdot +
                    dxp * can -
                    yip * (cinc * can * Ωdot -
                            sinc * san * div ) -
                    dyp * cinc * san,
                xip * can * Ωdot +
                    dxp * san -
                    yip * (cinc * san * Ωdot +
                            sinc * can * div ) +
                    dyp * cinc * can,
                yip * cinc * div + dyp * sinc
            ]
    # @warn "matrix multiply check!"
    # @show matZ
    # @show matX
    # @show inertialPos
    
    vresult = matZ * matX * dIntPos +
                dmatZ * matX * inertialPos
                
    v = (vresult[1], vresult[2], vresult[3],)
    # @bp
    # sv.v[0] = vxef;
    # sv.v[1] = vyef;
    # sv.v[2] = vzef;
    
    # return sv;

    Xvt(x, v, relcorr, clkbias, clkdrift, frame,
            health == 1.0 ? hsHealthy : hsUnhealthy)
end




function calculate_Orbit_pos( dt::DateTime, 
    ctToe::DateTime,
    af0::Float64, af1::Float64, af2::Float64,
    Ahalf::Float64, ecc::Float64, idot::Float64, dn::Float64,
    M0::Float64, ω::Float64, i0::Float64,
    Ω0::Float64, Ωdot::Float64,
    Cuc::Float64,  Cus::Float64,
    Crc::Float64,  Crs::Float64,
    Cic::Float64,  Cis::Float64,
    health::Float64=-1.0,
    Adot::Float64=0.0,
    dndot::Float64=0.0,
    GPSEllipsoid::GNSSEllipsoid=GPSEllipsoid,
    )

    sqrtgm = sqrt(GPSEllipsoid.gm)
    twoPI = 2.0 * PI
    # lecc;            # eccentricity
    # tdrinc;          # dt inclination
    A = Ahalf^2
    # Ahalf = sqrt(A)  # A is semi-major axis of orbit
    
    # TODO
    _, ToeSOW = datetime2gpsws(ctToe)    # SOW is time-system-independent
    
    lecc = ecc
    tdrinc = idot
    
    # Compute time since ephemeris & clock epochs
    elapte = (dt - ctToe).value / 1000.0 # TODO  second?
    # Compute A at time of interest (LNAV: Adot==0)
    Ak = A + Adot * elapte
    
    # Compute mean motion (LNAV: dndot==0)
    dnA = dn + 0.5 * dndot * elapte
    amm  = (sqrtgm / (A * Ahalf)) + dnA     # Eqn specifies A0, not Ak
    
    # In-plane angles
    #     meana - Mean anomaly
    #     ea    - Eccentric anomaly
    #     truea - True anomaly
    meana = M0 + elapte * amm
    meana = meana % twoPI # TODO fmod
    ea = meana + lecc * sin(meana)
    
    
    for loop_cnt in 1:20
        F = meana - (ea - lecc * sin(ea))
        G = 1.0 - lecc * cos(ea)
        delea = F / G
        ea = ea + delea
        abs(delea) < 1.0e-11 && break
    end
    
    # Compute clock corrections
    relcorr = svRelativity(dt)
    clkbias = svClockBias(dt)
    clkdrift = svClockDrift(dt)
    frame = fmWGS84;
    
    # Compute true anomaly
    q     = sqrt(1.0e0 - lecc * lecc)
    sinea = sin(ea)
    cosea = cos(ea)
    G     = 1.0e0 - lecc * cosea
    
    #  G*SIN(TA) AND G*COS(TA)
    GSTA  = q * sinea
    GCTA  = cosea - lecc
    
    #  True anomaly
    truea = atan(GSTA, GCTA)
    
    # Argument of lat and correction terms (2nd harmonic)
    alat  = truea + ω
    talat = 2.0e0 * alat
    c2al  = cos(talat)
    s2al  = sin(talat)
    
    du  = c2al * Cuc +  s2al * Cus
    dr  = c2al * Crc +  s2al * Crs
    di  = c2al * Cic +  s2al * Cis
    
    # U = updated argument of lat, R = radius, AINC = inclination
    U    = alat + du
    R    = Ak * G  + dr
    AINC = i0 + tdrinc * elapte  +  di
    
    #  Longitude of ascending node (ANLON)
    ANLON = Ω0 + (Ωdot - GPSEllipsoid.angVelocity) *
            elapte - GPSEllipsoid.angVelocity * ToeSOW
    
    # In plane location
    cosu = cos(U)
    sinu = sin(U)
    xip  = R * cosu
    yip  = R * sinu
    
    #  Angles for rotation to earth fixed
    can  = cos(ANLON)
    san  = sin(ANLON)
    cinc = cos(AINC)
    sinc = sin(AINC)
    
    # Earth fixed coordinates in meters
    xef  =  xip * can  -  yip * cinc * san
    yef  =  xip * san  +  yip * cinc * can
    zef  =              yip * sinc

    x = ECEF(xef, yef, zef)
    # sv.x[0] = xef
    # sv.x[1] = yef
    # sv.x[2] = zef
    
    # Compute velocity of rotation coordinates
    dek = amm * Ak / R
    dlk = Ahalf * q * sqrtgm / (R * R)
    div = tdrinc - 2.0e0 * dlk * (Cic  * s2al - Cis * c2al)
    domk = Ωdot - GPSEllipsoid.angVelocity
    duv = dlk * (1.e0 + 2.e0 * (Cus * c2al - Cuc * s2al))
    drv = Ak * lecc * dek * sinea - 2.e0 * dlk * (Crc * s2al - Crs * c2al)
    dxp = drv * cosu - R * sinu * duv
    dyp = drv * sinu + R * cosu * duv
    
    # Calculate velocities
    vxef = dxp * can - xip * san * domk - dyp * cinc * san +
            yip * (sinc * san * div - cinc * can * domk)
    vyef = dxp * san + xip * can * domk + dyp * cinc * can -
            yip * (sinc * can * div + cinc * san * domk)
    vzef = dyp * sinc + yip * cinc * div
    
    # Move results into output variables
    v = (vxef, vyef, vzef)
    # @bp
    # sv.v[0] = vxef;
    # sv.v[1] = vyef;
    # sv.v[2] = vzef;
    
    # return sv;

    Xvt(x, v, relcorr, clkbias, clkdrift, frame,
            health == 1.0 ? hsHealthy : hsUnhealthy)
end


function calculate_Orbit_pos(ees::EphEpochStore, dt::DateTime,
    vaild_d::Hour=Hour(2), )
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
    fun = calculate_Orbit_pos
    if ees.si.ss == sstBeiDou
        prn = ees.si.id
        # http://mgex.igs.org/IGS_MGEX_Status_BDS.php
        if prn < 6 ||
            (prn == 17 && dt < DateTime(2018, 9, 29)) ||
            (prn == 18 && dt > DateTime(2019, 5, 17)) ||
            prn == 59
            fun = calculate_Orbit_pos_BDGEO
        end
    end

    xvt = fun(dt, mk,
                me[1], me[2], me[3],

                me[11], me[9], me[20], me[6], 

                me[7], me[18], me[16],
                me[14], me[19],

                me[8], me[10],
                me[17], me[5],
                me[13], me[15],

                me[25],)
    return xvt.x
end