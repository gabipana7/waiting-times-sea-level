using CSV, DataFrames, Dates
using CairoMakie

# variable = "sea_level"
# period = "1905_2023"
# period = "1939_2023"


variable = "wind_speed"
period = "1951_2024"

results = CSV.read("./$(variable)/results/$(period)/results_$(variable).csv", DataFrame)

set_theme!(Theme(fonts=(; regular="CMU Serif")))
cmap = :thermometer
fig = Figure(resolution = (1000, 400), font= "CMU Serif") 
xlabels = [L"\delta\,\text{[km/h]}",L"\delta\,\text{[km/h]}", ""]
ylabels = [ L"\alpha", L"x_{min}", ""]
ax = [Axis(fig[1, i], xlabel = xlabels[i], ylabel = ylabels[i], ylabelsize = 26,
    xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10) for i in 1:2]
scatter!(ax[1],results.delta, results.alpha; color = results.KS, colormap = cmap,
    markersize = 13, marker = :circle, strokewidth = 0)
err = errorbars!(ax[1], results.delta, results.alpha, results.sigma; color = results.KS, colormap = cmap, 
whiskerwidth = 4)
xmin_scat = scatter!(ax[2],results.delta, results.xmin; color = results.KS, colormap = cmap,
    markersize = 13, marker = :circle, strokewidth = 0)
cbar = Colorbar(fig[1,3], xmin_scat, vertical = true, label="KS", flipaxis=false)
# Label(fig[1, 1, Top()], variable, fontsize=16,
#     padding=(0, 0, 15, 0))
save("./$(variable)/results/$(period)/wt_$(variable)_par_dep.png", fig, px_per_unit=5)

fig


# variable = "sea_level"
# trial = "5"

# results = CSV.read("./results_perturbed/trial_$(trial)/results_$(variable)_perturbed.csv", DataFrame)

# set_theme!(Theme(fonts=(; regular="CMU Serif")))
# cmap = :thermometer
# fig = Figure(resolution = (1000, 400), font= "CMU Serif") 
# xlabels = [L"\delta\,\text{[cm]}",L"\delta\,\text{[cm]}", ""]
# ylabels = [ L"\alpha", L"x_{min}", ""]
# ax = [Axis(fig[1, i], xlabel = xlabels[i], ylabel = ylabels[i], ylabelsize = 26,
#     xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
#     xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10) for i in 1:2]
# scatter!(ax[1],results.delta, results.alpha; color = results.KS, colormap = cmap,
#     markersize = 13, marker = :circle, strokewidth = 0)
# err = errorbars!(ax[1], results.delta, results.alpha, results.sigma; color = results.KS, colormap = cmap, 
# whiskerwidth = 4)
# xmin_scat = scatter!(ax[2],results.delta, results.xmin; color = results.KS, colormap = cmap,
#     markersize = 13, marker = :circle, strokewidth = 0)
# cbar = Colorbar(fig[1,3], xmin_scat, vertical = true, label="KS", flipaxis=false)
# # Label(fig[1, 1, Top()], variable, fontsize=16,
# #     padding=(0, 0, 15, 0))
# save("./results_perturbed/trial_$(trial)/wt_$(variable)_par_dep.png", fig, px_per_unit=5)

# fig