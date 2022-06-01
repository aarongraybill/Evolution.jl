""" The Habitat type

The `Habitat` type is essentially the state of the world at a given time

A `Habitat` includes a population of predators, prey, walls
and the characteristics of each
"""

@kwdef mutable struct Population
    species::String #predator,prey,etc
    beings::Vector{Being}
    id_vec::Vector{String} = nothing # shouldn't specify this directly
    function Population(species,beings)
        id_vec=getfield.(beings,Ref(:being_id))
        new(species,beings,id_vec)
    end
end

@kwdef mutable struct Enclosure
    walls::Vector{Wall} =
    [Wall([-1,-1],[-1,1]),
    Wall([-1,1],[1,1]),
    Wall([1,1],[1,-1]),
    Wall([1,-1],[-1,-1])]
end

@kwdef mutable struct Habitat
    populations::Vector{Population}
    enclosure::Enclosure
end