# https://github.com/SGL-UT/GPSTk/tree/master/core/lib/GNSSCore/ObsID.hpp
# https://github.com/SGL-UT/GPSTk/tree/master/core/lib/GNSSCore/ObsIDInitializer.cpp

@enum ObservationType begin
    otUnknown
    otAny       # < Used to match any observation type
    otRange     # < pseudorange, in meters
    otPhase     # < accumulated phase, in cycles
    otDoppler   # < Doppler, in Hz
    otSNR       # < Signal strength, in dB-Hz
    otChannel   # < Channel number
    otDemodStat # < Demodulator status
    otIono      # < Ionospheric delay (see RINEX3 section 5.12)
    otSSI       # < Signal Strength Indicator (RINEX)
    otLLI       # < Loss of Lock Indicator (RINEX)
    otTrackLen  # < Number of continuous epochs of 'good' tracking
    otNavMsg    # < Navigation Message data
    otRngStdDev # < pseudorange standard deviation, in meters
    otPhsStdDev # < phase standard deviation, in cycles
    otFreqIndx  # < GLONASS frequency offset index [-6..7]
    otUndefined # < Undefined
    otLast      # < Used to verify that all items are described at compile time
end

# The frequency band this obs was collected from.
@enum CarrierBand begin
    cbUnknown
    cbAny  # < Used to match any carrier band
    cbZero # < Used with the channel observation type (see RINEx3 section 5.13)
    cbL1   # < GPS L1, Galileo E2-L1-E1, SBAS L1, QZSS L1
    cbL2   # < GPS L2, QZSS L2
    cbL5   # < GPS L5, Galileo E5a, SBAS L5, QZSS L5, INRSS L5
    cbG1   # < Glonass G1
    cbG2   # < Glonass G2
    cbG3   # < Glonass G3
    cbE5b  # < Galileo E5b, BeiDou L7
    cbE5ab # < Galileo E5a+b
    cbE6   # < Galileo E6, QZSS LEX
    cbB1   # < BeiDou L1
    cbB2   # < BeiDou L7
    cbB3   # < BeiDou L6
    cbI9   # < IRNSS S-band (RINEX '9')
    cbL1L2 # < Combined L1L2 (like an ionosphere free obs)
    cbUndefined 
    cbLast # < Used to verify that all items are described at compile time
end


#= /** The code used to collect the observation. Each of these
    * should uniquely identify a code that was correlated
    * against to track the signal. While the notation generally
    * follows section 5.1 of RINEX 3, due to ambiguities in that
    * specification some extensions are made. Note that as
    * concrete specifications for the codes are released, this
    * list may need to be adjusted. Specifically, this lists
    * assumes that the same I & Q codes will be used on all
    * three of the Galileo carriers. If that is not true, more
    * identifiers need to be allocated */ =#
