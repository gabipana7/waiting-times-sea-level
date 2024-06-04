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
multiplier = [0.1, 1.0, 10]
deltas = [5, 10, 15]


# data_in_question = "hourly_wind_speed"
# datetime = "datetime"
# variable = "wind_speed"
# multiplier = [0.1, 1.0, 10]
# deltas = [3, 4, 5]

# mkpath("./results_article_plots/$(variable)/")


period = "1951_2024"


################################################################################################################################################################
################################################################################################################################################################
# BEST FITS
set_theme!(Theme(fonts=(; regular="CMU Serif")))
fig = Figure(resolution = (800, 700), font= "CMU Serif") 
ax1 = Axis(fig[1, 1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"F_k", xscale=log10, yscale=log10, ylabelsize = 26,
    xlabelsize = 22, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
    xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10,xticklabelsize=22, yticklabelsize=22)

########################################## TRUNCATED
ax2 = Axis(fig, bbox = BBox(145,395,106,320), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)

markers=[:utriangle, :diamond, :circle]
colors=[:lightblue, :lightgreen, :lightsalmon]
line_colors=[:midnightblue, :green, :darkred]


sc1 = Array{Any,1}(undef,3)
sc12 = Array{Any,1}(undef,3)


for i in eachindex(deltas)
    
    delta = deltas[i]
    wt_df = CSV.read("./$(variable)/wt_$(period)/wt_$(variable)_delta_$(delta).csv", DataFrame)
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
axislegend(ax1, [sc1[i] for i in eachindex(deltas)], [L"\delta=%$(deltas[i]) \, \mathrm{[km/h]}" for i in eachindex(deltas)], position = :rt, bgcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

axislegend(ax1, position = :rb, bgcolor = (:grey90, 0.25), labelsize=18);

# axislegend(ax1, [sc12[1]], [L"\text{historical waiting times}"], position = :lc, bgcolor = (:grey90, 0.25), labelsize=18, titlesize=18);


ylims!(ax1, 10^(-7), 10^(0.2))

text!(ax2, "only fitted data\nCCDFs", space = :relative, position = Point2f(0.03, 0.03))



ylims!(ax1, 10^(-7.5), 1.5)
ax1.xticks = ([10^(0),10^(1),10^(2),10^(3) ,10^(4), 10^(5), 10^(6)],["1", L"10^{1}", L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}", L"10^{6}"])
ax1.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ],[L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", "1"])

ax2.xticks = ([10^(2), 10^(3), 10^(4), 10^(5), 10^(6)], [L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}", L"10^{6}"])
ax2.yticks = ([10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ], [L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", L"1"])

# multipliers text
text!(ax1, L"\times %$(multiplier[1])", space = :relative, position = Point2f(0.32, 0.63), fontsize=16)
text!(ax1, L"\times %$(multiplier[3])", space = :relative, position = Point2f(0.7, 0.7), fontsize=16)

text!(ax2, L"\times %$(multiplier[1])", space = :relative, position = Point2f(0.13, 0.5), fontsize=16)
text!(ax2, L"\times %$(multiplier[3])", space = :relative, position = Point2f(0.57, 0.8), fontsize=16)

    
save("./$(variable)/results/$(period)/wt_$(variable)_best_fits.png", fig, px_per_unit=7)
fig













# delta = 10
# period = "1905_2023"
# wt_df = CSV.read("./wt_$(period)/wt_$(variable)_delta_$(delta).csv", DataFrame)
# wt = wt_df[!,:wt];


# period_historical = "1905_1938"
# wt_df_historical = CSV.read("./wt_$(period_historical)/wt_$(variable)_delta_$(delta).csv", DataFrame)
# wt_historical = wt_df_historical[!,:wt];



# set_theme!(Theme(fonts=(; regular="CMU Serif")))

# markers=[:utriangle, :diamond, :circle, :rect]
# colors=[:lightblue, :lightgreen, :lightsalmon, :orchid]
# line_colors=[:midnightblue, :green, :darkred, :purple]
# i=4

# ########################################### ALL
# # CCDF of all data scattered 
# fig = Figure(resolution = (700, 600), font= "CMU Serif") 
# ax1 = Axis(fig[1,1], xlabel = L"k\, \mathrm{[hours]}", ylabel = L"P_k", xscale=log10, yscale=log10, ylabelsize = 28,
#     xlabelsize = 28, xgridstyle = :dash, ygridstyle = :dash, xtickalign = 1,
#     xticksize = 5, ytickalign = 1, yticksize = 5 , xlabelpadding = 10, ylabelpadding = 10, xticklabelsize=22, yticklabelsize=22)
    
# # # CCDF of truncated data (fitted), the plot, (re-normed)
# ax2 = Axis(fig, bbox = BBox(150,400,115,330), xscale=log10, yscale=log10, xgridvisible = false, ygridvisible = false, xtickalign = 1,
#     xticksize = 4, ytickalign = 1, yticksize = 4, xticklabelsize=16, yticklabelsize=16, backgroundcolor=:white)
    
# # Powerlaw fit
# fit = powlaw.Fit(wt);
# # Round up the data
# alpha = round(fit.alpha, digits=2)
# sigma = round(fit.sigma, digits=2)
# xmin = round(fit.xmin, digits=4)
# KS = round(fit.power_law.KS(data=wt), digits=3)


# x_ccdf, y_ccdf = fit.ccdf()
# ########################################### ALL
# x_ccdf_original_data, y_ccdf_original_data = powlaw.ccdf(wt)
# x_historical, y_historical = powlaw.ccdf(wt_historical)




# sc1 = scatter!(ax1, x_ccdf_original_data, y_ccdf_original_data,
# color=(colors[1], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=12)


# sc12 = scatter!(ax1, x_historical, y_historical, color=(:gray, 0.6), marker=:circle, markersize=4)


# # The fit (from theoretical power_law)
# fit_power_law = fit.power_law.plot_ccdf()[:lines][1]
# x_powlaw, y_powlaw = fit_power_law[:get_xdata](), fit_power_law[:get_ydata]()

# # Fit through all data
# # Must shift the y values from the theoretical powerlaw by the values of y of original data, but cut to the length of truncated data
# ln1 = lines!(ax1, x_powlaw, y_ccdf_original_data[end-length(x_ccdf)] .* y_powlaw, label = L"\alpha=%$(alpha)\pm %$(sigma),\, x_{\mathrm{min}}=%$(xmin),\, \mathrm{KS}=%$(KS)",
# color=line_colors[1], linewidth=2.5) 


# ########################################### TRUNCATED
# sc2 = scatter!(ax2, x_ccdf, y_ccdf,
# color=(colors[1], 0.75), strokewidth=0.05, strokecolor=(line_colors[i], 0.8), marker=markers[i], markersize=10)


# # Fit through truncated data (re-normed)
# ln2 = lines!(ax2, x_powlaw, y_powlaw,
# color=line_colors[1], linewidth=2.5)


# # AXIS LEGEND
# axislegend(ax1, [sc1], [L"\delta=%$(delta) \, \mathrm{[cm]}"], position = :rt, bgcolor = (:grey90, 0.25), labelsize=18, titlesize=18);

# axislegend(ax1, position = :lt, bgcolor = (:grey90, 0.25), labelsize=18);

# ylims!(ax1, 10^(-6.5), 10^(1))


# ax1.xticks = ([10^(0),10^(1),10^(2),10^(3) ,10^(4), 10^(5), 10^(6)],["1", L"10^{1}", L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}", L"10^{6}"])
# ax1.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ],[L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", "1"])

# ax2.xticks = ([10^(2), 10^(3), 10^(4), 10^(5)], [L"10^{2}", L"10^{3}", L"10^{4}", L"10^{5}"])
# ax2.yticks = ([10^(-6), 10^(-5), 10^(-4), 10^(-3), 10^(-2), 10^(-1), 1 ], [L"10^{-6}", L"10^{-5}", L"10^{-4}", L"10^{-3}", L"10^{-2}", L"10^{-1}", L"1"])

# # save("./results_article_plots/wt_$(variable)_delta_$(delta)_bin_mle.png", fig, px_per_unit=7)

# fig
