using CSV, DataFrames, Dates

# data_in_question = "hourly_sea_level"

function read_data(data_in_question::String)
    path = "./data/"
    filepath = path * data_in_question * ".csv"
    df = CSV.read(filepath, DataFrame);

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


data_in_question = "hourly_wind_speed"

df = read_data(data_in_question)

# df = df[(df.datetime .< DateTime(1939,01,01,0,0,0)),:]

delta = parse(Int64, ARGS[1])
# delta = 100
datetime = "datetime"
variable = "wind_speed"


start_year = Dates.format(minimum(df.datetime), "yyyy")
end_year = Dates.format(maximum(df.datetime), "yyyy")
period =  start_year * "_" * end_year

mkpath("./$(variable)/wt_$(period)/")

wt = waiting_times(df, delta, datetime, variable)

wt_dataframe = DataFrame([wt], ["wt"])
CSV.write("./$(variable)/wt_$(period)/wt_$(variable)_delta_$(delta).csv", wt_dataframe, delim=",")


