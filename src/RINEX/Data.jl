
function parse_Int_or_Empty(a::AbstractString)
    b = strip(a)
    if isempty(b)
        return 0
    else
        return parse(Int64, b)
    end
end

