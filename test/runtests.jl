using Evolution
using Test

# Node1 = Evolution.Node(
#     type="input",
#     layer=1,inputNodes=[],
#     outputNodes=[],
#     bias=0.0
#     )

test_wall = Evolution.Wall([1,-1],[1,1])
test_ray = Evolution.Ray([0,0],[1,1]) # should get forced to magnitude 1
    

prey = [Evolution.base_being("skunk_p$i",2,3) for i in 1:500];
prey=Evolution.Population(prey);

pred = [Evolution.base_being("wolf_p$i",2,3,"wolf") for i in 1:300];
pred=Evolution.Population(pred);

H = Evolution.Habitat([prey,pred],Evolution.Enclosure());

# p=Evolution.perceive(get(H.populations["skunk"].beings,"skunk_p1",missing),H);
# t = Evolution.think(H.populations["skunk"].beings["skunk_p1"],p);

# Evolution.reproduce!(H.populations["skunk"].beings["skunk_p1"],H);
# Evolution.kill!(H.populations["skunk"].beings["skunk_p1→c1"],H);

Evolution.iterate!(H)



# out1 = Evolution.think(b,p);
# [b.brain=Evolution.scramble_brain(b.brain,node_depth=5) for _ in 1:10000];
# out2 = Evolution.think(b,p);

# using BenchmarkTools
# inputs = Evolution.interpret(get(H.populations[1].beings,"p1",missing),p)
# @benchmark Evolution.interpret(b,p)
# import NeuralTests as n
# @benchmark n.compute_neural_net(b.brain.net,inputs,Set(values(b.brain.outputs)))

@testset "Evolution.jl" begin
    @test Evolution.trace_ray(test_ray,test_wall)≈√2
    @test isapprox(Evolution.trace_ray(test_ray,b),Inf,rtol=.001)
    @test getfield.(Evolution.create_rays(b),Ref(:u))≈[[0.5000000000000001, -0.8660254037844386], [1.0, 0.0], [0.5000000000000001, 0.8660254037844386]] #test that the heading directions of rays are correct
end
