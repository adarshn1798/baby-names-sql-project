-- -------------------------------------------------------------------------------------
-- Task 1: Find the overall most popular girl and boy names 
--         and show how they have changed in popularity rankings over the years
-- -------------------------------------------------------------------------------------

-- Overall most popular girl name across all years
SELECT Name, SUM(Births) AS num_babies
FROM names
WHERE Gender = 'F'
GROUP BY Name
ORDER BY num_babies DESC
LIMIT 1; -- Result: Jessica

-- Overall most popular boy name across all years
SELECT Name, SUM(Births) AS num_babies
FROM names
WHERE Gender = 'M'
GROUP BY Name
ORDER BY num_babies DESC
LIMIT 1; -- Result: Michael

-- Year-wise popularity ranking of the most popular girl name (Jessica)
SELECT *
FROM (
    WITH baby_names AS (
        SELECT Year, Name, SUM(Births) AS girl_babies
        FROM names
        WHERE Gender = 'F'
        GROUP BY Year, Name
    )
    SELECT Year, Name,
           ROW_NUMBER() OVER(PARTITION BY Year ORDER BY girl_babies DESC) AS rnk_babies
    FROM baby_names
) AS rnk_details
WHERE Name = 'Jessica'; -- Jessica was top 3 in the 80s and 90s but declined in the 2000s

-- Year-wise popularity ranking of the most popular boy name (Michael)
SELECT *
FROM (
    WITH baby_names AS (
        SELECT Year, Name, SUM(Births) AS boy_babies
        FROM names
        WHERE Gender = 'M'
        GROUP BY Year, Name
    )
    SELECT Year, Name,
           ROW_NUMBER() OVER(PARTITION BY Year ORDER BY boy_babies DESC) AS rnk_babies
    FROM baby_names
) AS rnk_details
WHERE Name = 'Michael'; -- Michael consistently ranked in the top 3 from 1980–2009



-- -------------------------------------------------------------------------------------
-- Task 2: Find the names with the biggest jumps in popularity 
--         from the first year (1980) to the last year (2009)
-- -------------------------------------------------------------------------------------

WITH names_1980 AS (
    -- Get name rankings in 1980
    WITH baby_names AS (
        SELECT Year, Name, SUM(Births) AS all_babies
        FROM names
        GROUP BY Year, Name
    )
    SELECT Year, Name,
           ROW_NUMBER() OVER(PARTITION BY Year ORDER BY all_babies DESC) AS rnk_babies
    FROM baby_names
    WHERE Year = 1980
),
names_2009 AS (
    -- Get name rankings in 2009
    WITH baby_names AS (
        SELECT Year, Name, SUM(Births) AS all_babies
        FROM names
        GROUP BY Year, Name
    )
    SELECT Year, Name,
           ROW_NUMBER() OVER(PARTITION BY Year ORDER BY all_babies DESC) AS rnk_babies
    FROM baby_names
    WHERE Year = 2009
)
-- Compare ranking difference between 1980 and 2009
SELECT *,
       CAST(t2.rnk_babies AS SIGNED) - CAST(t1.rnk_babies AS SIGNED) AS diff
FROM names_1980 t1
JOIN names_2009 t2 ON t1.Name = t2.Name
ORDER BY diff; 
-- Names like Colton, Aidan, Rowan, Skylar, Macy saw the biggest jump in popularity



-- -------------------------------------------------------------------------------------
-- Task 3: For each year, return the top 3 girl names and top 3 boy names
-- -------------------------------------------------------------------------------------

SELECT *
FROM (
    WITH baby_names AS (
        SELECT Year, Gender, Name, SUM(Births) AS total_babies
        FROM names
        GROUP BY Year, Gender, Name
    )
    SELECT Year, Gender, Name,
           ROW_NUMBER() OVER(PARTITION BY Year, Gender ORDER BY total_babies DESC) AS rnk_babies
    FROM baby_names
) AS all_babies
WHERE rnk_babies < 4; -- Top 3 male and female baby names per year



-- -------------------------------------------------------------------------------------
-- Task 4: For each decade, return the top 3 girl names and top 3 boy names
-- -------------------------------------------------------------------------------------

