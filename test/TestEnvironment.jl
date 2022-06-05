using Evolution
using Test

Evolution.Random.seed!(1)
function facing_from_rand(θ)
    return [cos(θ),sin(θ)]
end

Node1 = Evolution.Node(
    type="input",
    layer=1,inputNodes=[],
    outputNodes=[],
    bias=0.0
    );
b=Evolution.Being(
    position=[.7,.1],
    facing=[1.0,0.0],
    age=0,
    species="skunk",
    being_id="p1",
    radius=.5,
    view_angle=π,
    n_rays=2,
    brain=Evolution.Brain(Evolution.Network([Node1])),
    health=0.0,
    n_children=0
);

b_vec=[
    Evolution.Being(
        position=10*(2*rand(2).-1),
        facing=facing_from_rand(2π*rand()),
        age=0,
        species="skunk",
        being_id="p$i",
        radius=.5,
        view_angle=π,
        n_rays=2,
        brain=Evolution.base_brain(b,1,true),
        health=1.0,
        n_children=0
) for i in 1:100];

pop=Evolution.Population(nothing,b_vec);

H = Evolution.Habitat([pop],Evolution.Enclosure());
H_new = deepcopy(H);
for i ∈ 1:100
    print("Iteration $i, population: ")
    println(length(H_new.populations[1].beings))
    H_new = Evolution.iterate(H_new)
end

# #x= Evolution.test_neural_net.()
# p_vec=Evolution.perceive.(H_new.populations[1].beings,Ref(H_new))
# i_vec=Evolution.interpret.(H_new.populations[1].beings,p_vec,Ref(H_new))

# test =[]
# for i in 1:186
#     temp_vec=[]
#     for j in 1:5
#         temp_vec=vcat(temp_vec,i_vec[i][j][2])
#     end
#     test=vcat(test,[temp_vec])
# end