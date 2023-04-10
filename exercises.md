## Practice exercises for SQL queries of UK Biobank duckDB

* List the names of all the available tables
    <details>
      <summary>Answer:</summary>
      
    ```SQL
    SELECT table_name
    FROM INFORMATION_SCHEMA.TABLES;
    ```
    </details>

* Show the first 10 rows of all columns of the "WorkEnvironment" table
<details>
  <summary>Answer:</summary>

```SQL
SELECT * 
FROM WorkEnvironment 
LIMIT 5;
```
</details>

* Find the table that contains data on "smoking status". Hint: use the datashow case to find the field ID for this (https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20116).
<details>
  <summary>Answer:</summary>

The field ID for smoking status is "20116".
```SQL
SELECT      COLUMN_NAME AS 'ColumnName'
            ,TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%f.20116.%'
ORDER BY    TableName
            ,ColumnName;
```
This shows us the 4 columns representing the different instances for smoking and that they are all found in the Touchscreen table.
</details>

* Return summary counts for smoking status. ie. how many people for prefer not to answer, never, previous or current?
<details>
  <summary>Answer:</summary>

```SQL

```
</details>

* Write a statement to show participants with smoking "Current".
<details>
  <summary>Answer:</summary>

```SQL

```
</details>

* Write a statement that counts the number of rows from inner joining X and X where Y is X.
<details>
  <summary>Answer:</summary>

```SQL

```
</details>

* Write a function to show the minimum, maximum and average results for "C-reactive protein". 
<details>
  <summary>Answer:</summary>

```SQL

```
</details>

