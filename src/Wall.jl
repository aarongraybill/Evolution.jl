using Parameters
using LinearAlgebra

@with_kw mutable struct Wall
    start::Vector{Float64}
    finish::Vector{Float64}
end

function norm_vec(wall::Wall)
    w=wall.finish-wall.start
    if w[2]==0
        return [0,-1]
    else
        n=[1,-w[1]/w[2]]
        n=n/sqrt(n⋅n)
        return n
    end
end

function connector_vec(wall::Wall)
    diff=(wall.finish-wall.start)
    diff=diff/sqrt(diff⋅diff)
    return diff
end