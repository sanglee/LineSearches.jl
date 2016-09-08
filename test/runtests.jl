using LineSearches
using Base.Test

lsfunctions = [hz_linesearch!,
               interpolating_linesearch!, mt_linesearch!, backtracking_linesearch!,]

f(x) = vecdot(x,x)

function g!(x, out)
    out[:] = 2x
end

df = LineSearches.LSDifferentiableFunction(f,g!)

for linesearch! in lsfunctions
    println("Testing $(string(linesearch!))")
    x = [-1., -1.]
    xtmp = copy(x)
    grtmp = similar(x)
    phi0 = df.fg!(x, grtmp)
    p = -grtmp
    dphi0 = dot(p, grtmp)

    lsr = LineSearchResults(eltype(x))
    push!(lsr, 0.0, phi0, dphi0)

    alpha = 1.0
    mayterminate = false

    alpha, f_update, g_update = linesearch!(df, x, p, xtmp, grtmp, lsr, alpha, mayterminate)
    xnew = x + alpha*p

    @test_approx_eq_eps f(xnew) 0. 1e-7
end
