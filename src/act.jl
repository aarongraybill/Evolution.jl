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

function species_cramming(b::Being,H::Habitat;damage=1)
    """Need a function here to count the number of ovelaps"""
    pop_of_interest=H.populations[b.species]
    for (being_id,other) in pop_of_interest.beings
        if other==b
            #do nothing bc that's you
        else
            d=LinearAlgebra.norm(b.position-other.position)
            if d>(other.radius+b.radius)
                #too far, do nothing
            else 
                return true
            end
        end
    end
    return false
end

"""
if a being invests r ∈ [0,1] in reproduction, they can move a total distance of
    step_size*speed*(1-r)

Additionally, step_size says that if an action should take d damage it will now take
d*step_size damage

Assume that it takes 1/step_size periods in a row of contact to die of cramming

regen is fraction of max health regained in  1/step_size steps
"""
function act!(H::Habitat;step_size::Float64=.25,speed::Float64=1.0,regen=.5,max_health=1)
    reproduction_list = Set{Being}([])
    kill_list = Set{Being}([])
    r = regen*max_health*step_size
    cram_dam = step_size*max_health + r 
    for (species,pop) in H.populations
        for (being_id,being) in pop.beings
            p=perceive(being,H)
            t=think(being,p)

            #@show t[reproduce_ind][1][2]
            rep_effort = σ(t["out_reproduce"])
            rep_roll = 1-rand()
            pivot_effort = σ(t["out_pivot"])*2π
            step_effort = step_size*(1-rep_effort)*speed

            being.facing = rotate(being.facing,pivot_effort)
            #being.facing = being.facing/sqrt(being.facing⋅being.facing) # normalize
            being.position = being.position + being.facing*step_effort*step_size
            #println(being.being_id)
            being.age=being.age+1
            ΔH = (-species_cramming(being,H)*cram_dam+r)
            being.health=min(being.health+ΔH,max_health)
            if rep_effort*step_size > rep_roll
                push!(reproduction_list,being)
            end
            if hitting_wall(being,H) || being.health<0
                push!(kill_list,being)
            end
        end
    end
  return reproduction_list, kill_list
end

function iterate!(H::Habitat)
    rep_list, kill_list = Evolution.act!(H);
    for death in kill_list
        kill!(death,H)
    end
    for birth ∈ rep_list
        H = reproduce!(birth,H)
    end
    #return H_new
end