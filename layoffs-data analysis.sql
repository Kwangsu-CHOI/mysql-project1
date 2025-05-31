-- Queries for Data anlysis

# showing entire data
select *
from layoffs_staging2;

# max number and percentage of total people laid off
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

# showing records of those who fully laid off their employees and order it by largest number of layoff first
select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

# showing records of those who fully laid off their employees and order it by largest fund raised first
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

# total layoffs by company, showing largest number of total layoff first
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

# identifying start and end date of this data
select min(`date`), max(`date`)
from layoffs_staging2;

# total layoff by industry, showing largest number of total layoff first
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

# total layoff by country, showing largest number of total layoff first
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc;

# total layoffs by period
## by date
select stage, sum(total_laid_off)
from layoffs_staging2
group by s
order by 2 desc;

## by month in each year
select substring(`date`, 1, 7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `month`
order by 1 asc;

## rolling total based on each month
with rolling_total as
(
	select substring(`date`, 1, 7) as `month`, sum(total_laid_off) as layoff_total
	from layoffs_staging2
	where substring(`date`, 1, 7) is not null
	group by `month`
	order by 1 asc
)
select `month`, layoff_total, sum(layoff_total) over(order by `month`) as rolling_total
from rolling_total;

## yearly total layoffs by company
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

## top 5 yearly total layoff by company
with 
company_year (company, years, total_laid_off) as
(
	select company, year(`date`), sum(total_laid_off)
	from layoffs_staging2
	group by company, year(`date`)
),
company_year_rank as
(
	select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
	from company_year
	where years is not null
	order by ranking asc
)
select *
from company_year_rank
where ranking <= 5;










