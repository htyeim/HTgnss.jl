
export SatelliteSystemType

@enum SatelliteSystemType begin
    sstGPS
    sstGalileo
    sstGlonass
    sstGeosync
    sstLEO
    sstTransit
    sstBeiDou
    sstQZSS
    sstIRNSS
    sstMixed
    sstUserDefined
    sstUnknown
end

#  ObsID::map1to3sys\["(.)"\] = "(...)";
#  ObsID::map3to1sys\["(...)"\] = "(.)";
# $1=>$2,
const mapC2SS = Dict{Char,SatelliteSystemType}(
    'G' => sstGPS,
    'R' => sstGlonass,
    'E' => sstGalileo,
    'S' => sstGeosync,
    'C' => sstBeiDou,
    'J' => sstQZSS,
    'I' => sstIRNSS,
    'M' => sstMixed,
)

function char2SatelliteSystemType(c::Char,
    mapC2SS::Dict{Char,SatelliteSystemType}=mapC2SS,
)::SatelliteSystemType
    c = uppercase(c)
    haskey(mapC2SS, c) ||
        throw(error("no such SatelliteSystemType: $c"))
    mapC2SS[c]
end
const mapSS2C = Dict{SatelliteSystemType,Char}(
    sstGPS => 'G',
    sstGlonass => 'R',
    sstGalileo => 'E',
    sstGeosync => 'S',
    sstBeiDou => 'C',
    sstQZSS => 'J',
    sstIRNSS => 'I',
)
const mapSS2Str = Dict{SatelliteSystemType,String}(
    sstGPS => "GPS",
    sstGlonass => "GLO",
    sstGalileo => "GAL",
    sstGeosync => "GEO",
    sstBeiDou => "BDS",
    sstQZSS => "QZS",
    sstIRNSS => "IRN",
)



const validRinexFrequencies = "12356789";

# this defines the valid obs types
# NB these tc characters are ORDERED ~best to worst
# ObsID::validRinexTrackingCodes\[('.')\]\[('.')\] = (".+"); 
# $1 $2 $3
# $2 =>$3,
validRinexTrackingCodes = Dict{SatelliteSystemType,Dict{Char,String}}(
    sstGPS => Dict(
        '1' => "PYWLMIQSXCN* ",   # except no C1N
        '2' => "PYWLMIQSXCDN* ",  # except no C2N
        '5' => "IQX* ",),
    sstGlonass => Dict(
        '1' => "PC* ",
        '2' => "PC* ",
        '3' => "IQX* ",),

    sstGalileo => Dict(
        '1' => "ABCIQXZ* ",
        '5' => "IQX* ",
        '6' => "ABCIQXZ* ",
        '7' => "IQX* ",
        '8' => "IQX* ",),

    sstGeosync => Dict(
        '1' => "C* ",
        '5' => "IQX* ",),

    sstBeiDou => Dict(
        # NB 24Jun2013 MGEX data uses 2!  RINEX 3.03: 1 for 3.02, 2 for 3.0[013]
        '1' => "IQX* ",
        '2' => "IQX* ",
        '6' => "IQX* ",
        '7' => "IQX* ",),

    sstQZSS => Dict(
        '1' => "CSLXZ* ",
        '2' => "SLX* ",
        '5' => "IQX* ",
        '6' => "SLX* ",),

    sstIRNSS => Dict(
        '5' => "ABCX* ",
        '9' => "ABCX* ",),
)

export SatID
struct SatID
    str::String
    ss::SatelliteSystemType
    id::Int64
    function SatID(str::Union{String,SubString})
        length(str) == 3 || throw(error("not a valid satid: $str"))
        ss = char2SatelliteSystemType(str[1])
        if str[2] == ' '
            str = string(str[1], '0', str[3])
        end
        ids = str[2:3]
        id = parse(Int64, ids)
        new(str, ss, id)
    end
    function SatID(ss::SatelliteSystemType, id::Int64)
        str = string(mapSS2C[ss], @sprintf("%02d",id))
        new(str, ss, id)
    end
end
Base.show(io::IO, i::SatID) = print(io, i.str)