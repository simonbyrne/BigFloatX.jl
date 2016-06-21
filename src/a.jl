immutable BigFloatA <: AbstractFloat
    prec::Clong
    sign::Cint
    exp::Clong
    signif::Vector{Limb}
end

precision(x::BigFloatA) = x.prec


function new_data(prec)
    k = sizeof(Limb)*8
    p = div(prec + (k-1), k)
    Array(Limb,p)
end

function new_mpfr_data()
    prec = precision(BigFloat)
    s = new_data(prec)
    Mpfr_t(prec,0,0,unsafe_convert(Ptr{Limb}, s)), s
end

BigFloatA(m::Mpfr_t, s::Vector{Limb}) =
    BigFloatA(m.prec, m.sign, m.exp, s)

convert(::Type{Mpfr_t}, x::BigFloatA) =
    Mpfr_t(x.prec, x.sign, x.exp, unsafe_convert(Ptr{Limb},x.signif))

for (fJ, fC) in ((:si,:Clong), (:ui,:Culong), (:d,:Float64))
    @eval begin
        function convert(::Type{BigFloatA}, x::($fC))
            m, s = new_mpfr_data()
            ccall(($(string(:mpfr_set_,fJ)), :libmpfr), Int32, (Ptr{Mpfr_t}, ($fC), Int32), &m, x, ROUNDING_MODE[end])
            return BigFloatA(m, s)
        end
    end
end

# Basic arithmetic without promotion
for (fJ, fC) in ((:+,:add), (:*,:mul))
    @eval begin
        # BigFloatA
        function ($fJ)(x::BigFloatA, y::BigFloatA)
            m, s = new_mpfr_data()
            ccall(($(string(:mpfr_,fC)),:libmpfr), Int32, (Ptr{Mpfr_t}, Ptr{Mpfr_t}, Ptr{Mpfr_t}, Int32), &m, &x, &y, ROUNDING_MODE[end])
            return BigFloatA(m, s)
        end

    end
end

zero(::Type{BigFloatA}) = convert(BigFloatA,0)



function string(x::BigFloatA)
    # In general, the number of decimal places needed to read back the number exactly
    # is, excluding the most significant, ceil(log(10, 2^precision(x)))
    k = ceil(Int32, precision(x) * 0.3010299956639812)
    lng = k + Int32(8) # Add space for the sign, the most significand digit, the dot and the exponent
    buf = Array(UInt8, lng + 1)
    # format strings are guaranteed to contain no NUL, so we don't use Cstring
    lng = ccall((:mpfr_snprintf,:libmpfr), Int32, (Ptr{UInt8}, Culong, Ptr{UInt8}, Ptr{Mpfr_t}), buf, lng + 1, "%.Re", &x)
    if lng < k + 5 # print at least k decimal places
        lng = ccall((:mpfr_sprintf,:libmpfr), Int32, (Ptr{UInt8}, Ptr{UInt8}, Ptr{Mpfr_t}), buf, "%.$(k)Re", &x)
    elseif lng > k + 8
        buf = Array(UInt8, lng + 1)
        lng = ccall((:mpfr_snprintf,:libmpfr), Int32, (Ptr{UInt8}, Culong, Ptr{UInt8}, Ptr{Mpfr_t}), buf, lng + 1, "%.Re", &x)
    end
    return bytestring(pointer(buf), (1 <= x < 10 || -10 < x <= -1 || x == 0) ? lng - 4 : lng)
end




