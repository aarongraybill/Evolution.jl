"""
Define how the brain of a creature works and what that brain can do

An object of type brain is essentially the structure of a being's neural network

A brain can think, so think(b::Brain,p::Perception) will be a key function
"""

using Evolution

# @kwdef mutable struct Brain

# end

Base.@kwdef mutable struct Node
    type::String #input, output, hidden
    layer::Int64
    inputNodes::Array{Node}
    outputNodes::Array{Node}
    weights_in::Array{Float64} # includes bias as first element
end

Base.@kwdef mutable struct Network
    Nodes::Vector{Node}
end

function compute_neural_net(input_vec::Array{Float64},net::Network)
    #findmax(i->i.layer,net)
    # findall(i->i>0.5, net)
    # for node ∈ net.Nodes
    #     if node.type=="input"

    #     end
    # end
end

function compute_p(input_vec::Array{Float64},node::Node)
    @assert length(input_vec)+1==length(node.weights_in) "Input vector must match number of weights"
    p=vcat([1],input_vec)⋅node.weights_in
    return p
end

