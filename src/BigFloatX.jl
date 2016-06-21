module BigFloatX

using Compat

export BigFloatA, BigFloatB

import Base.MPFR: ROUNDING_MODE

import Base.GMP: ClongMax, CulongMax, CdoubleMax, Limb

import Base: convert, cconvert, unsafe_convert, string, precision,
    +, *, cmp, zero

type Mpfr_t
    prec::Clong
    sign::Cint
    exp::Clong
    d::Ptr{Limb}
end

include("a.jl")
include("b.jl")

end # module