@enum TrackingCode begin
    tcUnknown
    tcAny     # < Used to match any tracking code
    tcCA      # < Legacy GPS civil code
    tcP       # < Legacy GPS precise code
    tcY       # < Encrypted legacy GPS precise code
    tcW       # < Encrypted legacy GPS precise code, codeless Z tracking
    tcN       # < Encrypted legacy GPS precise code, squaring codeless tracking
    tcD       # < Encrypted legacy GPS precise code, other codeless tracking
    tcM       # < Modernized GPS military unique code
    tcC2M     # < Modernized GPS L2 civil M code
    tcC2L     # < Modernized GPS L2 civil L code
    tcC2LM    # < Modernized GPS L2 civil M+L combined tracking (such as Trimble NetRS, Septrentrio, and ITT)
    tcI5      # < Modernized GPS L5 civil in-phase
    tcQ5      # < Modernized GPS L5 civil quadrature
    tcIQ5     # < Modernized GPS L5 civil I+Q combined tracking
    tcG1P     # < Modernized GPS L1C civil code tracking (pilot)
    tcG1D     # < Modernized GPS L1C civil code tracking (data)
    tcG1X     # < Modernized GPS L1C civil code tracking (pilot + data)

    tcGCA     # < Legacy Glonass civil signal
    tcGP      # < Legacy Glonass precise signal
    tcIR3     # < Glonass L3 I code
    tcQR3     # < Glonass L3 Q code
    tcIQR3    # < Glonass L3 I+Q combined tracking

    tcA       # < Galileo L1 PRS code
    tcB       # < Galileo OS/CS/SoL code
    tcC       # < Galileo Dataless code
    tcBC      # < Galileo B+C combined tracking
    tcABC     # < Galileo A+B+C combined tracking
    tcIE5     # < Galileo E5 I code
    tcQE5     # < Galileo E5 Q code
    tcIQE5    # < Galileo E5 I+Q combined tracking
    tcIE5a    # < Galileo E5a I code
    tcQE5a    # < Galileo E5a Q code
    tcIQE5a   # < Galileo E5a I+Q combined tracking
    tcIE5b    # < Galileo E5b I code
    tcQE5b    # < Galileo E5b Q code
    tcIQE5b   # < Galileo E5b I+Q combined tracking

    tcSCA     # < SBAS civil code
    tcSI5     # < SBAS L5 I code
    tcSQ5     # < SBAS L5 Q code
    tcSIQ5    # < SBAS L5 I+Q code

    tcJCA     # < QZSS civil code
    tcJD1     # < QZSS L1C(D)
    tcJP1     # < QZSS L1C(P)
    tcJX1     # < QZSS L1C(D+P)
    tcJZ1     # < QZSS L1-SAIF
    tcJM2     # < QZSS L2C(M)
    tcJL2     # < QZSS L2C(L)
    tcJX2     # < QZSS L2C(M+L)
    tcJI5     # < QZSS L5 in-phase
    tcJQ5     # < QZSS L5 quadrature
    tcJIQ5    # < QZSS L5 I+Q combined tracking
    tcJI6     # < QZSS LEX(6) in-phase
    tcJQ6     # < QZSS LEX(6) quadrature
    tcJIQ6    # < QZSS LEX(6) I+Q combined tracking

    tcCI1     # < BeiDou B1 I code
    tcCQ1     # < BeiDou B1 Q code
    tcCIQ1    # < BeiDou B1 I code
    tcCI7     # < BeiDou B2 I+Q code
    tcCQ7     # < BeiDou B2 Q code
    tcCIQ7    # < BeiDou B2 I+Q code
    tcCI6     # < BeiDou B3 I code
    tcCQ6     # < BeiDou B3 Q code
    tcCIQ6    # < BeiDou B3 I+Q code

        #  Nomenclature follows RiNEX 3.03 Table 10
    tcIA5     # < IRNSS L5 SPS
    tcIB5     # < IRNSS L5 RS(D)
    tcIC5     # < IRNSS L5 RS(P)
    tcIX5     # < IRNSS L5 B+C
    tcIA9     # < IRNSS S-band SPS
    tcIB9     # < IRNSS S=band RS(D)
    tcIC9     # < INRSS S-band RS(P)
    tcIX9     # < IRNSS S-band B+C

    tcUndefined
    tcLast    # < Used to verify that all items are described at compile time
end





# The following definitions really should only describe the items that are
# in the Rinex 3 specification. If an application needs additional ObsID
# types to be able to be translated to/from Rinex3, the additional types
# must be added by the application.

# ObsID::char2[a-z]{2}\[('.')\] = ObsID::(.+);
const char2ot = Dict{Char,ObservationType}(
        ' ' => otUnknown,
        '*' => otAny,
        'C' => otRange,
        'L' => otPhase,
        'D' => otDoppler,
        'S' => otSNR,
        '-' => otUndefined,
)
        
