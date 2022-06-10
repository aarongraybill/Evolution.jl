using PlotlyJS
using Evolution
using DataFrames

include("base_environment.jl");
H=create_base();
N=100

# trace = scatter(
#                 mode="lines",
#                 #line_width=1.5,
#                 line_color="RoyalBlue",
#                 fill="toself",
#                 marker=attr(size=10))

n_frames = N

# function create_shapes(coords::Vector{Vector{Float64}},radius=.5)
#     r=radius
#     x_vec = []
#     y_vec=[]
#     for i in 1:length(coords)
#         x, y = coords[i]
#         x_vec=vcat(x_vec,[x+r,x+r,x-r,x-r,x+r,nothing])
#         y_vec=vcat(y_vec,[y+r,y-r,y-r,y+r,y+r,nothing])
#     end
#     return x_vec,y_vec
# end

# frames  = Vector{PlotlyFrame}(undef, n_frames)

out_df = DataFrame(iter = Int64[],being_id = String[],position_x = Float64[],position_y=Float64[],age=Int64[])
for k in 1:n_frames
    out_rows = DataFrame([(k,b.being_id,b.position[1],b.position[2],b.age) for b in values(H.populations["skunk"].beings)])
    rename!(out_rows,names(out_df))
    append!(out_df,out_rows)
    println("$k/$N, population $(length(H.populations["skunk"].beings))")
    #positions = [x.position for x in values(H.populations["skunk"].beings)]
    #x_coords,y_coords = create_shapes(positions)
    # frames[k] = frame(data=[attr(x=x_coords, #update x and y
    #                              y=y_coords,
    #                              )],
    #                   layout=attr(title_text="Test frame $k"), #update title
    #                   name="fr$k", #frame name; it is passed to slider 
    #                   traces=[0] # this means that the above data update the first trace (here the unique one) 
                        #)
    Evolution.iterate!(H)
end    

using CSV
CSV.write("OutputData.csv", out_df)

# updatemenus = [attr(type="buttons", 
#                     active=0,
#                     y=1,  #(x,y) button position 
#                     x=1.1,
#                     buttons=[attr(label="Play",
#                                   method="animate",
#                                   args=[nothing,
#                                         attr(frame=attr(duration=5, 
#                                                         redraw=true),
#                                              transition=attr(duration=0),
#                                              fromcurrent=true,
#                                              mode="immediate"
#                                                         )])])
#     ];


# sliders = [attr(active=0, 
#                 minorticklen=0,
#                 steps=[attr(label="f$k",
#                             method="animate",
#                             args=[["fr$k"], # match the frame[:name]
#                                   attr(mode="immediate",
#                                        transition=attr(duration=0),
#                                        frame=attr(duration=5, 
#                                                   redraw=true))
#                                  ]) for k in 1:n_frames ]
#              )];    

# layout = Layout(
#     title_text="Test", title_x=0.5,
#     width=700, height=450,
#     xaxis_range=[-100.1, 100.1], 
#     yaxis_range=[-100.1, 100.1],
#     updatemenus=updatemenus,
#     sliders=sliders
#     )
    
# fig =Plot(trace,layout, frames)
# display(fig)