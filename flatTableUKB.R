## Extract UK Biobank data using the duckdb R package to create a flat table for analysis
# ------------------------------------
## Install the package and load other libraries
local({r <- getOption("repos")
       r["CRAN"] <- "https://www.stats.bris.ac.uk/R/" 
       options(repos=r)
})

.libPaths( "/home/s1211670/R" )

# install.packages("remotes")
# install.packages("dbplyr")
# remotes::install_version('duckdb', '0.7.1-1')

library(duckdb)
library(dplyr)
library(stringr)
library(tidyverse)

# ------------------------------------
## Connect to the database
## (for tips on creating a symlink see: https://github.com/AmeliaES/SQL_UKBiobank_duckDB)
con <- DBI::dbConnect(duckdb::duckdb(),
  dbdir="/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb",
  read_only=TRUE)

Dictionary <- tbl(con, 'Dictionary')
  
# ------------------------------------
## Create a table with the following variables from the baseline assessment
## "Age_when_attended_assessment_centre"
## "Sex"
## "UK_Biobank_assessment_centre"
## "Month_of_attending_assessment_centre"
## "BMI"
## "Smoking_status"
## "Alcohol_drinker_status"
## "Townsend_deprivation_index_at_recruitment"
## "CRP"
## MHQ depression items (https://github.com/ccbs-stradl/coding_club/blob/main/Sessions/2023_04_05_ukb_duckdb.md#finding-mhq-depression-items)


## Identify which tables each of the above come from
## make a dataframe with Table and the Field ID for variables of interest (some covariates for now)

fields_df <- list(Dictionary |> 
  filter(str_detect(Field, "Age." ) & str_detect(Field, ".assessment." )) |>
  select(c(Table, FieldID)) |> collect(),

Dictionary |> 
  filter(Field == "Sex" ) |>
  select(c(Table, FieldID)) |> collect(),

Dictionary |> 
  filter(str_detect(Field, "UK Biobank assessment centre")) |>
  select(c(Table, FieldID)) |> collect(),

Dictionary |> 
  filter(str_detect(Field, "Month of attending assessment centre")) |>
  select(c(Table, FieldID)) |> collect(),

Dictionary |> 
  filter(str_detect(Field, "Body mass index")) |>
  select(c(Table, FieldID)) |> collect(),
# https://biobank.ndph.ox.ac.uk/showcase/search.cgi?wot=0&srch=BMI&sta0=on&sta1=on&sta2=on&sta3=on&sta4=on&str0=on&str3=on&fit0=on&fit10=on&fit20=on&fit30=on&fvt11=on&fvt21=on&fvt22=on&fvt31=on&fvt41=on&fvt51=on&fvt61=on&fvt101=on&yfirst=2000&ylast=2023
# Two field ids for BMI

Dictionary |> 
  filter(str_detect(Field, "Smoking status")) |>
  select(c(Table, FieldID)) |> collect())  %>% do.call(rbind, .)



# Dictionary |> 
#   filter(regexp_matches(Field, "smoking status", "i")) |>
#  pull(Field)
# # See error at bottom of script
# # look at how regex is done in duckdb R package and dplyr



# Dictionary |> 
#   filter(str_detect(Field, regex("smoking status", ignore_case = T))) |>
#   pull(Field) |>
#   show_query()

#   Dictionary |> 
#   filter(str_detect(Field, "Smoking status")) |>
#   select(c(Table, FieldID)) |>
#   show_query()



## ------------------------------------
## Make new variables for the tables we need to extract from
tables <- unique(fields_df$Table)
for(t in tables){
  assign(t, tbl(con, t))
}
## check
ls()
rm(t)

## ------------------------------------
## Extract the variables for each of the above from the baseline assessment, 

flat_table_df <- lapply(tables, function(t){
tmp <- fields_df |>
  filter(Table %in% t) |>
  pull(FieldID) 
tmp <- paste0("f.", tmp, ".0.0")

eval(as.symbol(t)) |>
  select(c(f.eid, all_of(tmp))) 

}) %>% reduce(., full_join, by = "f.eid")

head(flat_table_df)

# Alternative: Join all the tables, then select. Might be the same amount of time? But simpler code.

## ------------------------------------
## To do:
## check for array instances (where a variable can have multiple values)
## collect them and pivot, duckdb, depends on variable.
## rename columns to something more informative?? best strategy for this?
## package from ppl at Kings, snake case name, but long...
## save output, best file type .rds or .csv? .csv.gz unless really large.
## Include other variables that might be useful for the group?
## make a package/function that takes field Ids and extracts table they want.
## Standard data cleaning methods to apply?
## this is how you get depression diagnosis etc. for this dataset
## view in sql, a virtual table, which does a full join between all the tables.. 


# ------------------------------------
# Weird error:

# > Dictionary |> 
# +   filter(str_detect(Field, regex("smoking status", ignore.case = T))) |>
# +   pull(Field)
# Error in `collect()`:
# ! Failed to collect lazy table.
# Caused by error:
# ! Parser Error: syntax error at or near "AS"
# LINE 3: ...Dictionary"
# WHERE (REGEXP_MATCHES(Field, regex('smoking status', TRUE AS "ignore.case")))
#                                                   ^
# Run `rlang::last_trace()` to see where the error occurred.
# Warning message:
# Named arguments ignored for SQL regex 
# > Dictionary |> 
# +   filter(str_detect(Field, regex("smoking status", ignore_case = T))) |>
# +   pull(Field)
# Error in `collect()`:
# ! Failed to collect lazy table.
# Caused by error:
# ! Parser Error: syntax error at or near "AS"
# LINE 3: ...Dictionary"
# WHERE (REGEXP_MATCHES(Field, regex('smoking status', TRUE AS ignore_case)))
#                                                   ^
# Run `rlang::last_trace()` to see where the error occurred.
# Warning message:
# Named arguments ignored for SQL regex 

# ------------------------------------
