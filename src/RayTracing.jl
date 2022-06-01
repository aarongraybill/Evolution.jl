using Parameters
using LinearAlgebra
using Base: @kwdef

@kwdef mutable struct Ray
    o::Array{Float64,1}
    u::Vector{Float64}
    function Ray(o,u)
        if !(u⋅u ≈ 1)
            "Coercing `u` to magnitude 1"
            u=u/sqrt(u⋅u)
        end
        new(o,u)
    end
end

"""
the trace ray function accepts a ray and a target and determines
if there is an intersection. If not, return nothinig
If intersection, returrn distance
"""

function trace_ray(ray::Ray,target::Being)
    c=target.position
    r=target.radius
    o=ray.o
    u=ray.u
    v=o-c
    ∇=(u⋅v)^2-((v⋅v)-r^2)
    if ∇<0
        return Inf64
    else
        d=-(u⋅v)-sqrt(∇)
        if d>0
            return d
        else
            return Inf
        end
    end
end

function trace_ray(ray::Ray,target::Wall)
    n=connector_vec(target)#norm_vec(target)
    o=ray.o
    u=ray.u
    if u ⋅n ≈ 1
        #line of sight parrallel
        return Inf64
        #this slightly omits the case of parrrel but on the Wall
    elseif rank([u -n])==1 #deal with parrrel business
        return Inf64
    else
        A=[u -n]
        d = A\(target.start-o)
        if 0 ≤ d[2] ≤ 1 && d[1] ≥ 0
            return d[1]
        else
            return Inf
        end
    end
end