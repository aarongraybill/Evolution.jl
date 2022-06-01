"""
The being structure contains all of the relevant information about a entity in the simulation,
position, movement, health, neural net, etc
"""

using Parameters
using Base: @kwdef

@kwdef mutable struct Being
    position::Array{Float64,1}
    facing::Vector{Float64} = [1,1]
    age::Int = 0
    species::String #predator, prey, apex, etc.
    being_id::String #unique within a species
    radius::Float64
    view_angle::Float64 # angle for cone of vision
    n_rays::Int64 # how many rays to trace
    #senses::Senses # the being's current inputs
    #brain::Brain # how being reacts to senses
    #health::Float64

    function Being(position,facing,age,species,being_id,radius,view_angle,n_rays)
        if !occursin(species,being_id)
            # create species being id
            being_id= "$(species)_$being_id"
        end
        new(position,facing,age,species,being_id,radius,view_angle,n_rays)
    end
end

function rotate(v::Vector{Float64},ϕ::Float64)
    A = [[cos(ϕ),sin(ϕ)] [-sin(ϕ),cos(ϕ)]]
    A*v
end

function create_rays(being::Being)
    θ=being.view_angle/2
    angles = LinRange(-θ,θ,being.n_rays) # the spread of angles to look at
    directions = rotate.(Ref(being.facing),angles)
    Ray.(Ref(being.position),directions)
end

