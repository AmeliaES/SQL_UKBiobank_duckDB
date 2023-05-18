## Practice exercises for SQL queries of UK Biobank duckDB

* List the names of all the available tables
    <details>
      <summary>Answer:</summary>
      
    ```SQL
    SELECT table_name
    FROM INFORMATION_SCHEMA.TABLES;
    ```
    </details>

* Show the first 10 rows of all columns of the "WorkEnvironment" table.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT * 
    FROM WorkEnvironment 
    LIMIT 5;
    ```
    </details>


* List all the column names in the "BaselineCharacteristics" table.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT COLUMN_NAME, TABLE_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'BaselineCharacteristics';
    ```
    
    It's also possible to run the following which will return a list of all the tables:
    ```SQL
    .tables
    ```
    Note that this is case sensitive, `.tables` is an object. And `.TABLES` won't work.
    
    </details>

* Return meta data about all field IDs and their field description in the "Touchscreen" table.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT "Table", "FieldID", "Field"
    FROM Dictionary
    WHERE "Table" = 'Touchscreen';
    ```
    Note how we have to use double quotations around "Table", this is because it's an object in SQL. It's good practice to then also put double quotations around FieldID and Field too. Single quotations are used for string searches.
    </details>

* Find the table that contains data on "smoking status". Hint: use the datashow case to find the field ID for this (https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20116) or use the "Dictionary" table.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT "Table", "FieldID", "Field"
    FROM Dictionary
    WHERE "Field" LIKE '%moking%' AND "Field" LIKE '%tatus%';
    ```
    
    The field ID for smoking status is "20116" and it's in the Touchscreen table.
    Check all possible instances and arrays for this field:
    ```SQL
    SELECT      COLUMN_NAME AS 'ColumnName'
                ,TABLE_NAME AS  'TableName'
    FROM        INFORMATION_SCHEMA.COLUMNS
    WHERE       COLUMN_NAME LIKE '%f.20116.%'
    ORDER BY    TableName
                ,ColumnName;
    ```
    
    This shows us the 4 columns representing the different instances for smoking and that they are all found in the Touchscreen table. NB. You can also use `ILIKE` to query without cases, as `LIKE` is case sensitive. 
    </details>

* Return summary counts for smoking status for the initial assement visit (instance = 0). ie. how many people for prefer not to answer, never, previous or current?
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT "f.20116.0.0" AS SmokingStatus, 
            count("f.20116.0.0") AS N
    FROM Touchscreen
    GROUP BY "f.20116.0.0";
    ```
    </details>

* Write a statement to show participants with smoking "Current".
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT * 
    FROM Touchscreen
    WHERE "f.20116.0.0" = 'Current';
    ```
    </details>

* Write a statement that returns information on age, sex, smoking, alcohol, [depression items from MHQ](https://biobank.ndph.ox.ac.uk/showcase/label.cgi?id=138) and C-reactive protein.
    <details>
      <summary>Answer:</summary>
    
    First find all the tables and column names for these variables:
    ```SQL
    SELECT "Table", "FieldID", "Field", "Category"
    FROM Dictionary
    WHERE "Field" ILIKE '%age%' AND "Field" LIKE '%assessment%'
    OR "Field" ILIKE 'sex'
    OR "Field" ILIKE '%smoking%' AND "Field" ILIKE '%status'
    OR "Field" ILIKE '%alcohol%' AND "Field" ILIKE '%status%'
    OR "Category" = 138
    OR "Field" ILIKE '%c-rea%' AND "Field" NOT ILIKE '%protein %';
    ```

    Is there a way to do the following without listing all the field IDs manually without using dynamic SQL?
    ```SQL
    -- Just for age and sex:
    SELECT "f.eid", "f.31.0.0", "f.21003.0.0"
    FROM BaselineCharacteristics
         INNER JOIN Recruitment
            USING ("f.eid") 
         INNER JOIN Touchscreen
            USING ("f.eid");
    
    -- Using the columns function and matching using regular expressions:
    SELECT columns('f.20116.')
    FROM Touchscreen;
    ```
    </details>


* Write a statement that counts the number of rows from the above table grouped by sex.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT "f.31.0.0", COUNT(*)
        FROM BaselineCharacteristics
         INNER JOIN Recruitment
            USING ("f.eid") 
         INNER JOIN Touchscreen
            USING ("f.eid")
    GROUP BY "f.31.0.0";
    ```
    </details>

* Write a function to show the minimum, maximum and average results for "C-reactive protein". Grouped by sex.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT 
        "f.31.0.0",
        AVG("f.30710.0.0") AS average,
        MIN("f.30710.0.0") AS min,
        MAX("f.30710.0.0") AS max
    FROM BloodAssays
        INNER JOIN BaselineCharacteristics
        USING ("f.eid")
    GROUP BY "f.31.0.0";
    ```
    </details>

* Count how many people do and don't have missing CRP data.
    <details>
      <summary>Answer:</summary>
    
    ```SQL
    SELECT 
        COUNT(*)
    FROM BloodAssays
    WHERE "f.30710.0.0" IS NULL;

    SELECT 
        COUNT(*)
    FROM BloodAssays
    WHERE "f.30710.0.0" IS NOT NULL;
    ```
    </details>


