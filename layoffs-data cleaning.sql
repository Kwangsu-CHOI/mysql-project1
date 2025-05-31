-- Data cleaning
-- 1. remove duplicates
-- 2. standardise the data
-- 3. handle null values or blank values
-- 4. remove any columns


-- not good idea to work with original data so create another table that is duplicate of original.
create table layoffs_staging
like layoffs;

insert layoffs_staging
select * from layoffs;

select * from layoffs_staging2;


-- 1. identify duplicates

# using row_number window function to find out duplicates. if there is any duplicate,  row_num > 1
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

# row_num column with row_num > 1 
with cte_duplicate as 
(
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from cte_duplicate
where row_num > 1;

# create staging table (copy of original)

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

# insert row_num column to staging table

insert into layoffs_staging2
select *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

# check duplicates
select * 
from layoffs_staging2
where row_num > 1
;

# delete duplicates
delete
from layoffs_staging2
where row_num > 1;


-- 2. standardising data

# check company names with unnecessory blanks
select company, trim(company) 
from layoffs_staging2
;

# update company names
update layoffs_staging2
set company = trim(company);

# check industry names if there is any misspelled or similar names.
select distinct industry
from layoffs_staging2;

# updating crypto 
select industry
from layoffs_staging2
where industry like 'Crypto%'
;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

# check country names ending with dot
select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

# updating US with dot
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

# found that date is in text format. change it to date format
## chech if i can change current date to standard date format
select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

# update date to standard date format for sql
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

# now i can change date format from text to date
alter table layoffs_staging2
modify column `date` date;


-- 3. handling null or blank values

# identify if there is null data in some important columns
select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# found some companies industry values are mistakenly recorded as null or blank.
select *
from layoffs_staging2
where industry is null
or industry = '';

# replace blank value in industry column with null
update layoffs_staging2
set industry = null
where industry = '';

# ready for fill up null value by checking company name and location
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
	and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null)
and t2.industry is not null;

select *
from layoffs_staging2
where company like 'bally%';

-- 4. remove column

# find companies with no layoff record at all.
select * 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# delete identified companies
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

# find unnecessory column
select *
from layoffs_staging2;
# delete column
alter table layoffs_staging2
drop column row_num;