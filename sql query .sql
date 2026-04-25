-- query 1 performance % per trust 

SELECT
    "Org Code",
    "Org name",
    "Parent Org",
    ("A&E attendances Type 1" + 
     "A&E attendances Type 2" + 
     "A&E attendances Other A&E Department") 
     AS total_attendances,
    ROUND(CAST(
        ("A&E attendances Type 1" + 
         "A&E attendances Type 2" + 
         "A&E attendances Other A&E Department") -
        ("Attendances over 4hrs Type 1" + 
         "Attendances over 4hrs Type 2" + 
         "Attendances over 4hrs Other Department")
    AS FLOAT) / NULLIF(
        ("A&E attendances Type 1" + 
         "A&E attendances Type 2" + 
         "A&E attendances Other A&E Department")
    , 0) * 100, 1) AS performance_pct
FROM "Monthly-AE-March-2025"
WHERE ("A&E attendances Type 1" + 
       "A&E attendances Type 2" + 
       "A&E attendances Other A&E Department") > 0
ORDER BY performance_pct ASC;


-- query 2 Add Red , amber , Green to Each trust 
SELECT
    "Org Code",
    "Org name",
    "Parent Org",
    ("A&E attendances Type 1" + 
     "A&E attendances Type 2" + 
     "A&E attendances Other A&E Department") 
     AS total_attendances,
    ROUND(CAST(
        ("A&E attendances Type 1" + 
         "A&E attendances Type 2" + 
         "A&E attendances Other A&E Department") -
        ("Attendances over 4hrs Type 1" + 
         "Attendances over 4hrs Type 2" + 
         "Attendances over 4hrs Other Department")
    AS FLOAT) / NULLIF(
        ("A&E attendances Type 1" + 
         "A&E attendances Type 2" + 
         "A&E attendances Other A&E Department")
    , 0) * 100, 1) AS performance_pct,
    CASE
        WHEN ROUND(CAST(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department") -
            ("Attendances over 4hrs Type 1" + 
             "Attendances over 4hrs Type 2" + 
             "Attendances over 4hrs Other Department")
        AS FLOAT) / NULLIF(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department")
        , 0) * 100, 1) >= 95 THEN 'GREEN'
        WHEN ROUND(CAST(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department") -
            ("Attendances over 4hrs Type 1" + 
             "Attendances over 4hrs Type 2" + 
             "Attendances over 4hrs Other Department")
        AS FLOAT) / NULLIF(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department")
        , 0) * 100, 1) >= 76 THEN 'AMBER'
        ELSE 'RED'
    END AS rag_rating
FROM "Monthly-AE-March-2025"
WHERE ("A&E attendances Type 1" + 
       "A&E attendances Type 2" + 
       "A&E attendances Other A&E Department") > 0
ORDER BY performance_pct ASC;


-- query 3 how many red , green , amber trust 
SELECT 
    rag_rating,
    COUNT(*) AS number_of_trusts
FROM (
    SELECT
        CASE
            WHEN ROUND(CAST(
                ("A&E attendances Type 1" + 
                 "A&E attendances Type 2" + 
                 "A&E attendances Other A&E Department") -
                ("Attendances over 4hrs Type 1" + 
                 "Attendances over 4hrs Type 2" + 
                 "Attendances over 4hrs Other Department")
            AS FLOAT) / NULLIF(
                ("A&E attendances Type 1" + 
                 "A&E attendances Type 2" + 
                 "A&E attendances Other A&E Department")
            , 0) * 100, 1) >= 95 THEN 'GREEN'
            WHEN ROUND(CAST(
                ("A&E attendances Type 1" + 
                 "A&E attendances Type 2" + 
                 "A&E attendances Other A&E Department") -
                ("Attendances over 4hrs Type 1" + 
                 "Attendances over 4hrs Type 2" + 
                 "Attendances over 4hrs Other Department")
            AS FLOAT) / NULLIF(
                ("A&E attendances Type 1" + 
                 "A&E attendances Type 2" + 
                 "A&E attendances Other A&E Department")
            , 0) * 100, 1) >= 76 THEN 'AMBER'
            ELSE 'RED'
        END AS rag_rating
    FROM "Monthly-AE-March-2025"
    WHERE ("A&E attendances Type 1" + 
           "A&E attendances Type 2" + 
           "A&E attendances Other A&E Department") > 0
)
GROUP BY rag_rating
ORDER BY number_of_trusts DESC;
--query 4 -- RQ3: Regional Analysis - Who is failing 
SELECT
    "Parent Org" AS region,
    COUNT(*) AS number_of_trusts,
    SUM("A&E attendances Type 1" + 
        "A&E attendances Type 2" + 
        "A&E attendances Other A&E Department") 
        AS total_patients,
    ROUND(AVG(
        CAST(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department") -
            ("Attendances over 4hrs Type 1" + 
             "Attendances over 4hrs Type 2" + 
             "Attendances over 4hrs Other Department")
        AS FLOAT) / NULLIF(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department")
        , 0) * 100
    ), 1) AS avg_performance_pct,
    SUM("Attendances over 4hrs Type 1" + 
        "Attendances over 4hrs Type 2" + 
        "Attendances over 4hrs Other Department") 
        AS patients_failed,
    ROUND(
        CAST(SUM("Attendances over 4hrs Type 1" + 
             "Attendances over 4hrs Type 2" + 
             "Attendances over 4hrs Other Department") 
        AS FLOAT) /
        CAST((SELECT SUM("Attendances over 4hrs Type 1" + 
                    "Attendances over 4hrs Type 2" + 
                    "Attendances over 4hrs Other Department")
              FROM "Monthly-AE-March-2025"
              WHERE "Parent Org" != 'TOTAL') AS FLOAT) * 100
    , 1) AS pct_of_national_failures
FROM "Monthly-AE-March-2025"
WHERE ("A&E attendances Type 1" + 
       "A&E attendances Type 2" + 
       "A&E attendances Other A&E Department") > 0
AND "Parent Org" != 'TOTAL'
GROUP BY "Parent Org"
ORDER BY patients_failed DESC;

-- Q4: 12 Hour Wait Crisis by Trust
SELECT
    "Org Code",
    "Org name",
    "Parent Org" AS region,

    -- Total attendances
    ("A&E attendances Type 1" + 
     "A&E attendances Type 2" + 
     "A&E attendances Other A&E Department")
     AS total_attendances,

    -- Patients waiting 4-12 hours
    "Patients who have waited 4-12 hrs from DTA to admission"
     AS wait_4_12hrs,

    -- Patients waiting 12+ hours
    "Patients who have waited 12+ hrs from DTA to admission"
     AS wait_over_12hrs,

    -- 12hr wait as % of total attendances
    ROUND(
        CAST("Patients who have waited 12+ hrs from DTA to admission"
        AS FLOAT) /
        NULLIF(
            ("A&E attendances Type 1" + 
             "A&E attendances Type 2" + 
             "A&E attendances Other A&E Department")
        , 0) * 100
    , 2) AS pct_waiting_12hrs

FROM "Monthly-AE-March-2025"
WHERE "Patients who have waited 12+ hrs from DTA to admission" > 0
AND "Parent Org" != 'TOTAL'
ORDER BY wait_over_12hrs DESC;

