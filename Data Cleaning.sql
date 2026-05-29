-- DATA CLEANING NIEL BALAGTAS 4/19/2026

SELECT *
FROM dirty_cafe_sales;

-- CREATE STAGING DATASET
CREATE TABLE `cafe_staging` (
  `Transaction ID` text,
  `Item` text,
  `Quantity` int DEFAULT NULL,
  `Price Per Unit` double DEFAULT NULL,
  `Total Spent` text,
  `Payment Method` text,
  `Location` text,
  `Transaction Date` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT cafe_staging
SELECT *
FROM dirty_cafe_sales;

SELECT *
FROM cafe_staging;

-- REMOVE DUPLICATES
SELECT `Transaction ID`, COUNT(*) AS occurences
FROM cafe_staging
GROUP BY `Transaction ID`
HAVING occurences > 1;

-- NO DUPLICATE RECORDS
-- THERE ARE NO DUPLICATES IN THE DATASET


-- STANDARDIZE DATA
-- ITEM COLUMN
SELECT DISTINCT Item
FROM cafe_staging;

SELECT *
FROM cafe_staging
WHERE Item = 'UNKNOWN';
-- 304 ROWS UNKNOWN
-- 293 ROWS BLANK

UPDATE cafe_staging
SET Item = 'UNKNOWN'
WHERE Item = '';

-- PAYMENT METHOD
SELECT DISTINCT `Payment Method`
FROM cafe_staging;

SELECT *
FROM cafe_staging
WHERE `Payment Method` = 'UNKNOWN';
-- 2310 rows unknown

UPDATE cafe_staging
SET `Payment Method` = 'UNKNOWN'
WHERE `Payment Method` = '';


-- LOCATION COLUMN
SELECT DISTINCT Location
FROM cafe_staging;

SELECT *
FROM cafe_staging
WHERE Location = 'UNKNOWN';

UPDATE cafe_staging
SET Location = 'UNKNOWN'
WHERE Location = '';

-- TOTAL SPENT
SELECT Quantity, `Price Per Unit`, `Total Spent`, Quantity * `Price Per Unit` AS temp_total_spent
FROM cafe_staging
WHERE `Total Spent` IN ('ERROR', 'UNKNOWN', '');

UPDATE cafe_staging
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Total Spent` IN ('ERROR', 'UNKNOWN', '');

ALTER TABLE cafe_staging
MODIFY COLUMN `Total Spent` DOUBLE;

-- i accidentaly set the column Total Spent column to INT instead of DOUBLE
UPDATE cafe_staging
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Price Per Unit` = 1.5;


-- TRANSACTION DATE
SELECT `Transaction Date`
FROM cafe_staging
WHERE `Transaction Date` IS NULL;

-- i accidentally made the date values all nulls, i have to reset the values from the raw data
UPDATE cafe_staging AS s
JOIN dirty_cafe_sales AS r 
    ON s.`Transaction ID` = r.`Transaction ID`
SET s.`Transaction Date` = r.`Transaction Date`
WHERE s.`Transaction Date` IS NULL;

UPDATE cafe_staging
SET `Transaction Date` = NULL
WHERE `Transaction Date` IN ('ERROR', 'UNKNOWN');

ALTER TABLE cafe_staging
MODIFY COLUMN `Transaction Date` DATE;

-- END OF STANDARDIZATION

-- HANDLE NULL VALUES
-- POSSIBLE REMOVAL OF ROWS WITH NO ANALYTICAL VALUE
SELECT *
FROM cafe_staging
WHERE Item IN ('UNKNOWN', 'ERROR') AND Location IN ('UNKNOWN', 'ERROR') AND `Transaction Date` IS NULL AND `Payment Method` IN ('UNKNOWN', 'ERROR');
-- THESE ROWS PROVE NO VALUE SINCE IMPORTANT VALUES ARE MISSING

DELETE
FROM cafe_staging
WHERE Item IN ('UNKNOWN', 'ERROR') AND Location IN ('UNKNOWN', 'ERROR') AND `Transaction Date` IS NULL AND `Payment Method` IN ('UNKNOWN', 'ERROR');

-- END OF HANDLING NULL VALUES

SELECT * FROM cafe_staging;

-- CREATION OF CLEANED DATASET
CREATE TABLE `cleaned_cafe_sales` (
  `Transaction ID` text,
  `Item` text,
  `Quantity` int DEFAULT NULL,
  `Price Per Unit` double DEFAULT NULL,
  `Total Spent` double DEFAULT NULL,
  `Payment Method` text,
  `Location` text,
  `Transaction Date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT cleaned_cafe_sales
SELECT *
FROM cafe_staging;

SELECT *
FROM cleaned_cafe_sales;

-- END OF DATA CLEANING