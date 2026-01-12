-- =====================================================================================
-- FINAL CLEAN DATASET
-- =====================================================================================
-- This query simply inspects the final cleaned table that is used for all analysis.
-- At this stage, all data cleaning, deduplication, normalization, and null handling
-- have already been completed upstream.
--
-- From this point onward, the table is treated as read-only and analysis-ready.
-- =====================================================================================

select * 
from layoffs_clean;

-- =====================================================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- =====================================================================================
-- Core Research Question:
-- "Which factor (industry, company stage, or individual company) was most strongly
-- associated with the variation in layoff size between 2020 and 2023?"
--
-- The analysis proceeds by:
-- 1. Establishing dataset scope and coverage
-- 2. Testing company-level concentration
-- 3. Testing whether industry explains company concentration
-- 4. Evaluating company stage as an explanatory factor
-- 5. Comparing concentration across company, industry, and stage
-- =====================================================================================



-- =====================================================================================
-- DATASET SCOPE AND COVERAGE
-- =====================================================================================
-- This query establishes the foundational context of the dataset:
-- - Total number of layoff events
-- - Earliest and latest layoff dates
-- - Number of distinct companies represented
--
-- This ensures that the analysis window (2020–2023) is correct and that
-- conclusions are drawn from a sufficiently broad set of companies.
-- =====================================================================================

select 
	count(*), 
    min(`date`), 
    max(`date`), 
    count(distinct company)
from layoffs_clean;

-- =====================================================================================
-- COMPANY-LEVEL CONCENTRATION ANALYSIS
-- =====================================================================================
-- Objective:
-- Measure how much of the total layoffs are concentrated among the top 10 companies.
--
-- Rationale:
-- If layoffs are primarily driven by individual company decisions, we would expect
-- a small number of companies to account for a disproportionately large share of
-- total layoffs.
--
-- Method:
-- 1. Aggregate total layoffs by company
-- 2. Select the top 10 companies by total layoffs
-- 3. Compare their combined layoffs to total layoffs overall
--
-- Result (computed externally):
-- Top 10 companies account for approximately 26% of total layoffs.
-- =====================================================================================

with top10_company_layoffs_cte as(
select 
	company,
    sum(total_laid_off) as total_company_layoffs
from layoffs_clean
where total_laid_off is not null
group by company
order by total_company_layoffs desc
limit 10),

top_ten as(
select sum(total_company_layoffs) as top_10
from top10_company_layoffs_cte),

total_cte as(
select sum(total_laid_off) as total_layoffs
from layoffs_clean
where total_laid_off is not null
)

select 
	top_ten.top_10, 
	total_cte.total_layoffs, 
    (top_10 / total_layoffs) * 100 as top_10_layoffs_pct
from top_ten , total_cte;

-- =====================================================================================
-- INDUSTRY DISTRIBUTION AMONG TOP 10 COMPANIES
-- =====================================================================================
-- Objective:
-- Determine whether the top 10 companies by layoffs are concentrated within a small
-- number of industries.
--
-- Rationale:
-- If layoffs are primarily industry-driven, the largest-layoff companies should
-- cluster within the same industries.
--
-- Method:
-- 1. Identify the top 10 companies by total layoffs
-- 2. Attach their industry labels
-- 3. Count how many top-10 companies fall into each industry
--
-- Result:
-- The top 10 companies are spread across industries, with no industry containing
-- more than two companies.
--
-- This weakens an industry-driven explanation for company-level concentration.
-- =====================================================================================

with top10_company_layoffs_cte as (
select 
	company,
    industry,
    sum(total_laid_off) as total_company_layoffs
from layoffs_clean
group by company, industry
order by total_company_layoffs desc
limit 10)

select
	industry,
    count(*)
from top10_company_layoffs_cte
group by industry;

-- =====================================================================================
-- COMPANY STAGE ANALYSIS (FREQUENCY AND SEVERITY)
-- =====================================================================================
-- Objective:
-- Evaluate whether company stage explains differences in layoff magnitude.
--
-- Rationale:
-- Company stage captures organizational maturity and scale.
-- Larger, more mature companies may execute fewer but significantly larger layoffs.
--
-- Method:
-- For each stage:
-- - Count number of layoff events
-- - Compute total layoffs
-- - Compute average layoffs per event
--
-- Only rows with known layoff magnitudes are included to ensure meaningful averages.
--
-- Result:
-- Post-IPO companies have the highest total layoffs and highest average layoffs per event.
-- =====================================================================================

select
	stage,
    count(*) as num_events,
    sum(total_laid_off) as total_laid,
    avg(total_laid_off) as avg_laid_off
from layoffs_clean
where total_laid_off is not null
group by stage
order by total_laid desc;

-- =====================================================================================
-- SHARE OF TOTAL LAYOFFS ATTRIBUTABLE TO POST-IPO COMPANIES
-- =====================================================================================
-- Objective:
-- Quantify the proportion of total layoffs coming from Post-IPO companies.
--
-- Rationale:
-- This mirrors the company-level concentration analysis and allows direct comparison
-- between stage-level and company-level explanatory power.
--
-- Result (computed externally):
-- Post-IPO companies account for approximately 53% of total layoffs.
--
-- This indicates that company stage explains a larger share of layoff magnitude
-- than individual company concentration or industry grouping.
-- =====================================================================================

with post_ipo as (
  select
    sum(total_laid_off) as post_ipo_laid
  from layoffs_clean
  where total_laid_off is not null
    and stage = 'Post-IPO'
),
total_layoffs as (
  select
    sum(total_laid_off) as total_laid
  from layoffs_clean
  where total_laid_off is not null
)
select
  post_ipo.post_ipo_laid,
  total_layoffs.total_laid,
  (post_ipo.post_ipo_laid / total_layoffs.total_laid) * 100 as pct_post_ipo
from post_ipo, total_layoffs;

-- =====================================================================================
-- INDUSTRY-LEVEL CONCENTRATION ANALYSIS (TOP 3 INDUSTRIES)
-- =====================================================================================
-- Objective:
-- Measure how much of the total layoffs are accounted for by the top 3 industries.
--
-- Rationale:
-- This provides a comparable concentration metric to company-level and stage-level
-- analyses.
--
-- Method:
-- 1. Aggregate total layoffs by industry
-- 2. Select the top 3 industries by total layoffs
-- 3. Compare their combined layoffs to the overall total
--
-- Result (computed externally):
-- The top 3 industries account for approximately 33% of total layoffs.
--
-- This indicates that industry explains some concentration, but substantially less
-- than company stage.
-- =====================================================================================

with combined as(
	select 
		industry,
		sum(total_laid_off) as total
	from layoffs_clean
    where total_laid_off is not null
	group by industry
	order by 2 desc
	limit 3), 

combined_total as(
	select sum(total) as top_3
    from combined),
    
total_layoffs as (
  select
    sum(total_laid_off) as total_laid
  from layoffs_clean
  where total_laid_off is not null)

select 
	combined_total.top_3, 
    total_layoffs.total_laid,
    (top_3 / total_laid) * 100 as pct_industry
from combined_total, total_layoffs;
