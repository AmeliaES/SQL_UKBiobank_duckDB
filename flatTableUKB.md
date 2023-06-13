# Extract UK Biobank data using the duckdb R package to create a flat table for analysis

## Log into an interactive node on Eddie and launch R:
```
qlogin -l h_vmem=32G
module load igmm/apps/R/4.1.0
R
```

## Run R script
```
source('flatTableUKB.R')
```


