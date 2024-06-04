echo `date`
julia --project ./src/wt_perturbed.jl 1 &
julia --project ./src/wt_perturbed.jl 2 &
julia --project ./src/wt_perturbed.jl 3 &
julia --project ./src/wt_perturbed.jl 4 &
julia --project ./src/wt_perturbed.jl 5 &
julia --project ./src/wt_perturbed.jl 6 &
julia --project ./src/wt_perturbed.jl 7 &
julia --project ./src/wt_perturbed.jl 8 &
julia --project ./src/wt_perturbed.jl 9 &
julia --project ./src/wt_perturbed.jl 10 &
julia --project ./src/wt_perturbed.jl 11 &
julia --project ./src/wt_perturbed.jl 12 &
julia --project ./src/wt_perturbed.jl 13 &
julia --project ./src/wt_perturbed.jl 14 &
julia --project ./src/wt_perturbed.jl 15 &
wait # do not return before background tasks are complete
echo `date`







# echo `date`
# julia --project ./src/wt_perturbed.jl 1.0 &
# julia --project ./src/wt_perturbed.jl 1.5 &
# julia --project ./src/wt_perturbed.jl 2.0 &
# julia --project ./src/wt_perturbed.jl 2.5 &
# julia --project ./src/wt_perturbed.jl 3.0 &
# julia --project ./src/wt_perturbed.jl 3.5 &
# julia --project ./src/wt_perturbed.jl 4.0 &
# julia --project ./src/wt_perturbed.jl 4.5 &
# julia --project ./src/wt_perturbed.jl 5.0 &
# wait # do not return before background tasks are complete
# echo `date`