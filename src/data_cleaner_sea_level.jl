using CSV, DataFrames, Dates

data_in_question = "hourly_sea_level_original"

path = "./data/"
filepath = path * data_in_question * ".csv"
df = CSV.read(filepath, DataFrame);
dropmissing!(df);

rename!(df, ["SEA LEVEL HEIGHT(cm above TG zero)", "FLAG(0=observed/1=approximate/2=estimated by interpolation/5=reconstructed from nearby station)"] .=>  
            ["sea_level", "flag"])

transform!(df, ["DATE", "TIME(UTC+1)"]  => ByRow((A, B) -> string(A, " ", B)) => "datetime")
select!(df, Not(["DATE", "TIME(UTC+1)"]));

df = df[df.flag .== 0,:] 
dateformat = dateformat"dd/mm/yyyy HH:MM:SS"
df.datetime = DateTime.(df.datetime, dateformat)
df
select!(df, Not([:flag]))
describe(df)

CSV.write("./data/hourly_sea_level.csv", df, delim=",")