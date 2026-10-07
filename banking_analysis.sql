--------------------- Analysis ---------------------------


-- 1. Which loyalty tier (Jade, Silver, Gold, Platinum) has the highest deposits and loans?


select loyalty_classification,
		Round(sum(bank_deposits)::numeric,2) as Total_deposits,
		Round(Sum(bank_loans)::numeric,2) as Total_loans
from banking_customers
group by loyalty_classification
order by Total_deposits desc


-- Ans : Jade has the highest deposits (₹927.14M) and loans (₹806.15M).



-- 2. How do income, deposits, and loans change across age groups?



Select age_group,
	Round(Sum(estimated_income)::numeric,2) as total_income,
	Round(Sum(bank_loans)::numeric,2) as Total_loans,
	Round(Sum(bank_deposits)::numeric,2) as Total_deposits
from banking_customers
Group by age_group
ORDER BY age_group

-- Ans: Income, deposits and loans all increase with age.
-- 0-17 is the lowest (income 7.3M, deposits 26.2M, loans 21.9M).
-- The three middle groups (18-30, 31-45, 46-60) rise steadily, and the
-- gap between 31-45 and 46-60 is small (income 112.1M vs 114.5M).
-- 61+ is the highest in all three (income 185.3M, deposits 725.2M, loans 637.3M).


-- 3. Which customer segment has the highest loan-to-deposit ratio? (This is a risk indicator.)

select age_group,
		Sum(bank_loans) as total_loans,
		Sum(bank_deposits) as total_deposits,
		Round( (Sum(bank_loans) / nullif( Sum(bank_deposits),0))::numeric,2) as loan_to_deposit_ratio
from banking_customers
Group by age_group
Order by loan_to_deposit_ratio desc
limit 1

-- Ans: The 46-60 age group has the highest loan-to-deposit ratio (0.90).
-- Its loans are about 90% of its deposits (406.9M vs 449.7M).
-- A ratio below 1 means deposits are still higher than loans,
-- so no age group lends out more than it holds.



-- 4. Is there any relationship between Fee Structure (High, Mid, Low) and loyalty tier or account balances?


----  relationship between Fee Structure and loyalty tier

select fee_structure, loyalty_classification,
		count(*) as customers,
		Round(100.0 * count(*)/sum(count(*)) over ( partition by fee_structure ) ,2) as pct_within_fee
from banking_customers
group by fee_structure, loyalty_classification
order by fee_structure, loyalty_classification

-- Ans: There is no strong relationship between Fee Structure and loyalty tier.
-- Jade is the largest tier in every Fee Structure (High 45.3%, Mid 44.0%, Low 42.7%).
-- Silver, Gold and Platinum shares also stay in a narrow range across High, Mid and Low
-- (for example Platinum: 9.5% in High, 12.1% in Mid, 10.9% in Low).


----  relationship between Fee Structure and account balances

select fee_structure,
		count(*) as customers,
		Round(Avg(bank_loans)::numeric,2) as Avg_loans,
		Round(Avg(bank_deposits)::numeric,2) as Avg_deposits,
		Round(Avg(checking_accounts)::numeric,2) as Avg_checking,
		Round(Avg(saving_accounts)::numeric,2) as Avg_saving
from banking_customers
group by fee_structure
order by fee_structure

-- Ans: There is no clear relationship between Fee Structure and account balances.
-- Average balances are close across High, Mid and Low (differences are roughly 5% or less).
-- High has the highest avg deposits (683.6K) and checking (330.3K),
-- but Mid has the highest avg loans (607.6K) and the lowest deposits, checking and saving.
-- The balances do not rise or fall steadily from Low to Mid to High.



-- 5. Which occupations and nationalities are the most valuable to the bank?

--Occupation (top 10)

select  occupation,
		Round(Sum(bank_deposits)::numeric,2) as Total_deposits
from banking_customers
group by occupation
order by Total_deposits desc
limit 10

-- Ans: Structural Analysis Engineer is the most valuable occupation by total deposits (22.84M),
-- followed by Database Administrator III (20.62M) and Social Worker (19.96M).


-- nationalities

select  nationality,
		Round(Sum(bank_deposits)::numeric,2) as Total_deposits
from banking_customers
group by nationality
order by Total_deposits desc

-- Ans: European customers are the most valuable by total deposits (873.97M),
-- followed by Asian (515.31M), American (335.30M), Australian (169.04M) and African (121.06M).
-- Valuable is measured here as total deposits.




-- 6. How has customer growth changed by joining year?

SELECT join_year,
       COUNT(*) AS new_customers
FROM banking_customers
GROUP BY join_year
ORDER BY join_year;

-- Ans: Customer growth was steady from 1995 to 2018 (about 90-126 new customers per year).
-- It jumped in 2019 (187) and peaked in 2020 (248), then fell to 194 in 2021.
-- No customers joined in 1997 and 1998.


-- 7. What is the relationship between credit card balance and income?

select 
		Round(CORR(estimated_income,credit_card_balance)::numeric,3) as correlation
from banking_customers;

-- Ans: Income and credit card balance have a weak-to-moderate positive relationship (correlation = 0.299).
