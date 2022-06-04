""" In this we define kill(b::Being,H::Habitat)
which removes a being from the population on commmand
"""

using Evolution

function kill(b::Being , H::Habitat)
    
    new_pops = deepcopy(H.populations)
    target_species = new_pops[[pop.species==b.species for pop in new_pops]][1]
    ignored_species = new_pops[[pop.species!=b.species for pop in new_pops]]
    function compare_to_b(x)
        return x≈b
    end
    dead_index = findfirst(compare_to_b,target_species.beings)
    target_species.beings = target_species.beings[1:end .!=dead_index]
    @show length(target_species.beings)
    new_H = Habitat(
        vcat([target_species],ignored_species),
        H.enclosure
    )
    return new_H
end