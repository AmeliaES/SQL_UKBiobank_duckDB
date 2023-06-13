### flatTable
# -------------------------------------
### Description
# Extract a flat table from the UKB SQL duckdb database for given field ids

# -------------------------------------
### Useage
# Give the function a vector of fieldIDs and the instance (assessment time point, default is baseline) and it will return a flat table with ID and fieldIDs as columns and each person in a row (ie. wide format). For multiple arrays (ie. where a variable has more than one element, eg. someone might have multiple ICD-10 codes) these are provided as multiple columns

# -------------------------------------
### Arguments
# fieldIDs 
# This is a vector of field IDs in a numeric format.

# instance
# This is the instance (assessment time point):  Initial assessment visit (2006-2010)  = 0, First repeat assessment visit (2012-13) = 1,  Imaging visit (2014+) = 2, First repeat imaging visit (2019+) = 3. Default is 0.

# -------------------------------------
### Value
# A dataframe of a flat table for analysis. Additionally wrangling might be needed to tidy multiple arrays, eg. using the pivot() function.


### Example
# Get data on CRP, age at assessment and ICD-10 codes at the initial baseline assessment
# flatTable(c(30710, 21003, 41270))

# Get data on CRP, age at assessment and ICD-10 codes at first repeat assessment 
# flatTable(c(30710, 21003, 41270), instance = 1)
# -------------------------------------
# Load in required packages
library(duckdb)
library(dplyr)
library(tidyverse)

flatTable <- function(fieldIDs, instance = 0){

# Check arguments
if(!is.numeric(fieldIDs)){
	stop("Please provide a numeric value for the fieldIDs.")
}

if(!instance %in% c(0:3)){
	stop("Please provide either 0,1,2 or 3 for the instance. See documentation for more details.")
}

# Connect to the database
con <- DBI::dbConnect(duckdb::duckdb(),
  dbdir="/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb",
  read_only=TRUE)

# Load the data dictionary
Dictionary <- tbl(con, 'Dictionary')

# Make a dataframe that tells you which table each field ID is in
fields_df <- Dictionary |>
	filter(FieldID %in% fieldIDs) |>
	select(c(Table, FieldID)) |>
	collect()

# Create environment variables for each table, (assigned from it's character string name)
tables <- unique(fields_df$Table)
for(tab in tables){
  assign(tab, tbl(con, tab))
}

# Create a list for each table with the field IDs selected
# Reduce these and join by the ID column
flat_table_df <- lapply(tables, function(tab){
tmp <- fields_df |>
  filter(Table %in% tab) |>
  pull(FieldID) 
tmp <- paste0("f.", tmp, ".", instance, ".")

eval(as.symbol(tab)) |>
  select(c(f.eid, all_of(starts_with(tmp)))) 

}) %>% reduce(., full_join, by = "f.eid")

return(flat_table_df)

}


