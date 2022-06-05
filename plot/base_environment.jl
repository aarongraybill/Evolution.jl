function create_base(seed=1)
        Evolution.Random.seed!(seed)
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
            view_angle=π/2,
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
                view_angle=π/2,
                n_rays=2,
                brain=Evolution.base_brain(b,1,true),
                health=1.0,
                n_children=0
        ) for i in 1:100];

        pop=Evolution.Population(nothing,b_vec);

        H = Evolution.Habitat([pop],Evolution.Enclosure());
        return H
end