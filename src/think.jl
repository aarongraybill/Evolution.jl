""" 
Define how the brain of a creature works and what that brain can do

An object of type brain is essentially the structure of a being's neural network

A brain can think, so think(b::Brain,p::Perception) will be a key function

relies on the construction of neural networks in NeuralNet.jl
"""

using Evolution

function base_brain(b::Being,H::Habitat)
    out=[
        Node("output,",100,[],[],.5,"reproduce"),
        Node("output,",100,[],[],0,"pivot"),
        Node("output,",100,[],[],0,"step")
    ]
    out_pairs=[(o,0.0) for o ∈ out] #start with zero weight,consider random
    ins=[Node("input",1,[],out_pairs,0,"health")]
    index_mat = fill(missing,(b.n_rays,(length(H.populations)+1)))
    for ij ∈ CartesianIndices(index_mat)
        ins=vcat(ins,Node("input",1,[],out_pairs,0.0,"R=$(ij[1]), P=$(ij[2]-1)"))
    end
    net=Network(vcat(ins,out))
    connect_nodes(net)
    return Brain(net)
end

function base_brain(b::Being,H::Int64)
    out=[
        Node("output,",100,[],[],.5,"reproduce"),
        Node("output,",100,[],[],0,"pivot"),
        Node("output,",100,[],[],0,"step")
    ]
    out_pairs=[(o,0.0) for o ∈ out] #start with zero weight,consider random
    ins=[Node("input",1,[],out_pairs,0,"health")]
    index_mat = fill(missing,(b.n_rays,(H+1)))
    for ij ∈ CartesianIndices(index_mat)
        ins=vcat(ins,Node("input",1,[],out_pairs,0.0,"R=$(ij[1]), P=$(ij[2]-1)"))
    end
    net=Network(vcat(ins,out))
    connect_nodes(net)
    return Brain(net)
end


function think(b::Being,p::Perception,H::Habitat)
    inputs=interpret(b,p,H)
    outputs=compute_neural_net(inputs,b.brain.net)
    return outputs
end