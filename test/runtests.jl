using Evolution
using Test

b=Evolution.Being(position=[.7,.1],facing=[0,1],age=5,species="skunk",being_id="31415",radius=.5,view_angle=π,n_rays=3)
test_wall = Evolution.Wall([1,-1],[1,1])
test_ray = Evolution.Ray([0,0],[1,1]) # should get forced to magnitude 1
prey=repeat([b],5)
prey=Evolution.Population("skunk",prey)
a=deepcopy(b)
a.species = "wolf"
pred=repeat([a],3)
pred=Evolution.Population("wolf",pred)

H = Evolution.Habitat([prey,pred],Evolution.Enclosure())

Evolution.perceive(b,H)

@testset "Evolution.jl" begin
    @test Evolution.trace_ray(test_ray,test_wall)≈√2
    @test Evolution.trace_ray(test_ray,b)≈sqrt(2*.3^2)
    @test getfield.(Evolution.create_rays(b),Ref(:u))≈[[1,0],[0,1],[-1,0]] #test that the heading directions of rays are correct

end
