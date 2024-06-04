using CSV, DataFrames, Dates


function read_data_perturbed(data_in_question::String, trial::String)
    path = "./data_perturbed/"
    filepath = path * data_in_question * "_trial_" * trial * ".csv"
    df = CSV.read(filepath, DataFrame);

    mkpath("./wt_perturbed/trial_$(trial)/")

    return df
end

function waiting_times(df, delta, datetime, variable)
    wtid = []
    for (i,k) in enumerate(df[!,variable])
        first_event = df[!,datetime][i]
        for (j,x) in enumerate(df[i+1:end, variable])
            if x >= (k+delta)
                second_event = df[!,datetime][i+j]
                push!(wtid, Int(Dates.value(second_event - first_event) / 3600000) )
                break
            end
        end
    end
    return wtid
end

trial = "5"

df = read_data_perturbed("hourly_sea_level_perturbed", trial)

# df = df[(df.datetime .> DateTime(2018,1,1,0,0,0)),:]

delta = parse(Int64, ARGS[1])
# delta = 10
datetime = "datetime"
variable = "sea_level"

wt = waiting_times(df, delta, datetime, variable)
wt_dataframe = DataFrame([wt], ["wt"])
CSV.write("./wt_perturbed/trial_$(trial)/wt_$(variable)_delta_$(delta).csv", wt_dataframe, delim=",")