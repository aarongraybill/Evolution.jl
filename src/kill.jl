""" In this we define kill(b::Being,H::Habitat)
which removes a being from the population on commmand
"""

using Evolution

function kill!(b::Being , H::Habitat)
    delete!(H.populations[b.species].beings,b.being_id)
end