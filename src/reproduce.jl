using Evolution

"""
Given a being (it's brain mostly), the fact that it is reproducing,
and some randomness parameters, define a new offspring and add to habitat
"""


function maxk(a, k)
    b = sortperm(a, rev=true)
    return unique(a[b])[k]
end

function scramble_brain(brain::Brain; scramble=.01,node_prob=.01,node_depth=1.0,layer_prob=.01)
    """Given a brain add some randomness and return a new brain
    scramble is the percentage by which every number changes
    node_prob is prob of introducing a new node at current layer_prob
    node_depth is the fraction of nodes in previous layer that connect to new nodes
    layer_prob is prob of adding a new layer entirely
    """
    node_roll=rand()
    layer_roll=rand()
    new_net=deepcopy(brain.net)
    second_biggest_layer = maxk([x.layer for x in new_net.Nodes],2)
    biggest_layer = maxk([x.layer for x in new_net.Nodes],1)
    out_nodes = get_nodes_in_layer(biggest_layer,new_net)
    out_tup = [(o,0.0) for o in out_nodes]

    if second_biggest_layer+1 == biggest_layer
        #print("No room")
        #don't add a layer if you have no room
    elseif layer_roll < layer_prob
        #println("Adding Layer")
        cur_nodes=get_nodes_in_layer(second_biggest_layer,new_net)
        n_connections=Int64(ceil(length(cur_nodes)*node_depth))
        connections=cur_nodes[randperm(length(cur_nodes))[1:n_connections]]
        id_name=string("L=$(second_biggest_layer+1), N=1, layer start")
        con_tup = [(c,0.0) for c in connections] #doesn't do anything initially
        new_node=Node("hidden",second_biggest_layer+1,con_tup,out_tup,0.0,id_name)
        new_net=Network(vcat(new_net.Nodes,new_node))
        connect_nodes(new_net)
    end
    
    if second_biggest_layer == 1
        #can't add another node to input layer
    elseif node_roll<node_prob
        # add a new Node
        #print("add a Node")
        cur_nodes=get_nodes_in_layer(second_biggest_layer-1,new_net)
        n_connections=Int64(ceil(length(cur_nodes)*node_depth))
        connections=cur_nodes[randperm(length(cur_nodes))[1:n_connections]]
        id_name=string("L=$(second_biggest_layer), N=$(length(get_nodes_in_layer(second_biggest_layer,new_net))+1)")
        con_tup = [(c,0) for c in connections] #new connections don't do anything initially
        new_node=Node("hidden",second_biggest_layer,con_tup,out_tup,0.0,id_name)
        new_net=Network(vcat(new_net.Nodes,new_node))
        connect_nodes(new_net)
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
