using Evolution
using Test

Node1 = Evolution.Node(
    type="input",
    layer=1,inputNodes=[],
    outputNodes=[],
    bias=0.0
    )
Node2 = Evolution.Node(
    type="hidden",
    layer=2,inputNodes=[(Node1,69.0)],
    outputNodes=[],
    bias=2.0
    )
Node3 = Evolution.Node(
    type="output",
    layer=3,
    inputNodes=[
        (Node2,4.0),
       (Node1,5.0)
    ],
    outputNodes=[],
    bias=0.0
)

net=Evolution.Network([Node1,Node2,Node3])

Evolution.connect_nodes(net)

Evolution.compute_neural_net([(Node1,3.0)],net);
