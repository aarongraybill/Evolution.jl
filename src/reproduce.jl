using Evolution
using Distributions
using StatsBase

"""
Given a being (it's brain mostly), the fact that it is reproducing,
and some randomness parameters, define a new offspring and add to habitat
"""


function maxk(a, k)
    b = sortperm(a, rev=true)
    return unique(a[b])[k]
end

function scramble_brain(old_brain::Brain; scramble::Float64=.01,node_prob::Float64=.01,node_depth::Int64=3)
    """Given a brain add some randomness and return a new brain
    scramble is sd of the change to each weight
    node_prob is prob of introducing a new node 
    node_depth is the /average/ number of new connections
    """
    @assert node_depth ≥ 2 "Need at least one input and output"
    brain=deepcopy(old_brain)

    node_roll=rand() # will we create a new node or not?
    if node_roll < node_prob
        out_nodes = Set(values(brain.outputs)) # the nodes we can't have as inputs, static
        other_nodes = setdiff(brain.net,nodes,out_nodes) # nodes that can be inputs
        n_nodes = length(net.nodes)
        binom_p = (node_depth-2.0)/(n_nodes-2.0)
        n_pulls_extra = rand(Binomial(n_nodes-2,binom_p))
        in_1 = rand(other_nodes)
        out_1 = rand(out_nodes)
        others = StatsBase.sample(setdiff(brain.net.nodes,in_1,out_1),n_pulls_extra,replace=false)
        hidden_nodes=length(other_nodes)-length(brain.inputs)
        new_node = n.add_node!(brain.net,"hidden node $(hidden_nodes+1)")
        connections = in_1∪others∪out_1
        for input ∈ connections ∩ other_nodes
            n.add_edge!(brain.net,input,new_node,0.0)
        end
        for output ∈ connections ∩ out_nodes
            n.add_edge!(brain.net,new_node,output,0.0) 
        end
    end

    # do random scrambling
    for node ∈ new_net.Nodes
        node.bias=node.bias+randn()*scramble
    end

    connect_nodes(new_net)
    
    # the last layer has everything as an input so it's convenient to update weights
    for layer ∈ vcat(1:second_biggest_layer,biggest_layer)
        nodes=get_nodes_in_layer(layer,new_net)
        for node in nodes
            new_weights=[x[2] for x in node.inputNodes]+scramble*randn(length(node.inputNodes))
            nodes_temp=[x[1] for x in node.inputNodes]
            node.inputNodes=[(nodes_temp[i],new_weights[i]) for i in 1:length(nodes_temp)]
            #connect_nodes(new_net)
        end
    end

    return Brain(new_net)
end

import Base: ≈
function ≈(b1::Being,b2::Being)
    fields=setdiff(fieldnames(Being),[:brain])
    test = true
    for field in fields
        val=getfield(b1,field)==getfield(b2,field)
        if !val
            return false
        end
    end
    test=test*(test_neural_net(b1.brain.net)≈test_neural_net(b2.brain.net))
    return test
end

function reproduce(b::Being,H::Habitat)
    """Returns a new habitat with an offspring added
    """
    #@assert b ∈ reduce(vcat,[x.beings for x in H.populations]) "Being needs to be in population"
    new_brain=scramble_brain(b.brain)
    pos_rand = 2π*rand()
    new_being=Being(
        position = b.position+1.1*2*b.radius*[cos(pos_rand),sin(pos_rand)],
        facing = [cos(pos_rand),sin(pos_rand)],
        age=0,
        species=b.species,
        being_id=string("$(b.being_id)→c$(b.n_children+1)"),
        radius = b.radius,
        view_angle = b.view_angle,
        n_rays = b.n_rays,
        brain = new_brain,
        health = 1.0
    )
    new_pops = deepcopy(H.populations)
    #println("Looking for $(b.species)")
    #println("$([pop.species==b.species for pop in new_pops])")
    target_species = new_pops[[pop.species==b.species for pop in new_pops]][1]
    ignored_species = new_pops[[pop.species!=b.species for pop in new_pops]]
    #@show size(ignored_species)
    target_species.beings = vcat(target_species.beings,[new_being])
    #println("$([x ≈ b for x in target_species.beings])")
    parent = target_species.beings[
        [x ≈ b for x in target_species.beings]
    ]
    if length(parent)>0
        parent=parent[1]
        parent.n_children = parent.n_children+1
        #@show typeof((vcat([target_species],ignored_species)))
        new_H = Habitat(
            vcat([target_species],ignored_species),
            H.enclosure
        )
        return new_H
    else
        return H
    end
end