const char2cb = Dict{Char,CarrierBand}(
        ' ' => cbUnknown,
        '*' => cbAny,
        '1' => cbL1,
        '2' => cbL2,
        '3' => cbG3,
        '5' => cbL5,
        '6' => cbE6,
        '7' => cbE5b,
        '8' => cbE5ab,
        '9' => cbI9,
        '-' => cbUndefined, 
)


const char2tc = Dict{Char,TrackingCode}(
        ' ' => tcUnknown,
        '*' => tcAny,
        'C' => tcCA,
        'P' => tcP,  
        'W' => tcW,
        'Y' => tcY,
        'M' => tcM,
        'N' => tcN,
        'D' => tcD,
        'S' => tcC2M,
        'L' => tcC2L,
        'X' => tcC2LM,
        'I' => tcI5,
        'Q' => tcQ5,
        'A' => tcA,
        'B' => tcB,
        'Z' => tcABC,
        '-' => tcUndefined, 
)









# ObsID::otDesc\[ObsID::(ot[A-Za-z]+)\]( +)= +("[A-Za-z]+");( +)//(.+)
# $1$2=>$3,$4#$5
const otDesc = Dict{ObservationType,String}(
    otUnknown => "UnknownType",   # Rinex (sp)
    otAny       => "AnyType",       # Rinex *
    otRange     => "pseudorange",   # Rinex C
    otPhase     => "phase",         # Rinex L
    otDoppler   => "doppler",       # Rinex D
    otSNR       => "snr",           # Rinex S
    otChannel   => "channel",       # Rinex  
    otDemodStat => "demodStatus",   # test
    otIono      => "iono",          # Rinex  
    otSSI       => "ssi",           # Rinex  
    otLLI       => "lli",           # Rinex  
    otTrackLen  => "tlen",          # Rinex  
    otNavMsg    => "navmsg",        # Rinex
    otRngStdDev => "rngSigma",      # test
    otPhsStdDev => "phsSigma",      # test
    otFreqIndx  => "freqIndx",      # test
    otUndefined => "undefined",     # Rinex -
)
# ObsID::cbDesc\[ObsID::(cb[A-Za-z0-9]+)\]( +)= +("[A-Za-z0-9\+]+");( +)//(.+)
# $1$2=>$3,$4#$5
const cbDesc = Dict{CarrierBand,String}(
    cbUnknown   => "UnknownBand",   # Rinex (sp)
    cbAny       => "AnyBand",       # Rinex *
    cbZero      => "0",              # Rinex  
    cbL1        => "L1",            # Rinex 1
    cbL2        => "L2",            # Rinex 2
    cbL5        => "L5",            # Rinex 5
    cbG1        => "G1",            # Rinex 1
    cbG2        => "G2",            # Rinex 2
    cbG3        => "G3",            # Rinex 3
    cbE5b       => "E5b",           # Rinex 7
    cbE5ab      => "E5a+b",         # Rinex 8
    cbE6        => "E6",            # Rinex 6
    cbB1        => "B1",            # Rinex 1  2 in RINEX 3.0[013]
    cbB2        => "B2",            # Rinex 7
    cbB3        => "B3",            # Rinex 6
    cbI9        => "I9",            # Rinex 9
    cbL1L2      => "comboL1L2",     # Rinex 3
    cbUndefined => "undefined",     # Rinex -
)
# ObsID::tcDesc\[ObsID::(tc[A-Za-z0-9]+)\]( +)= +(".+?");( +)//(.+)
# $1$2=>$3,$4#$5
const tcDesc = Dict{TrackingCode,String}(
    tcUnknown   => "UnknownCode",   # Rinex (sp)
    tcAny       => "AnyCode",       # Rinex *
    tcCA        => "GPSC/A",        # Rinex C    // GPScivil
    tcP         => "GPSP",          # Rinex P    // GPSprecise
    tcY         => "GPSY",          # Rinex Y    // GPSprecise_encrypted
    tcW         => "GPScodelessZ",  # Rinex W    // GPSprecise_encrypted_codeless_Z
    tcN         => "GPSsquare",     # Rinex N    // GPSprecise_encrypted_codeless_squaring
    tcD         => "GPScodeless",   # Rinex D    // GPSprecise_encrypted_codeless_other
    tcM         => "GPSM",          # Rinex M    // GPSmilitary
    tcC2M       => "GPSC2M",        # Rinex S    // GPScivil_M
    tcC2L       => "GPSC2L",        # Rinex L    // GPScivil_L
    tcC2LM      => "GPSC2L+M",      # Rinex X    // GPScivil_L+M
    tcI5        => "GPSI5",         # Rinex I    // GPScivil_I
    tcQ5        => "GPSQ5",         # Rinex Q    // GPScivil_Q
    tcIQ5       => "GPSI+Q5",       # Rinex X    // GPScivil_I+Q
    tcG1P       => "GPSC1P",        # Rinex L    // GPScivil_L1P
    tcG1D       => "GPSC1D",        # Rinex S    // GPScivil_L1D
    tcG1X       => "GPSC1(D+P)",    # Rinex X    // GPScivil_L1D+P

    tcGCA       => "GLOC/A",        # Rinex C    // GLOcivil
    tcGP        => "GLOP",          # Rinex P    // GLOprecise
    tcIR3       => "GLOIR5",        # Rinex I    // GLO L3 I code
    tcQR3       => "GLOQR5",        # Rinex Q    // GLO L3 Q code
    tcIQR3      => "GLOI+QR5",      # Rinex X    // GLO L3 I+Q code

    tcA         => "GALA",          # Rinex A    // GAL
    tcB         => "GALB",          # Rinex B    // GAL
    tcC         => "GALC",          # Rinex C    // GAL
    tcBC        => "GALB+C",        # Rinex X    // GAL
    tcABC       => "GALA+B+C",      # Rinex Z    // GAL
    tcIE5       => "GALI5",         # Rinex I    // GAL
    tcQE5       => "GALQ5",         # Rinex Q    // GAL
    tcIQE5      => "GALI+Q5",       # Rinex X    // GAL
    tcIE5a      => "GALI5a",        # Rinex I    // GAL
    tcQE5a      => "GALQ5a",        # Rinex Q    // GAL
    tcIQE5a     => "GALI+Q5a",      # Rinex X    // GAL
    tcIE5b      => "GALI5b",        # Rinex I    // GAL
    tcQE5b      => "GALQ5b",        # Rinex Q    // GAL
    tcIQE5b     => "GALI+Q5b",      # Rinex X    // GAL

    tcSCA       => "SBASC/A",       # Rinex C    // SBAS civil code
    tcSI5       => "SBASI5",        # Rinex I    // SBAS L5 I code
    tcSQ5       => "SBASQ5",        # Rinex Q    // SBAS L5 Q code
    tcSIQ5      => "SBASI+Q5",      # Rinex X    // SBAS L5 I+Q code

    tcJCA       => "QZSSC/A",       # Rinex C    // QZSS L1 civil code
    tcJD1       => "QZSSL1C(D)",    # Rinex S    // QZSS L1C(D)
    tcJP1       => "QZSSL1C(P)",    # Rinex L    // QZSS L1C(P)
    tcJX1       => "QZSSL1C(D+P)",  # Rinex X    // QZSS L1C(D+P)
    tcJZ1       => "QZSSL1-SAIF",   # Rinex Z    // QZSS L1-SAIF
    tcJM2       => "QZSSL2C(M)",    # Rinex S    // QZSS L2 M code
    tcJL2       => "QZSSL2C(L)",    # Rinex L    // QZSS L2 L code
    tcJX2       => "QZSSL2C(M+L)",  # Rinex X    // QZSS L2 M+L code
    tcJI5       => "QZSSL5I",       # Rinex I    // QZSS L5 I code
    tcJQ5       => "QZSSL5Q",       # Rinex Q    // QZSS L5 Q code
    tcJIQ5      => "QZSSL5I+Q",     # Rinex X    // QZSS L5 I+Q code
    tcJI6       => "QZSSL6I",       # Rinex S    // QZSS LEX(6) I code
    tcJQ6       => "QZSSL6Q",       # Rinex L    // QZSS LEX(6) Q code
    tcJIQ6      => "QZSSL6I+Q",     # Rinex X    // QZSS LEX(6) I+Q code

    tcCI1       => "BDSIB1",        # Rinex I    // BeiDou L1 I code
    tcCQ1       => "BDSQB1",        # Rinex Q    // BeiDou L1 Q code
    tcCIQ1      => "BDSI+QB1",      # Rinex X    // BeiDou L1 I+Q code
    tcCI7       => "BDSIB2",        # Rinex I    // BeiDou B2 I code
    tcCQ7       => "BDSQB2",        # Rinex Q    // BeiDou B2 Q code
    tcCIQ7      => "BDSI+QB2",      # Rinex X    // BeiDou B2 I+Q code
    tcCI6       => "BDSIB3",        # Rinex I    // BeiDou B3 I code
    tcCQ6       => "BDSQB3",        # Rinex Q    // BeiDou B3 Q code
    tcCIQ6      => "BDSI+QB3",      # Rinex X    // BeiDou B3 I+Q code

    tcIA5       => "IRNSSL5A",      # Rinex A    // IRNSS L5 SPS
    tcIB5       => "IRNSSL5B",      # Rinex B    // IRNSS L5 RS(D)
    tcIC5       => "IRNSSL5C",      # Rinex C    // IRNSS L5 RS(P)
    tcIX5       => "IRNSSL5B+C",    # Rinex X    // IRNSS L5 B+C
    tcIA9       => "IRNSSL9A",      # Rinex A    // IRNSS S-band SPS
    tcIB9       => "IRNSSL9B",      # Rinex B    // IRNSS S-band RS(D)
    tcIC9       => "IRNSSL9C",      # Rinex C    // IRNSS S-band RS(P)
    tcIX9       => "IRNSSL9B+C",    # Rinex X    // IRNSS S-band B+C
    tcUndefined => "undefined",     # test
)




