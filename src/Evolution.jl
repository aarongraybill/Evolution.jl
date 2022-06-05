module Evolution

using Base: @kwdef
using LinearAlgebra
using Parameters
using Random


# Create bespoke neural network
include("NeuralNet.jl")

# Create the being class
include("Being.jl")

# Create the wall class
include("Wall.jl")

# Define how to do ray tracing for a ray and a target object
include("RayTracing.jl")

#Define what a being's environment looks like and how to define a population
include("Habitat.jl")

#Figure out how a being sees all of the objects in its environment and translates that to
# the minimal perceived information
include("Perceive.jl")

# construct put neural network in being
include("think.jl")

# How an offsping is connected to the habitat and slightly altered
include("reproduce.jl")

# How to kill a being if they get eaten or starve or what have you
include("kill.jl")

# how different species behave in a given iteration
include("act.jl")

end