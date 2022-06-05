""" 
After perceiving, and thinking about what to do, translate thoughts to action
"""
σ(x::Real) = one(x) / (one(x) + exp(-x))

function hitting_wall(b::Being,H::Habitat)
    test = false
    #@show length(H.enclosure.walls)
    for wall ∈ H.enclosure.walls
            c=b.position
            r=b.radius
            o=wall.start
            u=wall.finish-wall.start
            wall_dist = sqrt(u ⋅ u)
            u=u./wall_dist
            v=o-c
            ∇=(u⋅v)^2-((v⋅v)-r^2)
            
            if ∇<0
                test = test || false
            else
                d=-1*(u⋅v)-sqrt(∇)
                if wall_dist>d>0
                    test = return true
                else
                    test = test || false
                end
            end
    end
    return test
end

function species_cramming(b::Being,H::Habitat)
    """Need a function here to count the number of ovelaps"""
    pop_of_interest=findall(x -> x==b.species,[x.species for x in H.populations])
    run_sum = 0.0
    #@show typeof(H.populations[pop_of_interest])
    for other in H.populations[pop_of_interest][1].beings
        d=LinearAlgebra.norm(b.position-other.position)
        if d>(other.radius+b.radius)
            #skip too far
        elseif b ≈ other
            #skip bc same boy
        else
            run_sum = other.health+run_sum
        end
    end
    return run_sum
end

## SHOULD PROBABLY KILL BEFORE REPRODUCE OR ELSE WE HAVE SALMON BEHAVIOR
function act(H_in::Habitat;step_size::Float64=.25)
    H = deepcopy(H_in)
    reproduction_list = Node[]
    kill_list = Node[]
    for pop in H.populations
        for being in pop.beings
            p=perceive(being,H)
            t=think(being,p,H)
            idea_names = [x[1].opt_text for x ∈ t]
            reproduce_ind = findall(x-> x == "reproduce",idea_names) # should be 1
            pivot_ind = findall(x-> x == "pivot",idea_names) # 2
            step_ind = findall(x-> x == "step",idea_names)  # 3 but just in case

            #@show t[reproduce_ind][1][2]
            rep_effort = σ(t[reproduce_ind][1][2])
            rep_roll = 1-rand()
            pivot_effort = σ(t[pivot_ind][1][2])*2π
            step_effort = 2*(σ(t[step_ind][1][2])-.5)

            being.facing = rotate(being.facing,pivot_effort)
            being.facing = being.facing/sqrt(being.facing⋅being.facing) # normalize
            being.position = being.position + being.facing*step_effort*step_size
            #println(being.being_id)
            being.age=being.age+1
            if being.species == "skunk"
                being.health=min(being.health-rep_effort-abs(step_effort)+.5,1)
            end
            if rep_effort > rep_roll
                reproduction_list=vcat(reproduction_list,[deepcopy(being)])
            end
            being.health = being.health-species_cramming(being,H) #damage from cramming
            if hitting_wall(being,H) || being.health<0
                kill_list = vcat(kill_list,[deepcopy(being)])
            end
        end
    end
  return H, reproduction_list, kill_list
end

function iterate(H_in::Habitat)
    H=deepcopy(H_in)
    H_new, rep_list, kill_list = Evolution.act(H);
    for death in kill_list
        H_new = kill(death,H_new)
    end
    for birth ∈ rep_list
        H_new = reproduce(birth,H_new)
    end

    return H_new

end