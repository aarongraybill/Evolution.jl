""" The Habitat type

The `Habitat` type is essentially the state of the world at a given time

A `Habitat` includes a population of predators, prey, walls
and the characteristics of each
"""

@kwdef mutable struct Population
    species::String = nothing #predator,prey,etc don't call directly infered from species
    beings::Dict{String,Being}
    function Population(beings::Vector{Being})
        out_dict = Dict{String,Being}()
        [merge!(out_dict,Dict(b.being_id=>b)) for b in beings]
        species_vec = unique([b.species for b in beings])
        @assert length(species_vec)==1 "One species per pop please"
        new(species_vec[1],out_dict)
    end
end

@kwdef mutable struct Enclosure
    walls::Vector{Wall} =
    [Wall([-100,-100],[-100,100]),
    Wall([-100,100],[100,100]),
    Wall([100,100],[100,-100]),
    Wall([100,-100],[-100,-100])]
end

@kwdef mutable struct Habitat
    populations::Dict{String, Population}
    enclosure::Enclosure
    function Habitat(populations::Vector{Population},enclosure::Enclosure)
        out_dict = Dict{String, Population}()
        [merge!(out_dict,Dict(pop.species=>pop)) for pop ∈ populations]
        new(out_dict,enclosure)
    end
end