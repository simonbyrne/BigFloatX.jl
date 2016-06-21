using BigFloatX

N = 100
X = randn(N,N)
Y = randn(N,N)

Xj = map(BigFloat,X);
Yj = map(BigFloat,Y);
@time Xj*Yj;
@time Xj*Yj;
@time Xj*Yj;

Xa = map(BigFloatA,X);
Ya = map(BigFloatA,Y);
@time Xa*Ya;
@time Xa*Ya;
@time Xa*Ya;

Xb = map(BigFloatB,X);
Yb = map(BigFloatB,Y);
@time Xb*Yb;
@time Xb*Yb;
@time Xb*Yb;
