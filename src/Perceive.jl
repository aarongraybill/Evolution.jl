"""
Define the structure of a creature's input in a given period.

Should include the object hit by each ray and its distance

"""


using Evolution

@kwdef mutable struct Perception
  objects::Array{Float64}
  distances::Array{Float64}
end

function perceive(b::Being,H::Habitat)
  rays = create_rays(b) # The rays the being always casts
  n_walls=length(H.enclosure.walls)

  # Create a vector to store what each ray is directed at (wall, prey, pred,...)
  object_type = repeat([0],n_walls)

  perception = Array{Float64}(undef,b.n_rays,n_walls)
  for (i,wall) ∈ enumerate(H.enclosure.walls)
     perception[:,i]=trace_ray.(rays,Ref(wall))
  end

  n_pops = length(H.populations)
  # a vector of vectors for perception of each population
  for (i,pop) ∈ enumerate(H.populations)
    object_type = vcat(object_type,repeat([i],length(pop.beings)))
    for (j,b_t) ∈ enumerate(pop.beings)
      if b==b_t #don't perceive yourself, so just set that to infinity
        perception=hcat(perception,repeat([Inf],b.n_rays))
      else
        perception=hcat(perception,trace_ray.(rays,Ref(b_t)))
      end
    end
  end

  mins,indices = findmin(perception,dims=2)

  # quick function to get column from index and find what object that corresponds to
  function get_object_from_index(c::CartesianIndex)
    place_in_vec=c[2]
    return object_type[place_in_vec]
  end
  
  objects=get_object_from_index.(indices)

  return Perception(objects,mins)
end