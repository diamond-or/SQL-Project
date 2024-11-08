-- Exploratory Data Analysis 

SELECT * FROM layoff_staging2;

-- MODIFY DATA TYPE COLUMNS
ALTER TABLE layoff_staging2
MODIFY COLUMN total_laid_off INT;

ALTER TABLE layoff_staging2
MODIFY COLUMN percentage_laid_off BOOL;

ALTER TABLE layoff_staging2
MODIFY COLUMN funds_raised_millions INT;



-- CHECK maximum total laid off in a day
SELECT MAX(total_laid_off), MAX(percentage_laid_off) FROM layoff_staging2;

-- CHECK the company that laid off all of their employees
SELECT * FROM layoff_staging2 WHERE percentage_laid_off = 1;

-- CHECK which company has the highest fund raised and also highest in laid off
SELECT * FROM layoff_staging2 WHERE percentage_laid_off = 1 ORDER BY funds_raised_millions DESC;

-- FIND THE DATE FROM THE PERIOD OF DATA
SELECT MIN(`date`), MAX(`date`) FROM layoff_staging2;

-- CHECK THE HIGHEST LAID OFF COMPANY THROUGH OUT THE PERIOD
SELECT company, SUM(total_laid_off) FROM layoff_staging2 GROUP BY company ORDER BY 2 DESC;

-- CHECK WHICH INDUSTRY IS THE MOST LAID OFF 
SELECT industry, SUM(total_laid_off) FROM layoff_staging2 GROUP BY industry ORDER BY 2 DESC;

-- CHECK WHICH COUNTRY IS THE MOST LAID OFF 
SELECT country, SUM(total_laid_off) FROM layoff_staging2 GROUP BY country ORDER BY 2 DESC;

-- CHECK WHICH YEAR HAS THE HIGHEST LAID OFF
SELECT YEAR(`date`), SUM(total_laid_off) FROM layoff_staging2 GROUP BY YEAR(`date`) ORDER BY YEAR(`date`) DESC;

-- CHECK HIGHEST LAID OFF MONTH AND ROLLING SUM
SELECT SUBSTRING(`date`, 6, 2) as `MONTH`, SUM(total_laid_off) FROM layoff_staging2 GROUP BY `MONTH` ORDER BY 1;

WITH rolling_total AS (
SELECT SUBSTRING(`date`, 1, 7) as `MONTH`, SUM(total_laid_off) as total_off
FROM layoff_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH` 
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_sum FROM rolling_total;

-- CHECK WHAT YEAR THE MOST LAID OFF BY COMPANY
SELECT company, YEAR(`date`), SUM(total_laid_off) FROM layoff_staging2 GROUP BY company, YEAR(`date`) ORDER BY 3 DESC;

WITH Company_Year (company, year, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off) FROM layoff_staging2 GROUP BY company, YEAR(`date`) 
), Company_Ranking AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS RANKING FROM Company_Year WHERE year IS NOT NULL ORDER BY RANKING)
SELECT * FROM Company_Ranking WHERE RANKING <= 5 ORDER BY year
;







