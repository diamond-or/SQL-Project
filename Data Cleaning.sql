USE work_layoff;

DROP TABLE IF EXISTS layoffs;
DROP TABLE IF EXISTS layoff_staging;
DROP TABLE IF EXISTS layoff_staging2;


CREATE TABLE layoffs (
  company varchar(50),
  location varchar(50),
  industry varchar(50),
  total_laid_off varchar(50),
  percentage_laid_off varchar(50),
  `date` varchar(50),
  stage varchar(50),
  country varchar(50),
  funds_raised_millions varchar(50));

LOAD DATA LOCAL INFILE '/Users/ordiamond/Desktop/SQL Practice/layoffs.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions);

-- Data Cleaning 
SELECT * FROM layoffs;

SELECT * FROM layoffs WHERE company = 'NULL' OR company = ''
						OR location = 'NULL' OR location = ''
						OR industry = 'NULL' OR industry = ''
                        OR total_laid_off = 'NULL' OR company = ''
						OR percentage_laid_off = 'NULL' OR percentage_laid_off= ''
                        OR `date` = 'NULL' OR `date` = ''
						OR stage = 'NULL' OR stage = ''
                        OR country = 'NULL' OR country = ''
                        OR funds_raised_millions = 'NULL' OR funds_raised_millions = '';

-- UPDATE NULL in STRING to NULL values
UPDATE layoffs SET company = NULL WHERE company = 'NULL' OR company = '';
UPDATE layoffs SET location = NULL WHERE location = 'NULL' OR location = '';
UPDATE layoffs SET industry = NULL WHERE industry = 'NULL' OR industry = '';
UPDATE layoffs SET total_laid_off = NULL WHERE total_laid_off = 'NULL' OR total_laid_off = '' OR total_laid_off = NULL;
UPDATE layoffs SET percentage_laid_off = NULL WHERE percentage_laid_off = 'NULL' OR percentage_laid_off = '' OR percentage_laid_off = NULL;
UPDATE layoffs SET `date` = NULL WHERE `date` = 'NULL' OR `date` = '' OR `date` = NULL;
UPDATE layoffs SET stage = NULL WHERE stage = 'NULL' OR stage = '' OR stage = NULL;
UPDATE layoffs SET country = NULL WHERE country = 'NULL' OR country = '';
UPDATE layoffs SET funds_raised_millions = NULL WHERE funds_raised_millions LIKE 'NULL%' OR funds_raised_millions = '' OR funds_raised_millions IS NULL;

-- 1. Remove duplicates
-- 2. Standardize the data
-- 3. Null or blank values
-- 4. Remove any columns 

-- Create a staging table to avoid untend actions
CREATE TABLE layoff_staging LIKE layoffs;

SELECT * FROM layoff_staging;

INSERT layoff_staging SELECT * FROM layoffs; 


-- BECAUSE WE DONT HAVE ACTUAL PRIMARY KEY OR UNIQUE ID SO WE NEED TO CREATE ROW_NUMBER() TO IDENTIFY DUPLICATES

WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, country, funds_raised_millions) as row_num
FROM layoff_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

SELECT * FROM layoff_staging WHERE company = 'Casper';

-- AS WE CANNOT DELETE DUPLICATE ROWS DIRECTLY FROM CTE, WE CAN JUST CREATE A NEW TABLE AND INSERT THOSE DATA IN THE NEW TABLE
DROP TABLE IF EXISTS `layoff_staging2`;
CREATE TABLE `layoff_staging2` (
  `company` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `total_laid_off` varchar(50) DEFAULT NULL,
  `percentage_laid_off` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `funds_raised_millions` varchar(50) DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
WITH duplicate_cte AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, country, funds_raised_millions) as row_num
FROM layoff_staging
)
SELECT * FROM duplicate_cte;

SELECT * FROM layoff_staging2 WHERE row_num > 1 ORDER BY company;

-- DELETE DUPLICATE ROWS
DELETE FROM layoff_staging2 WHERE row_num > 1;

SELECT * FROM layoff_staging2;

-- CHECK STRING IN EACH COLUMNS
SELECT company, TRIM(company) FROM layoff_staging2;

UPDATE layoff_staging2 SET company = TRIM(company);

-- CHECK location COLUMN
SELECT DISTINCT location FROM layoff_staging2;

-- CHECK industry COLUMN
SELECT DISTINCT industry FROM layoff_staging2 ORDER BY 1;

UPDATE layoff_staging2 SET industry = TRIM(industry);

SELECT DISTINCT industry FROM layoff_staging2 WHERE industry LIKE 'Crypto%';

UPDATE layoff_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

SELECT * FROM layoff_staging2;

-- CHECK country COLUMN

SELECT DISTINCT country FROM layoff_staging2 ORDER BY 1;

UPDATE layoff_staging2 SET country = TRIM(country);

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoff_staging2 ORDER BY 1;

UPDATE layoff_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

--  CHECK DATE COLUMN

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoff_staging2 ORDER BY 2;

UPDATE layoff_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); 

ALTER TABLE layoff_staging2 MODIFY COLUMN `date` DATE;

SELECT * FROM layoff_staging2 WHERE industry IS NULL or industry = '';

SELECT * FROM layoff_staging2 WHERE company  = 'Airbnb';

SELECT * FROM layoff_staging2 t1 JOIN layoff_staging2 t2 ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

-- POPULATED MISSING VALUES
UPDATE layoff_staging2 t1 JOIN layoff_staging2 t2 ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- DROP row_num COLUMN
ALTER TABLE layoff_staging2
DROP row_num;

-- DELETE ROWS contain NULL VALUES in both total laid off and percentage laid off.
SELECT * FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoff_staging2;









