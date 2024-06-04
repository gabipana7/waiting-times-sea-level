using CSV, DataFrames, Dates
using PyCall
using CairoMakie
using StatsBase

@pyimport powerlaw as powlaw
so = pyimport("scipy.optimize")

fit_powerlaw = pyeval("""lambda fit: lambda a, b, c: fit(a, b, c)""")
@. powerlaw_ccdf(x, α, b) = b*((x)^(-α))



data_in_question = "hourly_sea_level"
datetime = "datetime"
variable = "sea_level"

mkpath("./results_article_plots/")



delta = 10
period = "1905_2023"
wt_df = CSV.read("./wt_$(period)/wt_$(variable)_delta_$(delta).csv", DataFrame)
wt = wt_df[!,:wt];


################################################################################################################################################################
################################################################################################################################################################
# nb = 1000

# h = StatsBase.fit(Histogram, wt, nbins=nb)

# y = h.weights

# x_edges = collect(h.edges[1])
# x = [(x_edges[i+1] + x_edges[i])/2 for i in 1:length(x_edges)-1];

# to_del = []
# for i in eachindex(y)
#     if y[i] == 0
#         push!(to_del, i)
#     end
# end

# deleteat!(y, to_del)
# deleteat!(x, to_del);

# x = x[2:end]
# y = y[2:end]


# popt_powerlaw, pcov_powerlaw = so.curve_fit(fit_powerlaw((x, α, b)->powerlaw_ccdf(x, α, b)), x, y, bounds=(0, Inf), maxfev=3000)

# alpha_bin = round(popt_powerlaw[1], digits=4)
# b_bin = round(popt_powerlaw[2], digits=4)
# println("alpha= ", popt_powerlaw[1],"b= ", popt_powerlaw[2])



set_theme!(Theme(fonts=(; regular="CMU Serif")))

markers=[:utriangle, :diamond, :circle, :rect]
colors=[:lightblue, :lightgreen, :lightsalmon, :orchid]
line_colors=[:midnightblue, :green, :darkred, :purple]
i=4

