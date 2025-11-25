USE DATABASE BRIGHTLIGHT_TV_DB;

SELECT * FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
WHERE UserID = 39;

ALTER TABLE  BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL DROP COLUMN column_name;


SELECT * FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL
WHERE UserID = 39;

--Doing column count
SELECT COUNT(*)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL;

--Doing column count
SELECT COUNT(*)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL;
--Checking how many channels do we have
SELECT COUNT(DISTINCT CHANNEL2)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL;

SELECT DISTINCT(GENDER)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL;

SELECT DURATION_2,CHANNEL2,RECORDDATE2  
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
ORDER BY DURATION_2 DESC;
--Checking Max and Min AGE
SELECT MIN(AGE)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL;

--To check how many Users
SELECT COUNT(DISTINCT (UserID))
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL;

--Check Max and Min Recorddate2
SELECT MIN(RECORDDATE2)
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL;


--Converting recorddate2 to date and time separate column
  SELECT     
      --  RECORDDATE2,
         DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DAY, -- Changed from dayname
        DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DATE,  -- Changed from DATE
        TIME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_TIME,  -- Changed from TIME
            CASE
                WHEN VIEW_DAY IN (SUNDAY AND SATURDAY) THEN 'WEEKEND'
                ELSE WEEKDAYS
                END AS DAY_Bucket,
              DURATION_2
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL;
-- adding buckets

