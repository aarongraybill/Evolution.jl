""" The Habitat type

The `Habitat` type is essentially the state of the world at a given time

A `Habitat` includes a population of predators, prey, walls
and the characteristics of each
"""

@kwdef mutable struct Population
    species::String = nothing #predator,prey,etc don't call directly infered from species
    beings::Vector{Being}
    id_vec::Vector{String} = nothing # shouldn't specify this directly
    function Population(species,beings)
        id_vec=getfield.(beings,Ref(:being_id))
        species_vec = unique([b.species for b in beings])
        @assert length(species_vec)==1 "One species per pop please"
        new(species_vec[1],beings,id_vec)
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
    populations::Vector{Population}
    enclosure::Enclosure
end