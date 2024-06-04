using CSV, DataFrames, Dates
using PyCall
using CairoMakie

@pyimport powerlaw as powlaw
so = pyimport("scipy.optimize")


wt_alpha = []
wt_sigma = []
wt_xmin = []
wt_KS = []

variable = "sea_level"
trial = "5"

deltas = collect(1:15)
for delta in deltas

    wt_df = CSV.read("./wt_perturbed/trial_$(trial)/wt_$(variable)_delta_$(delta).csv", DataFrame)
    wt = wt_df[!,:wt]

    mkpath("./results_perturbed/trial_$(trial)/")


    set_theme!(Theme(fonts=(; regular="CMU Serif")))

    markers=[:utriangle, :circle]
    colors=[:lightblue, :lightgreen]
    line_colors=[:midnightblue, :green]

    ########################################### ALL
    # CCDF of all data scattered 
    fig = Figure(resolution = (700, 600), font= "CMU Serif") 
    ax1 = Axis(fig[1,1], xlabel = L"hours", ylabel = L"P", xscale=log10, yscale=log10, ylabelsize = 28,
        xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
        xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
        
    # # CCDF of truncated data (fitted), the plot, (re-normed)
    ax2 = Axis(fig, bbox = BBox(150,400,116,330), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
        xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)

    # sc1 = Array{Any,1}(undef,1)

    #############################################################################################################################################################
    #############################################################################################################################################################
    # THE PLOTS 
    # CCDF of truncated 

    i=1
    # data (fitted), x and y values
    # Powerlaw fit
    fit = powlaw.Fit(wt);
    alpha = fit.alpha
    xmin = fit.xmin
    sigma = fit.sigma
    KS = fit.power_law.KS(data=wt)

    push!(wt_alpha, alpha )
    push!(wt_sigma, sigma )
    push!(wt_xmin, xmin )
    push!(wt_KS, KS )

    x_ccdf, y_ccdf = fit.ccdf()

    # The fit (from theoretical power_law)
    fit_power_law = fit.power_law.plot_ccdf()[:lines][1]
    x_powlaw, y_powlaw = fit_power_law[:get_xdata](), fit_power_law[:get_ydata]()

    # Round up the data
    alpha = round(alpha, digits=2)
    sigma = round(sigma, digits=2)
    xmin = round(xmin, digits=4)
    KS = round(KS, digits=3)

    x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)


    sc1 = scatter!(ax1, x_ccdf_original_data, y_ccdf_original_data,
        color=(colors[1], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)

    # Fit through truncated data
    # Must shift the y values from the theoretical powerlaw by the values of y of original data, but cut to the length of truncated data
    ln1 = lines!(ax1, x_powlaw, y_ccdf_original_data[end-length(x_ccdf)] .* y_powlaw, label = L"\alpha=%$(alpha)\pm %$(sigma),\, x_{\mathrm{min}}=%$(xmin),\, \mathrm{KS}=%$(KS)",
        color=line_colors[1], linewidth=2.5) 

    ########################################### TRUNCATED
    sc2 = scatter!(ax2, x_ccdf, y_ccdf,
    color=(colors[1], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=10)

    # Fit through truncated data (re-normed)
    ln2 = lines!(ax2, x_powlaw, y_powlaw,
        color=line_colors[1], linewidth=2.5)
        
        
    # AXIS LEGEND
    axislegend(ax1, [sc1], 
    [L"\delta=%$(delta)"],
    position = :rt, bgcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

    axislegend(ax1, position = :lt, bgcolor = (:grey90, 0.25), labelsize=18);

    ylims!(ax1, 10^(-6), 10^(0.7))

    save("./results_perturbed/trial_$(trial)/wt_$(variable)_delta_$(delta)_perturbed.png", fig, px_per_unit=5)

end

results = DataFrame([deltas, wt_alpha, wt_sigma, wt_xmin, wt_KS], ["delta", "alpha", "sigma", "xmin", "KS"])
CSV.write("./results_perturbed/trial_$(trial)/results_$(variable)_perturbed.csv", results, delim=",", header=true);





# function lomax_process(variable, delta)

#     fit_tsallis = pyeval("""lambda fit: lambda a, b, c, d: fit(a, b, c, d)""")
#     @. tsallis_ccdf(x, α, λ, c) = c*((1+x/(λ))^(-α))

#     wt_df = CSV.read("./wt/wt_$(variable)_delta_$(delta).csv", DataFrame)
#     wt = wt_df[!,:wt]

#     mkpath("./results/$(variable)/")

#     set_theme!(Theme(fonts=(; regular="CMU Serif")))

#     markers=[:utriangle, :circle]
#     colors=[:lightblue, :lightgreen]
#     line_colors=[:midnightblue, :green]

#     ########################################### ALL
#     # CCDF of all data scattered 
#     fig = Figure(resolution = (700, 600), font= "CMU Serif") 
#     ax1 = Axis(fig[1,1], xlabel = L"hours", ylabel = L"P", xscale=log10, yscale=log10, ylabelsize = 28,
#         xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
#         xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
        
#     # # CCDF of truncated data (fitted), the plot, (re-normed)
#     # ax2 = Axis(fig, bbox = BBox(150,400,116,330), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
#     #     xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)

#     # sc1 = Array{Any,1}(undef,1)

#     #############################################################################################################################################################
#     #############################################################################################################################################################
#     # THE PLOTS 
#     # CCDF of truncated 

#     i=1
#     # data (fitted), x and y values

#     x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)

#     popt_tsallis, pcov_tsallis = so.curve_fit(fit_tsallis((x, α, λ, c)->tsallis_ccdf(x, α, λ, c)), x_ccdf_original_data, y_ccdf_original_data, bounds=(0, Inf), maxfev=3000)

#     alpha = round(popt_tsallis[1], digits=4)
#     lambda = round(popt_tsallis[2], digits=4)
#     c = round(popt_tsallis[3], digits=4)
#     println("alpha= ", popt_tsallis[1],"\nlambda= ", popt_tsallis[2], "\nc= ", popt_tsallis[3])

#     sc = scatter!(ax1, x_ccdf_original_data, y_ccdf_original_data,
#     color=(colors[i], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)

#     lines!(ax1, x_ccdf_original_data, tsallis_ccdf(x_ccdf_original_data, popt_tsallis[1], popt_tsallis[2], popt_tsallis[3]), label= L"\alpha=%$(alpha),\, \lambda=%$(lambda),\, c=%$(c)",
#     color=(line_colors[i], 0.7), linewidth=3)
        
#     # AXIS LEGEND
#     axislegend(ax1, [sc], 
#     [L"delta=%$(delta)"],
#     position = :rt, bgcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

#     axislegend(ax1, position = :lb, bgcolor = (:grey90, 0.25), labelsize=18);

#     save("./results/$(variable)/wt_$(variable)_delta_$(delta)_tsallis.png", fig, px_per_unit=5)
# end


# for delta in [60, 70, 80, 90, 100]
#     powerlaw_process("sea-height", delta)
#     lomax_process("sea-height", delta)
# end


# res = powerlaw_process("sea-height", delta)

# function powerlaw_process(variable, delta)
