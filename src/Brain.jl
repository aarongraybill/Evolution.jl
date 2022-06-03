""" 
Define how the brain of a creature works and what that brain can do

An object of type brain is essentially the structure of a being's neural network

A brain can think, so think(b::Brain,p::Perception) will be a key function

relies on the construction of neural networks in NeuralNet.jl
"""

using Evolution

@kwdef mutable struct Brain
    net::Network
end




