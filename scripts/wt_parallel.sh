echo `date`
# julia --project ./src/wt.jl 1 &
julia --project ./src/wt.jl 2 &
julia --project ./src/wt.jl 3 &
julia --project ./src/wt.jl 4 &
julia --project ./src/wt.jl 5 &
julia --project ./src/wt.jl 6 &
julia --project ./src/wt.jl 7 &
julia --project ./src/wt.jl 8 &
julia --project ./src/wt.jl 9 &
julia --project ./src/wt.jl 10 &
julia --project ./src/wt.jl 11 &
julia --project ./src/wt.jl 12 &
julia --project ./src/wt.jl 13 &
julia --project ./src/wt.jl 14 &
julia --project ./src/wt.jl 15 &
julia --project ./src/wt.jl 20 &
julia --project ./src/wt.jl 30 &
julia --project ./src/wt.jl 40 &
julia --project ./src/wt.jl 50 &
julia --project ./src/wt.jl 100 &
wait # do not return before background tasks are complete
echo `date`