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

function scramble_brain(old_brain::Brain; scramble::Float64=.01,node_prob::Float64=.001,node_depth::Int64=3)
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
        other_nodes = setdiff(brain.net.nodes,out_nodes) # nodes that can be inputs
        n_nodes = length(brain.net.nodes)
        binom_p = (node_depth-2.0)/(n_nodes-2.0)
        n_pulls_extra = rand(Binomial(n_nodes-2,binom_p))
        in_1 = rand(other_nodes)
        out_1 = rand(out_nodes)
        others=[x for x in setdiff(brain.net.nodes,[in_1],[out_1])]
        selections = StatsBase.sample(1:length(others),n_pulls_extra,replace=false)
        others = Set(others[selections])
        hidden_nodes=length(other_nodes)-length(brain.inputs)
        new_node = n.add_node!(brain.net,"hidden node $(hidden_nodes+1)",0.0)
        connections = Set([in_1]) ∪ others ∪ Set([out_1])
        for input ∈ connections ∩ other_nodes
            n.add_edge!(brain.net,input,new_node,0.0)
        end
        for output ∈ connections ∩ out_nodes
            n.add_edge!(brain.net,new_node,output,0.0) 
        end
    end

    # do random scrambling
    [brain.net.biases[node] = bias + randn()*scramble for (node, bias) ∈ brain.net.biases]
    
    # update every weight
    [brain.net.weights[edge] = weight + randn()*scramble for (edge,weight) ∈ brain.net.weights]

    return brain
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

function reproduce!(b::Being,H::Habitat)
    """Returns a new habitat with an offspring added
    """
    if b∈ values(H.populations[b.species].beings) 
        #@assert b ∈ reduce(vcat,[x.beings for x in H.populations]) "Being needs to be in population"
        new_brain=scramble_brain(b.brain)
        pos_rand = 2π*rand()
        #@show b.being_id
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
        #new_pops = deepcopy(H.populations)
        #println("Looking for $(b.species)")
        #println("$([pop.species==b.species for pop in new_pops])")
        target_species = H.populations[b.species].beings # a dictionary
        #@show typeof(target_species)
        #@assert b ∈ values(target_species)
        b.n_children = b.n_children+1
        merge!(target_species,Dict(new_being.being_id=>new_being))
    end
    return H
end
