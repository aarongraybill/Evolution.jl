function create_base(seed=1)
        Evolution.Random.seed!(seed)

        b_vec=[Evolution.base_being("p$i") for i in 1:100];

        pop=Evolution.Population(b_vec);
        
        H = Evolution.Habitat([pop],Evolution.Enclosure());
        return H
end