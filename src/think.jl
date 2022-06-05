""" 
Define how the brain of a creature works and what that brain can do

An object of type brain is essentially the structure of a being's neural network

A brain can think, so think(b::Brain,p::Perception) will be a key function

relies on the construction of neural networks in NeuralNet.jl
"""

using Evolution

function base_brain(b::Being,H::Habitat)
    if rand_weights
        out=[
        Node("output,",100,[],[],5*rand(),"reproduce"),
        Node("output,",100,[],[],5*rand(),"pivot"),
        Node("output,",100,[],[],5*rand(),"step")
        ]
        out_pairs=[(o,5*rand()) for o ∈ out]
        bias_temp=5*rand()
    else
        out=[
        Node("output,",100,[],[],0,"reproduce"),
        Node("output,",100,[],[],0,"pivot"),
        Node("output,",100,[],[],0,"step")
        ]
        out_pairs=[(o,0.0) for o ∈ out]
        bias_temp=0
    end
    ins=[Node("input",1,[],out_pairs,bias_temp,"health")]
    index_mat = fill(missing,(b.n_rays,(length(H.populations)+1)))
    for ij ∈ CartesianIndices(index_mat)
        ins=vcat(ins,Node("input",1,[],out_pairs,bias_temp,"R=$(ij[1]), P=$(ij[2]-1)"))
    end
    net=Network(vcat(ins,out))
    connect_nodes(net)
    return Brain(net)
end


function base_brain(b::Being,H::Int64,rand_weights::Bool = false)
    if rand_weights
        out=[
        Node("output,",100,[],[],5*rand(),"reproduce"),
        Node("output,",100,[],[],5*rand(),"pivot"),
        Node("output,",100,[],[],5*rand(),"step")
        ]
        out_pairs=[(o,5*rand()) for o ∈ out]
        bias_temp=5*rand()
    else
        out=[
        Node("output,",100,[],[],0,"reproduce"),
        Node("output,",100,[],[],0,"pivot"),
        Node("output,",100,[],[],0,"step")
        ]
        out_pairs=[(o,0.0) for o ∈ out]
        bias_temp=0
    end
    ins=[Node("input",1,[],out_pairs,bias_temp,"health")]
    index_mat = fill(missing,(b.n_rays,(H+1)))
    for ij ∈ CartesianIndices(index_mat)
        ins=vcat(ins,Node("input",1,[],out_pairs,bias_temp,"R=$(ij[1]), P=$(ij[2]-1)"))
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