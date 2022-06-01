module Evolution

using Base: @kwdef
using LinearAlgebra
using Parameters

# Create the being class
include("Being.jl")

# Create the wall class
include("Wall.jl")

# Define how to do ray tracing for a ray and a target object
include("RayTracing.jl")

#Define what a being's environment looks like and how to define a population
include("Habitat.jl")

include("Perceive.jl")

include("Brain.jl")

end