export ObsID
struct ObsID
    str::String
    ot::ObservationType
    cb::CarrierBand
    tc::TrackingCode
    ss::SatelliteSystemType
    function ObsID(str::Union{String,SubString}, sys::SatelliteSystemType=sstUnknown)
        length(str) == 3  || throw(error("ObsID |$str| error"))
        cot, ccb, ctc = str
        haskey(char2cb, ccb) || throw(error("no such CarrierBand: $ccb"))
        haskey(char2ot, cot) || throw(error("no such ObservationType: $cot"))
        haskey(char2tc, ctc) || throw(error("no such TrackingCode: $ctc"))
        type = char2ot[cot]
        band = char2cb[ccb]
        code = char2tc[ctc]
        # / This next block takes care of fixing up the codes that are reused
        # / between the various signals
        if sys == sstGPS
            if band == cbL5
                if code == tcC2LM code = tcIQ5 end
            elseif band == cbL1
                if (code == tcC2LM)     code = tcG1X
                elseif (code == tcC2M)  code = tcG1D
                elseif (code == tcC2L)  code = tcG1P
                end
            end
        elseif sys == sstGalileo
            if band == cbL1 || band == cbE6
                if code == tcCA       code = tcC
                elseif code == tcC2LM code = tcBC
                end
            elseif band == cbL5
                if code == tcI5       code = tcIE5a
                elseif code == tcQ5   code = tcQE5a
                elseif code == tcC2LM code = tcIQE5a
                end
            elseif band == cbE5b
                if code == tcI5       code = tcIE5b
                elseif code == tcQ5   code = tcQE5b
                elseif code == tcC2LM code = tcIQE5b
                end
            elseif band == cbE5ab
                if code == tcI5       code = tcIE5
                elseif code == tcQ5   code = tcQE5
                elseif code == tcC2LM code = tcIQE5
                end
            end
        elseif sys == sstGlonass
            if code == tcCA      code = tcGCA
            elseif code == tcP   code = tcGP
            elseif code == tcI5  code = tcIR3
            elseif code == tcQ5  code = tcQR3
            elseif code == tcC2LM || code == tcG1X
                code = tcIQR3
            end
            if band == cbL1 band = cbG1
            elseif band == cbL2 band = cbG2
            end
            
        elseif sys == sstGeosync
            if code == tcCA     code = tcSCA     # 'C'
            elseif code == tcI5 code = tcSI5     # 'I'
            elseif code == tcQ5 code = tcSQ5     # 'Q'
            elseif code == tcC2LM || code == tcG1X
                code = tcSIQ5  # 'X'
            end
        elseif sys == sstQZSS
            if band == cbL1
                if code == tcCA
                    code = tcJCA    # 'C'
                elseif code == tcC2M  || code == tcG1D
                    code = tcJD1    # 'S'
                elseif code == tcC2L  || code == tcG1P
                    code = tcJP1    # 'L'
                elseif code == tcC2LM || code == tcG1X
                    code = tcJX1    # 'X'
                elseif code == tcABC
                    code = tcJZ1    # 'Z'
                end
            elseif band == cbL2
                if code == tcC2M      || code == tcG1D
                    code = tcJM2  # 'S'
                elseif code == tcC2L  || code == tcG1P
                    code = tcJL2  # 'L'
                elseif code == tcC2LM || code == tcG1X
                    code = tcJX2  # 'X'
                end
            elseif band == cbL5
                if code == tcI5       code = tcJI5    # 'I'
                elseif code == tcQ5   code = tcJQ5    # 'Q'
                elseif code == tcC2LM code = tcJIQ5   # 'X'
                end
            elseif band == cbE6
                if code == tcC2M  || code == tcG1D
                    code = tcJI6     # 'S'
                elseif code == tcC2L  || code == tcG1P
                    code = tcJQ6     # 'L'
                elseif code == tcC2LM || code == tcG1X
                    code = tcJIQ6    # 'X'
                end
            end
        elseif sys == sstBeiDou
            if band == cbL1     band = cbB1         # RINEX 3.02
            elseif band == cbL2 band = cbB1         # RINEX 3.0[013]
            elseif band == cbE6 band = cbB3 
            elseif band == cbB1
                if code == tcI5     code = tcCI1    # 'I'
                elseif code == tcQ5 code = tcCQ1    # 'Q'
                elseif code == tcC2LM || code == tcG1X
                    code = tcCIQ1                   # 'X'
                end
            elseif band == cbB3
                if code == tcI5      code = tcCI7    # 'I'
                elseif code == tcQ5  code = tcCQ7    # 'Q'
                elseif code == tcC2LM || code == tcG1X
                    code = tcCIQ7                    # 'X'
                end
            elseif band == cbE5b
                if code == tcI5     code = tcCI6     # 'I'
                elseif code == tcQ5 code = tcCQ6     # 'Q'
                elseif code == tcC2LM || code == tcG1X
                    code = tcCIQ6                    # 'X'
                end
            end
        elseif sys == sstIRNSS # IRNSS
            if band == cbL5
                if code == tcCA     code = tcIA5   # 'A'
                elseif code == tcA  code = tcIB5   # 'B'
                elseif code == tcB  code = tcIC5   # 'B'
                elseif code == tcC2LM || code == tcG1X
                    code = tcIX5                   # 'X'
                end
            end
        end
        new(str,  type, band, code, sys)
    end
end