SELECT  
    CHANNEL2,
    DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS VIEW_DATE,
    TIME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS VIEW_TIME,
    DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS VIEW_DAYNAME,
    CASE 
        WHEN DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) IN ('Saturday', 'Sunday') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS DAY_BUCKET,
    DURATION_2,
    LEAD(DURATION_2) OVER(PARTITION BY CHANNEL2 ORDER BY TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS Duration_NextDay,
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
LIMIT 20;


   SELECT  
    CHANNEL2,
    DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS VIEW_DATE,
    TO_CHAR(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI'), 'HH24:MI') AS VIEW_TIME,
    DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS VIEW_DAYNAME,
    CASE 
        WHEN DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) IN ('Saturday', 'Sunday') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS DAY_BUCKET,
    DURATION_2,
    LEAD(DURATION_2) OVER(PARTITION BY CHANNEL2 ORDER BY TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS Duration_DayBefore,
    CASE 
        WHEN Duration_NextDay IS NOT NULL AND Duration_NextDay != 0 THEN 
            ROUND((DURATION_2 - Duration_NextDay) / Duration_NextDay * 100, 0)
        ELSE NULL
    END AS DOD
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
LIMIT 20;




-----------------------------------------------------------------------------------------------------------------------------------------------
WITH cte_viewship AS (
    SELECT  
        --  v."userid",
           CHANNEL2,
           RECORDDATE2,
            DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DATE,  
            TIME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_TIME, 
            DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DAYNAME,
         CASE
        WHEN VIEW_DAYNAME IN ('Sat', 'Sun') THEN 'WEEKEND'
        ELSE 'WEEKDAY'
    END AS DAY_Bucket,
        DURATION_2,
       -- LAG(DURATION_2) OVER(PARTITION BY CHANNEL2 ORDER BY TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) AS Duration_DayBefore,
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
),
cte_Userprofile AS (
                     SELECT 
                          UserID,
                          GENDER,
                          RACE,
                          PROVINCE,
                          NAME,
                          AGE,
                             CASE
                                WHEN AGE BETWEEN 0 AND 19 THEN 'Children'
                                WHEN AGE BETWEEN 20 AND 35 THEN 'Young Adult'
                                WHEN AGE BETWEEN 36 AND 60 THEN 'Adult'
                                ELSE 'Senior'
                          END AS AGE_Category
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL
) 
SELECT    
    v."UserID",
    COALESCE(v.CHANNEL2, 'Unknown channel') AS CHANNEL2,
    v.RECORDDATE2,
    v.VIEW_DAYNAME,
    v.VIEW_DATE,
    v.VIEW_TIME,
    v.DAY_Bucket,
    v.DURATION_2,
  --  Duration_DayBefore,
    UserID,
    COALESCE(u.GENDER, 'Unknown gender') AS GENDER,
    COALESCE(u.RACE,'Unknown race') AS RACE,
    u.NAME,
    u.AGE,
    u.AGE_Category,
    u.PROVINCE,
FROM cte_viewship AS v
    LEFT JOIN cte_Userprofile AS u
    ON  v."UserID" = u.UserID;
   


-------------------------------------------------------------------------------------------------------

SELECT   
    v."UserID",
    v.CHANNEL2,
    DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DATE,  
    TIME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_TIME, 
    DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DAYNAME,
          CASE
            WHEN VIEW_DAYNAME IN ('Sat', 'Sun') THEN 'WEEKEND'
            ELSE 'WEEKDAY'
        END AS DAY_Bucket,
    v.DURATION_2,
    u.NAME,
    u.Surname,
    u.Email,
    u.GENDER, 
    u.RACE,
            CASE
            WHEN AGE BETWEEN 0 AND 19 THEN 'Children'
            WHEN AGE BETWEEN 20 AND 35 THEN 'Young Adult'
            WHEN AGE BETWEEN 36 AND 60 THEN 'Adult'
            ELSE 'Senior'
        END AS AGE_Category,
    u.PROVINCE,
FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL AS v
FULL OUTER JOIN BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL AS u
    ON v."UserID" = u.UserID
WHERE v."UserID" IS NOT NULL
AND v.CHANNEL2 IS NOT NULL
AND v.DURATION_2 IS NOT NULL
AND v.RECORDDATE2 IS NOT NULL
AND u.NAME IS NOT NULL
AND u.Surname IS NOT NULL
AND u.Email IS NOT NULL
AND u.GENDER IS NOT NULL
AND u.RACE IS NOT NULL
AND u.AGE IS NOT NULL
AND u.PROVINCE IS NOT NULL
AND u.GENDER IS NOT NULL;




--------------------------------------------------------------------------------------------------------------------------------------------------------------

WITH cte_viewship AS (
    SELECT  
       v."UserID",
        CHANNEL2,
        RECORDDATE2,
        DATE(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DATE,  
        TIME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_TIME, 
        DAYNAME(TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI')) as VIEW_DAYNAME,
        CASE
            WHEN VIEW_DAYNAME IN ('Sat', 'Sun') THEN 'WEEKEND'
            ELSE 'WEEKDAY'
        END AS DAY_Bucket,
        DURATION_2
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.VIEWSHIP_TBL
),
cte_Userprofile AS (
    SELECT 
        u.UserID,
        GENDER,
        RACE,
        PROVINCE,
        NAME,
        AGE,
        CASE
            WHEN AGE BETWEEN 0 AND 19 THEN 'Children'
            WHEN AGE BETWEEN 20 AND 35 THEN 'Young Adult'
            WHEN AGE BETWEEN 36 AND 60 THEN 'Adult'
            ELSE 'Senior'
        END AS AGE_Category
    FROM BRIGHTLIGHT_TV_DB.BRIGHTTV_SCH.USER_PROFILE_TBL
) 
SELECT    
    u.UserID,
    COALESCE(v.CHANNEL2, 'Unknown channel') AS CHANNEL2,
    v.RECORDDATE2,
    v.VIEW_DAYNAME,
    v.VIEW_DATE,
    v.VIEW_TIME,
    v.DAY_Bucket,
    v.DURATION_2,
    COALESCE(u.GENDER, 'Unknown gender') AS GENDER,
    COALESCE(u.RACE,'Unknown race') AS RACE,
    u.NAME,
    u.AGE,
    u.AGE_Category,
    u.PROVINCE
FROM cte_viewship AS v
LEFT JOIN cte_Userprofile AS u
    ON v"UserID" = u.UserID;  -- Fixed join condition

----------------------------------------------------------------------------------------------------------------------------------------------------
    