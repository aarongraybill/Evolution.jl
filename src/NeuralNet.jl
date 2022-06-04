"""
A rather poor bespoke solution to a create a neral network that can live inside a being


"""

using Evolution

# @kwdef mutable struct Brain

# end

Base.@kwdef mutable struct Node
    type::String #input, output, hidden
    layer::Int64
    inputNodes::Array{Tuple{Node,Float64}} #redundantly store weights
    outputNodes::Array{Tuple{Node,Float64}} #goes to output node with certain weight
    bias::Float64
    opt_text::String = ""
end

@kwdef mutable struct Network
    Nodes::Vector{Node}
    n_layers::Int64 = undef #likely won't be specified directly
    function Network(Nodes,n_layers=undef)
        temp_max=0
        for node ∈ Nodes
            temp_max=max(temp_max,node.layer)
        end
        new(Nodes,temp_max)
    end
end


function connect_nodes(net::Network)
    """
    There are two options. Taking the case of Node A as an input for B.
    Option 1: Node A is not listed as an input for Node b
    Option 2: Node A is listed, but with an outdated value

    I will make the assumption of input-overwrite priority
    so if the weight on NodeA→NodeB (output weight) ≠ weight on NodeB→NodeA (input weight)
        I set NodeA→NodeB to the value that is on NodeB→NodeA

    As such, only if A→B exists but B→A DNE, then the output weight will be written as an input weight for NodeB→NodeA
        We will almost always construct nets increasing by layer, so that doesn't matter too much
    """
    
    n=deepcopy(net)

    inputs_by_node = [(x,x.inputNodes) for x in n.Nodes]
    outputs_by_node = [(x,x.inputNodes) for x in n.Nodes]

    # i list you as an input, you should list me as an output
    for (i,(node,inputs)) ∈ enumerate(inputs_by_node)
        for (j,(node_in,val)) ∈ enumerate(inputs)
            temp_outs=node_in.outputNodes[[x[1]!=node for x in node_in.outputNodes]]
            node_in.outputNodes = vcat(temp_outs,(node,val))
        end
    end

    #i list you as an output, you should list me as an input
    for (i,(node,outputs)) ∈ enumerate(outputs_by_node)
        for (j,(node_out,val)) ∈ enumerate(outputs)
            temp_ins=node_out.inputNodes[[x[1]!=node for x in node_out.inputNodes]]
            node_out.inputNodes = vcat(temp_ins,(node,val))
        end
    end

    return(n)
end

function get_nodes_in_layer(layer::Int64,net::Network)
    temp_list = Node[]
    for node ∈ net.Nodes
        if node.layer==layer
            temp_list=vcat(temp_list,node)
        end
    end
    return temp_list
end


# function input_output(input_vec::Array{Tuple{Node,Float64}},net::Network)
#     for (i,(node_in,val)) = enumerate(input_vec)
#         run_sum
#         inputs = [x[1] x in node.inputNodes]
#     end
# end



function find_value(targetNode::Node,input_vec::Array{Tuple{Node,Float64}})
    temp_val=missing
    for (i,(inNode,val)) ∈ enumerate(input_vec)
        #print("Iteration $i, with value $val Starting a new one! \n")
        #@show targetNode==inNode
        if targetNode==inNode
            temp_val=val
        end
    end
    return temp_val
end

"""
This function essentially creates a lookup table of output values. 
    We begin with a lookup table of the output values from the input layer (the inputs)
    These first value are used to compute the outputs of layer two which are then 
    added to the lookup table so that layer 3 can pull from layer 2 etc

    The only reason this works is because we never update the output value of a 
    node once its been computed
"""
function compute_neural_net(
    input_vec::Array{Tuple{Node,Float64}},
    net::Network
    )
    old_vec=input_vec #outputs of last iteration
    new_vec=input_vec #outputs of this iteraton/lookup table
    for i ∈ 2:net.n_layers # first layer trival
        cur_nodes=get_nodes_in_layer(i,net) # the nodes that need outputs now
        #if length(cur_nodes)!=0
            #println("Layer $i has $(length(cur_nodes)) nodes")
        #end
        #@show i
        for node in cur_nodes
            run_sum=node.bias #implicity resets sum
            inputs=[x[1] for x in node.inputNodes] # who feeds inito this node
            for input ∈ inputs #for each input node add to weighted sum
               # println([(o[1].opt_text,o[2]) for o in old_vec])
                #println()
                v=find_value(input,old_vec)
                w=find_value(input,node.inputNodes)
                run_sum = run_sum + v*w
            end
            new_vec=vcat(new_vec,[(node,run_sum)]) # add to lookup table
        end
        old_vec=new_vec #new vec gets used as old vec for next layer
    end
    output_layer=get_nodes_in_layer(net.n_layers,net) #what nodes are in output
    out=new_vec[[x[1] for x in new_vec].∈Ref(output_layer)] #only return outputs
    return out
end

function disconnect(Node_in::Node,Node_out::Node,net::Network)
    Node_in.outputNodes=Node_in.outputNodes[[x[1] for x ∈ Node_in.outputNodes].≠ Ref(Node_out)]
    Node_out.inputNodes=Node_out.inputNodes[[x[1] for x ∈ Node_out.inputNodes].≠ Ref(Node_in)]
    #connect_nodes(net) this might be necessay, I'm going to hope not
end


# Define the actual brain of a being

@kwdef mutable struct Brain
    net::Network
    function Brain(net)
        connect_nodes(net)
        new(net)
    end
end




# for node ∈ net.Nodes
#     #print(node.layer)
#     inNodes=node.inputNodes
#     outNodes=node.outputNodes

#     # anything I list as an input should list me as output
#     for (i,inNode) ∈ enumerate(inNodes)
#         #list comprehension to get node not weight
#         their_outs=inNode[1].outputNodes
#         their_out_nodes=[x[1] for x in their_outs]
#         if node ∉ their_out_nodes
#             inNode[1].outputNodes = vcat(inNode[1].outputNodes,(node,node.inputNodes[i][2]))
#         end
#     end

#     # anything I list as an output should list me as an input
#     for (i,outNode) ∈ enumerate(outNodes)
#         their_ins=outNode[1].inputNodes
#         their_in_nodes=[x[1] for x in their_ins]
#         if node ∉ their_in_nodes
#             outNode[1].inputNodes = vcat(outNode[1].inputNodes,(node,node.outputNodes[i][2]))
#         end
#     end
# end

function test_neural_net(network::Network,inval::Float64=Float64(π))
    n=deepcopy(network)
    first_layer=get_nodes_in_layer(1,n)
    input=[(node,inval) for node in first_layer]
    return [x[2] for x in compute_neural_net(input,n)]
end