SELECT *
FROM (
    WITH baby_names AS (
        SELECT FLOOR(Year / 10) * 10 AS decade, Gender, Name, SUM(Births) AS total_babies
        FROM names
        GROUP BY decade, Gender, Name
    )
    SELECT decade, Gender, Name,
           ROW_NUMBER() OVER(PARTITION BY decade, Gender ORDER BY total_babies DESC) AS rnk_babies
    FROM baby_names
) AS all_babies
WHERE rnk_babies < 4; -- Top 3 names per gender per decade



-- -------------------------------------------------------------------------------------
-- Task 5: Return the number of babies born in each of the six regions 
--         (Ensure MI is included in the Midwest region)
-- -------------------------------------------------------------------------------------

WITH clean_regions AS (
    -- Clean region names and append Michigan manually to Midwest
    SELECT State, 
           CASE WHEN Region = 'New England' THEN 'New_England' ELSE Region END AS clean_region
    FROM regions
    UNION
    SELECT 'MI' AS State, 'Midwest' AS Region
)
SELECT cr.clean_region, SUM(n.births) AS num_babies
FROM names n
LEFT JOIN clean_regions cr ON n.State = cr.State
GROUP BY cr.clean_region;



-- -------------------------------------------------------------------------------------
-- Task 6: Return the top 3 girl and boy names within each region
-- -------------------------------------------------------------------------------------

SELECT * FROM (
    WITH clean_regions AS (
        SELECT State, 
               CASE WHEN Region = 'New England' THEN 'New_England' ELSE Region END AS clean_region
        FROM regions
        UNION
        SELECT 'MI' AS State, 'Midwest' AS Region
    ),
    babies_info AS (
        SELECT cr.clean_region, n.Gender, n.Name, SUM(n.Births) AS num_babies
        FROM names n
        LEFT JOIN clean_regions cr ON n.State = cr.State
        GROUP BY cr.clean_region, n.Gender, n.Name
    )
    SELECT clean_region, Gender, Name,
           ROW_NUMBER() OVER(PARTITION BY clean_region, Gender ORDER BY num_babies DESC) AS rnk_babies
    FROM babies_info
) AS sub
WHERE rnk_babies < 4; -- Top 3 per gender per region



-- -------------------------------------------------------------------------------------
-- Task 7: Find the 10 most popular androgynous names 
--         (i.e., names given to both males and females)
-- -------------------------------------------------------------------------------------

SELECT Name, COUNT(DISTINCT Gender) AS num_genders, SUM(Births) AS num_babies
FROM names
GROUP BY Name 
HAVING num_genders = 2
ORDER BY num_babies DESC
LIMIT 10;



-- -------------------------------------------------------------------------------------
-- Task 8: Analyze name lengths: 
--         - Shortest and longest names 
--         - Most popular among them
-- -------------------------------------------------------------------------------------

-- Names ordered by shortest length and popularity
SELECT Name, LENGTH(Name) AS num_chars, SUM(Births) AS num_babies
FROM names
GROUP BY Name, num_chars
ORDER BY num_chars, num_babies DESC;

-- Names ordered by longest length and popularity
SELECT Name, LENGTH(Name) AS num_chars, SUM(Births) AS num_babies
FROM names
GROUP BY Name, num_chars
ORDER BY num_chars DESC, num_babies DESC;



-- -------------------------------------------------------------------------------------
-- Task 9: Find the state with the highest percentage of babies named "Chris"
-- -------------------------------------------------------------------------------------

WITH count_chris AS (
    -- Count babies named Chris per state
    SELECT State, SUM(Births) AS num_chris
    FROM names
    WHERE Name = 'Chris'
    GROUP BY State
),
count_all AS (
    -- Total babies born per state
    SELECT State, SUM(Births) AS num_all
    FROM names
    GROUP BY State
)
SELECT cc.State, 
       ROUND(cc.num_chris * 100.0 / ca.num_all, 4) AS pct_chris
FROM count_chris cc
JOIN count_all ca ON cc.State = ca.State
ORDER BY pct_chris DESC;
-- Highest % of babies named "Chris" per state
