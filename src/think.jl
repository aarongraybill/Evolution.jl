""" 
Define how the brain of a creature works and what that brain can do

An object of type brain is essentially the structure of a being's neural network

A brain can think, so think(b::Brain,p::Perception) will be a key function

relies on the construction of neural networks in NeuralNet.jl
"""

using Evolution
import NeuralTests as n

@kwdef mutable struct Brain
    net::n.Network
    inputs::Dict{String,n.Node} # =Dict{String,n.Node}([])
    outputs::Dict{String,n.Node} # =Dict{String,n.Node}([])
end


function base_brain(n_species::Int64,n_rays::Int64,rand_weight::Bool=true)
    in_dict = Dict{String,n.Node}()
    out_dict = Dict{String,n.Node}()
    weight(rand_weight::Bool) = rand_weight ? randn() : Float64(0.0)
    net = n.Network()

    #create output nodes
    n1=n.add_node!(net,"out_reproduce",weight(rand_weight))
    n2=n.add_node!(net,"out_pivot",weight(rand_weight))
    merge!(out_dict,Dict("out_reproduce"=>n1,"out_pivot"=>n2))
    #@show size(out_dict)
    # health has a slightly different format but is an input 
    n_h=n.add_node!(net,"in_health",weight(rand_weight))
    merge!(in_dict,Dict("in_health"=>n_h))
    for output in values(out_dict)
        n.add_edge!(net,n_h,output,weight(rand_weight))
    end
    for ij in CartesianIndices((1:n_rays,1:(n_species+1)))
        new_node = n.add_node!(net,"in_R$(ij[1]),S$(ij[2]-1)",weight(rand_weight))
        merge!(in_dict,Dict("in_R$(ij[1]),S$(ij[2]-1)"=>new_node))
        for output in values(out_dict)
            n.add_edge!(net,new_node,output,weight(rand_weight))
        end
    end
    return Brain(net,in_dict,out_dict)
end

function base_being(being_id::String,n_species::Int64=2,n_rays::Int64=5)
    brain = base_brain(n_species,n_rays)
    return Being([0,0],[1,0],0,"skunk",being_id,.5, 2π/3,n_rays,brain,1.0,0)
end

function base_being(being_id::String,n_species::Int64=2,n_rays::Int64=5,species::String = "skunk")
    brain = base_brain(n_species,n_rays)
    return Being([0,0],[1,0],0,species,being_id,.5, 2π/3,n_rays,brain,1.0,0)
end

function think(b::Being,p::Perception)
    inputs=interpret(b,p)
    outputs=n.compute_neural_net(b.brain.net,inputs,Set(values(b.brain.outputs)))
    temp_out = Dict([(k.opt_text,val) for (k,val) ∈ outputs])
    return temp_out
end