########################################### ALL
# CCDF of all data scattered 
fig = Figure(resolution = (700, 600), font= "CMU Serif") 
ax1 = Axis(fig[1,1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"P_k", xscale=log10, yscale=log10, ylabelsize = 28,
    xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
    
# # CCDF of truncated data (fitted), the plot, (re-normed)
ax2 = Axis(fig, bbox = BBox(150,400,115,330), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
    xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)
    
# Powerlaw fit
fit = powlaw.Fit(wt);
# Round up the data
alpha = round(fit.alpha, digits=2)
sigma = round(fit.sigma, digits=2)
xmin = round(fit.xmin, digits=4)
KS = round(fit.power_law.KS(data=wt), digits=3)


x_ccdf, y_ccdf = fit.ccdf()
########################################### ALL
x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)

sc1 = scatter!(ax1, x_ccdf_original_data, y_ccdf_original_data,
color=(colors[1], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)


# The fit (from theoretical power_law)
fit_power_law = fit.power_law.plot_ccdf()[:lines][1]
x_powlaw, y_powlaw = fit_power_law[:get_xdata](), fit_power_law[:get_ydata]()

# Fit through all data
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
axislegend(ax1, [sc1], [L"\delta=%$(delta) \, \mathrm{[cm]}"], L"\text{MLE}", position = :rt, backgroundcolor = (:grey90, 0.25), labelsize=20, titlesize=20);

axislegend(ax1, position = :lt, backgroundcolor = (:grey90, 0.25), labelsize=18);

ylims!(ax1, 10^(-6.5), 10^(1))


# ax3 = Axis(fig[1,1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"P_k",  ylabelsize = 28, xscale=log10, yscale=log10,
#     xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
#     xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
    
# sc3 = scatter!(ax3, x, y,
#     color=(colors[i], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)

# lines!(ax3, x[1:60], powerlaw_ccdf(x,popt_powerlaw[1],popt_powerlaw[2])[1:60], label= L"\alpha=%$(alpha_bin)", #,\, b=%$(b_bin)",
#     color=(line_colors[i], 0.7), linewidth=3)


# axislegend(ax3, [sc3], [L"\delta=%$(delta) \, \mathrm{[cm]}"], position = :rt, backgroundcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

# axislegend(ax3, position = :lb, backgroundcolor = (:grey90, 0.25), labelsize=18);

ax1.xticks = ([10^(0),10^(1),10^(2),10^(3) ,10^(4), 10^(5), 10^(6)],["1", L"10^{1}", L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}", L"10^{6}"])
ax1.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ],[L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", "1"])

ax2.xticks = ([10^(2), 10^(3), 10^(4), 10^(5)], [L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}"])
ax2.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ], [L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", L"1"])

save("./results_article_plots/wt_$(variable)_delta_$(delta)_bin_mle.png", fig, px_per_unit=7)

fig


################################################################################################################################################################
################################################################################################################################################################
# Parameter dependence
results = CSV.read("./results/$(period)/results_$(variable).csv", DataFrame)

set_theme!(Theme(fonts=(; regular="CMU Serif")))
cmap = :thermometer
fig = Figure(resolution = (1000, 400), font= "CMU Serif") ## probably you need to install this font in your system
xlabels = [L"\delta\,\text{[cm]}",L"\delta\,\text{[cm]}", ""]
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
save("./results_article_plots/wt_$(variable)_par_dep.png", fig, px_per_unit=7)

fig


################################################################################################################################################################
################################################################################################################################################################
# BEST FITS
set_theme!(Theme(fonts=(; regular="CMU Serif")))
fig = Figure(resolution = (800, 700), font= "CMU Serif") 
ax1 = Axis(fig[1, 1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"P_k", xscale=log10, yscale=log10, ylabelsize = 26,
    xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10,xticklabelsize=22, yticklabelsize=22)

########################################## TRUNCATED
ax2 = Axis(fig, bbox = BBox(145,395,106,320), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)

markers=[:utriangle, :diamond, :circle]
colors=[:lightblue, :lightgreen, :lightsalmon]
line_colors=[:midnightblue, :green, :darkred]


sc1 = Array{Any,1}(undef,3)

multiplier = [0.1, 1.0, 10]
deltas = [5, 10, 15]
for i in eachindex(deltas)
    
    delta = deltas[i]
    wt_df = CSV.read("./wt_$(period)/wt_$(variable)_delta_$(delta).csv", DataFrame)
    wt = wt_df[!,:wt];

    # Powerlaw fit
    fit = powlaw.Fit(wt);
    # Round up the data
    alpha = round(fit.alpha, digits=2)
    sigma = round(fit.sigma, digits=2)
    xmin = round(fit.xmin, digits=4)
    KS = round(fit.power_law.KS(data=wt), digits=3)


    x_ccdf, y_ccdf = fit.ccdf()
    ########################################### ALL
    x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)

    sc1[i] = scatter!(ax1, multiplier[i] .* x_ccdf_original_data, y_ccdf_original_data,
    color=(colors[i], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)


    # The fit (from theoretical power_law)
    fit_power_law = fit.power_law.plot_ccdf()[:lines][1]
    x_powlaw, y_powlaw = fit_power_law[:get_xdata](), fit_power_law[:get_ydata]()

    # Fit through all data
    # Must shift the y values from the theoretical powerlaw by the values of y of original data, but cut to the length of truncated data
    ln1 = lines!(ax1, multiplier[i] .* x_powlaw, y_ccdf_original_data[end-length(x_ccdf)] .* y_powlaw, label = L"\alpha=%$(alpha)\pm %$(sigma),\, x_{\mathrm{min}}=%$(xmin),\, \mathrm{KS}=%$(KS)",
    color=line_colors[i], linewidth=2.5) 


    ########################################### TRUNCATED
    sc2 = scatter!(ax2, multiplier[i] .* x_ccdf, y_ccdf,
    color=(colors[i], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=10)


    # Fit through truncated data (re-normed)
    ln2 = lines!(ax2, multiplier[i] .* x_powlaw, y_powlaw,
    color=line_colors[i], linewidth=2.5)
end


# AXIS LEGEND
axislegend(ax1, [sc1[i] for i in eachindex(deltas)], [L"\delta=%$(deltas[i]) \, \mathrm{[cm]}" for i in eachindex(deltas)], position = :rt, backgroundcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

axislegend(ax1, position = :rb, backgroundcolor = (:grey90, 0.25), labelsize=18);

ylims!(ax1, 10^(-7), 10^(0.2))

text!(ax2, "only fitted data\nCCDFs", space = :relative, position = Point2f(0.03, 0.03))



ylims!(ax1, 10^(-7.5), 1.5)
ax1.xticks = ([10^(0),10^(1),10^(2),10^(3) ,10^(4), 10^(5), 10^(6)],["1", L"10^{1}", L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}", L"10^{6}"])
ax1.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ],[L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", "1"])

ax2.xticks = ([10^(2), 10^(3), 10^(4), 10^(5)], [L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}"])
ax2.yticks = ([10^(-3), 10^(-2), 10^(-1), 1 ], [L"10^{-3}", L"10^{-2}", L"10^{-1}", L"1"])

# multipliers text
text!(ax1, L"\times %$(multiplier[1])", space = :relative, position = Point2f(0.32, 0.63), fontsize=16)
text!(ax1, L"\times %$(multiplier[3])", space = :relative, position = Point2f(0.7, 0.7), fontsize=16)

text!(ax2, L"\times %$(multiplier[1])", space = :relative, position = Point2f(0.13, 0.5), fontsize=16)
text!(ax2, L"\times %$(multiplier[3])", space = :relative, position = Point2f(0.57, 0.8), fontsize=16)

    
save("./results_article_plots/wt_$(variable)_best_fits.png", fig, px_per_unit=7)
fig



################################################################################################################################################################
################################################################################################################################################################
function rescale_data(data)
    r_min = minimum(data)
    r_max = maximum(data)
    t_min = 0.00001
    t_max = 1.0

    new_data = [(((m - r_min)/(r_max - r_min))*(t_max-t_min)+t_min) for m in data]
    return new_data
end



deltas = [50, 100, 150, 200]

set_theme!(Theme(fonts=(; regular="CMU Serif")))

markers=[:utriangle, :diamond, :circle, :rect]
colors=[:lightblue, :lightgreen, :lightsalmon, :orchid]
line_colors=[:midnightblue, :green, :darkred, :purple]

########################################### ALL
# CCDF of all data scattered 
fig = Figure(resolution = (700, 600), font= "CMU Serif") 
ax1 = Axis(fig[1,1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"P_k", ylabelsize = 28, #xscale=log10, yscale=log10,   
    xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
    
sc = Array{Any,1}(undef,length(deltas))

for i in eachindex(deltas)
    delta = deltas[i]

    wt_df = CSV.read("./wt_$(period)/wt_$(variable)_delta_$(delta).csv", DataFrame)
    wt = wt_df[!,:wt];

    x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)
    # x_ccdf_original_data = x_ccdf_original_data ./ maximum(x_ccdf_original_data)
    # y_ccdf_original_data = rescale_data(y_ccdf_original_data)

    #############################################################################################################################################################
    # THE PLOTS 

    sc[i] = scatter!(ax1, x_ccdf_original_data, y_ccdf_original_data,
    color=(colors[i], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)

    # lines!(ax1, x_ccdf_original_data, tsallis_ccdf(x_ccdf_original_data, popt_tsallis[1], popt_tsallis[2], popt_tsallis[3]), label= L"\alpha=%$(alpha),\, \lambda=%$(lambda),\, c=%$(c)",
    # color=(line_colors[i], 0.7), linewidth=3)

end

# AXIS LEGEND
axislegend(ax1, [sc[i] for i in eachindex(deltas)], 
[L"\delta=%$(deltas[i])\, \mathrm{[cm]}" for i in eachindex(deltas)],
position = :rt, backgroundcolor = (:grey90, 0.25), labelsize=22, titlesize=22);


save("./results_article_plots/wt_$(variable)_big_deltas_overlayed_norm_norm.png", fig, px_per_unit=7)

fig