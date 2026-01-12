-- select the schema/database to run all queries in
use new_schema1;

-- quick sanity check: view the raw layoffs table
select * from layoffs;

-- data cleaning roadmap (high-level)
-- remove duplicates: prevent inflated counts and incorrect aggregations
-- standardize: ensure consistent categories for grouping
-- rebuild/discard: handle nulls and unusable rows
-- remove unnecessary stuff: drop helper columns used during cleaning
-- always have a backup: create staging tables before risky operations

-- create 1st new table
-- purpose: create a working copy of the raw table structure
create table layoffs_staging
like layoffs;


-- remove duplicates

-- creating a new table to work with the data
-- purpose: populate staging table so raw data remains untouched
insert into layoffs_staging
select *
from layoffs;

-- checking to see if the creation worked
-- purpose: confirm data exists in the staging table
select *
from layoffs_staging;

-- checking for duplicates
-- purpose: flag duplicate rows using row_number()
-- note: rn > 1 indicates duplicate rows across the partitioned columns
with dup as (
	select *,
		 row_number()
			over(partition by
				company,
				location,
				industry,
				total_laid_off,
				percentage_laid_off,
				`date`,
				stage,
				country,
				funds_raised_millions) as rn
	from layoffs_staging
)

-- view only duplicated rows
select *
from dup
where rn > 1;

-- check to see if they are actual duplicates
-- purpose: spot-check a specific company to validate duplicates
select *
from layoffs_staging
where company = 'casper';


-- creating a new table that we can delete from
-- purpose: store rn in a physical table so duplicates can be safely deleted
create table `layoffs_staging1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int default null,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int default null,
  `rn` int
) engine=innodb default charset=utf8mb4 collate=utf8mb4_0900_ai_ci;

-- insert data into new table with duplicate flag
insert into layoffs_staging1
select *,
		 row_number()
			over(partition by
				company,
				location,
				industry,
				total_laid_off,
				percentage_laid_off,
				`date`,
				stage,
				country,
				funds_raised_millions) as rn
	from layoffs;
    
-- check for new table creation
-- purpose: verify duplicates were correctly flagged
select *
from layoffs_staging1
where rn > 1;
    
-- deleting duplicates
-- purpose: remove duplicate rows to ensure accurate analysis
delete
from layoffs_staging1
where rn > 1;
    
-- check for deleted duplicates
-- purpose: confirm all duplicates have been removed
select *
from layoffs_staging1
where rn > 1;
    
-- standardizing by column

-- company column
-- purpose: remove leading/trailing spaces so companies are not split during grouping
select company, trim(company)
from layoffs_staging1;

update layoffs_staging1
set company = trim(company);

-- check results after trimming
select *
from layoffs_staging1;

-- industry column
-- purpose: review unique values to identify inconsistent categories
select distinct industry
from layoffs_staging1
order by 1;

-- create staging table
-- purpose: backup table before performing category standardization
create table layoffs_staging2
like layoffs_staging1;

insert into layoffs_staging2
select * from layoffs_staging1;

-- merging similar industries
-- purpose: consolidate similar labels into consistent industry categories
update layoffs_staging2
set industry =
	case
		when industry regexp 'crypto' then 'cryptocurrency'
        when industry in ('fin-tech') then 'finance'
        when industry in ('recruiting') then 'hr'
        else industry
	end;
    
-- check update
select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
order by 1;

-- country column
-- purpose: identify and correct inconsistent country values
select distinct country
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'united states'
where country = 'united states.';

-- check for update
select distinct country
from layoffs_staging2
order by 1;


-- date column
-- purpose: convert date from text to proper date type
select
	`date`,
    str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- converting the date column type
alter table layoffs_staging2
modify column `date` date;

-- note: columns not standardized are either already consistent
-- or too niche to confidently correct without assumptions


-- rebuilding / discarding data (nulls and empty cells)

-- industry column
-- purpose: identify rows with missing or blank industry values
select
	company,
	industry
from layoffs_staging2
where industry is null or industry = ''
order by 1;

-- confirm that these rows truly have missing industries
select
	company,
    location,
	industry
from layoffs_staging2
where company in (
			'airbnb',
            "bally's interactive",
            'carvana',
            'juul');

-- create new table in case of mistakes
-- purpose: backup before filling missing values
create table layoffs_staging3
like layoffs_staging2;

insert into layoffs_staging3
select * from layoffs_staging2;

-- populating rows with missing industries
-- purpose: infer industry based on same company and location
update layoffs_staging2
set industry =
	case
		when company = 'airbnb' and location = 'sf bay area' then 'travel'
		when company = 'carvana' and location = 'phoenix' then 'transportation'
		when company = 'juul' and location = 'sf bay area' then 'consumer'
        else industry
	end
where industry is null or industry = '';

-- check results
select
	company,
    location,
	industry
from layoffs_staging2
where company in (
			'airbnb',
            "bally's interactive",
            'carvana',
            'juul');


-- removing rows where both total_laid_off and percentage_laid_off are null
-- purpose: these rows provide no usable layoff magnitude for analysis
select *
from layoffs_staging2
where total_laid_off is null
	and percentage_laid_off is null;
    
delete
from layoffs_staging2
where total_laid_off is null
	and percentage_laid_off is null;
    
-- confirm removal
select *
from layoffs_staging2
where total_laid_off is null
	and percentage_laid_off is null;

-- removing helper column used for duplicate detection
alter table layoffs_staging2
drop column rn;

-- final cleaned staging table preview
select *
from layoffs_staging2;

-- create final clean table
-- purpose: store a stable, analysis-ready dataset
create table layoffs_clean
like layoffs_staging2;

insert into layoffs_clean
select *
from layoffs_staging2;

-- final verification
select *
from layoffs_clean;



 
