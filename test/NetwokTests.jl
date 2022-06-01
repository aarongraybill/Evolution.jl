using Evolution
using Test

Node1 = Evolution.Node(
    type="input",
    layer=1,inputNodes=Array{Evolution.Node}(undef),
    outputNodes=Array{Evolution.Node}(undef),
    weights_in=Array{Float64}(undef)
    )
Node2 = Evolution.Node(type="input",layer=1,inputNodes=Array{Evolution.Node}(undef),outputNodes=Array{Evolution.Node}(undef))