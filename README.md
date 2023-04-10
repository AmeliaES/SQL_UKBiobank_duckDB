## Using duckDB on Eddie with the [command line interface](https://duckdb.org/docs/api/cli.html) to query the UK Biobank database

**1. Connect to Eddie (change to your user ID):**
```
ssh s1211670@eddie.ecdf.ed.ac.uk
```

**2. Open a screen session (optional):**
```
screen -S duckDB
```

**3. Log into an interactive node, change to your scratch or project directory and load the GCC compiler (so duckDB can run in the command line):**
```
qlogin -l h_vmem=8G
cd /exports/eddie/scratch/$USER
module load phys/compilers/gcc/9.3.0
```

<details>
  <summary>Make a symbolic link to the UKB database</summary>

More info about symlinks [here](https://linuxize.com/post/how-to-create-symbolic-links-in-linux-using-the-ln-command/).
```
ln -s /exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb ukb670429.duckdb
```
A symlink is now saved in your current directory, so you can now use `ukb670429.duckdb` instead of typing `/exports/igmm/eddie/GenScotDepression/data/ukb/phenotypes/fields/2022-11-phenotypes-ukb670429-v0.7.1/ukb670429.duckdb` when you are working from within this current directory.
</details>

**4. Run duckDB:**
Do this by executing the path to where duckdb is installed on Eddie:
```
/exports/igmm/eddie/GenScotDepression/local/bin/duckdb
```

<details>
  <summary>Alternatively you can add the following to your "~/.bash_profile" </summary>

```
export PATH=$PATH:/exports/igmm/eddie/GenScotDepression/local/bin/
```
This then allows duckdb to run by simply executing `duckdb` rather than typing the long path. NB. `.bash_profile` is run everytime you log into Eddie.
</details>

We are now using the duckDB command line interface. For more info about this, including helpful commands see the documentation [here](https://duckdb.org/docs/api/cli.html). You should see something that looks similar to this:
[figs/duckDB_open.png]

**5. Connect to the UKB database (NB. use the full path if you didn't make a symlink - see above):**
```
.open --readonly ukb670429.duckdb
```

**6. Run a basic query to check it works:**
* Count of each level of variable f.4598.0.0 (“ever depressed”) from table Touchscreen.
```
SELECT "f.4598.0.0" AS ever_depressed, COUNT(*) AS n
FROM Touchscreen
GROUP BY "f.4598.0.0";
┌──────────────────────┬────────┐
│    ever_depressed    │   n    │
│     "f.4598.0.0"     │ int64  │
├──────────────────────┼────────┤
│                      │ 329735 │
│ No                   │  78777 │
│ Yes                  │  89351 │
│ Do not know          │   3876 │
│ Prefer not to answer │    650 │
└──────────────────────┴────────┘
```

**7. Try the exercises [here](exercises.md) to get familiar with SQL commands and the UK Biobank duckDB.**

**8. Exit duckDB:**
"To exit the CLI, press Ctrl-D if your platform supports it. Otherwise press Ctrl-C. If using a persistent database, it will automatically checkpoint (save the latest edits to disk) and close. This will remove the .WAL file (the Write-Ahead-Log) and consolidate all of your data into the single file database."


