using Evolution
using Test

# Node1 = Evolution.Node(
#     type="input",
#     layer=1,inputNodes=[],
#     outputNodes=[],
#     bias=0.0
#     )
    
b=Evolution.base_being("skunk");
test_wall = Evolution.Wall([1,-1],[1,1])
test_ray = Evolution.Ray([0,0],[1,1]) # should get forced to magnitude 1
prey=[deepcopy(b) for _ in 1:5];
prey[1].being_id = "p1";
prey[2].being_id = "p2";
prey[3].being_id = "p3";
prey[4].being_id = "p4";
prey[5].being_id = "p5";
prey=Evolution.Population("skunk",prey);

a=deepcopy(b);
a.species = "wolf";
pred=[deepcopy(a) for _ in 1:3];
pred[1].being_id = "w1";
pred[2].being_id = "w2";
pred[3].being_id = "w3";
pred=Evolution.Population("wolf",pred);

H = Evolution.Habitat([prey,pred],Evolution.Enclosure());

p=Evolution.perceive(b,H)

[b.brain=Evolution.scramble_brain(b.brain) for _ in 1:1000];

@testset "Evolution.jl" begin
    @test Evolution.trace_ray(test_ray,test_wall)≈√2
    @test isapprox(Evolution.trace_ray(test_ray,b),0.3011143517,rtol=.001)
    @test getfield.(Evolution.create_rays(b),Ref(:u))≈[[0,-1],[1,0],[0,1]] #test that the heading directions of rays are correct

end
