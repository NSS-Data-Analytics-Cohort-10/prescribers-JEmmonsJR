-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT 
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claims
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
GROUP BY pr.npi
ORDER BY tot_claims DESC
LIMIT 1;

--ANSWER: npi:1881634483 total claims: 99,707
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT 
	pr.npi,
	pr.nppes_provider_first_name,
	pr.nppes_provider_last_org_name,
	pr.specialty_description,
	SUM(pn.total_claim_count) AS tot_claims
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
GROUP BY
	pr.npi,
	pr.nppes_provider_first_name,
	pr.nppes_provider_last_org_name,
	pr.specialty_description
ORDER BY tot_claims DESC
LIMIT 1;

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT 
	pr.specialty_description,
	SUM(pn.total_claim_count) AS tot_claims
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
GROUP BY pr.specialty_description
ORDER BY tot_claims DESC
LIMIT 1;

--ANSWER: Family Practice; 9,752,347
--     b. Which specialty had the most total number of claims for opioids?

SELECT 
	pr.specialty_description,
	SUM(pn.total_claim_count) AS tot_claims
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE LOWER(drug.opioid_drug_flag) LIKE 'y'
GROUP BY pr.specialty_description
ORDER BY tot_claims DESC
LIMIT 1;

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT
	pr.specialty_description AS specialty,
	COUNT(pn.drug_name) AS drug_count
FROM prescriber AS pr
LEFT JOIN prescription AS pn
USING(npi)
GROUP BY pr.specialty_description
HAVING COUNT(pn.drug_name) = 0;

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?


CREATE TEMP TABLE tot_op AS
SELECT 
	pr.specialty_description,
	SUM(pn.total_claim_count) AS tot_op_claim
FROM prescriber AS pr
LEFT JOIN prescription AS pn
USING(npi)
LEFT JOIN drug AS d
USING(drug_name)
WHERE d.opioid_drug_flag = 'Y'
GROUP BY pr.specialty_description;

SELECT 
	pr.specialty_description,
	(t.tot_op_claim/SUM(pn.total_claim_count))*100 AS percentage
FROM prescriber AS pr
LEFT JOIN prescription AS pn
USING(npi)
LEFT JOIN tot_op AS t
USING(specialty_description)
GROUP BY pr.specialty_description, t.tot_op_claim
ORDER BY percentage DESC;

DROP TABLE tot_op_claim;

--ANSWER: Case Manager/Care Corrdinator 72%

-- SELECT
-- 	pr.specialty_description AS specialty,
-- 	pn.total_claim_count/SUM(pn.total_claim_count)
-- FROM prescriber AS pr
-- INNER JOIN prescription AS pn
-- USING(npi)
-- INNER JOIN drug
-- USING(drug_name)
-- GROUP BY pr.specialty_description, pn.total_claim_count
	
-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT
	d.generic_name,
	CAST(SUM(p.total_drug_cost) AS MONEY) AS tot_drug_cost
FROM prescription AS p
LEFT JOIN drug AS d
USING(drug_name)
GROUP BY d.generic_name
ORDER BY tot_drug_cost DESC
LIMIT 1;

--ANSWER:Insulin; 104,264,066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT
	d.generic_name,
	ROUND(SUM(p.total_drug_cost)/SUM(p.total_day_supply), 2) AS cost_per_day
FROM prescription AS p
LEFT JOIN drug AS d
USING(drug_name)
GROUP BY d.generic_name
ORDER BY cost_per_day DESC
LIMIT 1;

--ANSWER: C1 Esterase Inhibitor $3,495.22

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT
	drug_name,
	CASE
		WHEN opioid_drug_flag LIKE 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag LIKE 'Y' THEN 'antibiotic'
		ELSE 'neither'
		END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	CASE
		WHEN opioid_drug_flag LIKE 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag LIKE 'Y' THEN 'antibiotic'
		ELSE 'neither'
		END AS drug_type,
	CAST(SUM(p.total_drug_cost) AS MONEY) AS tot_spent
FROM drug AS d
LEFT JOIN prescription AS p
USING(drug_name)
GROUP BY drug_type
ORDER BY tot_spent DESC;

--ANSWER: Spent the most on Opioids; $105,080,626,37

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(*)
FROM CBSA
WHERE cbsaname LIKE '%TN%'

--Answer: 56

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT
	c.cbsaname,
	SUM(p.population) AS tot_pop
FROM cbsa AS c
INNER JOIN population AS p
USING(fipscounty)
GROUP BY c.cbsaname
ORDER BY tot_pop;

--ANSWER: Highest: Nashville 1,830,410 LOWEST: Morristown 116,352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT
	p.population AS pop,
	f.county
FROM population AS p
LEFT JOIN fips_county AS f
USING(fipscounty)
LEFT JOIN cbsa AS c
USING(fipscounty)
WHERE c.cbsa IS NULL
ORDER by pop DESC
LIMIT 1;
	
--ANSWER: SEVIER; 95,523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT
	drug_name,
	total_claim_count AS total_claims
FROM prescription
WHERE total_claim_count >= 3000;
--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT
	p.drug_name,
	p.total_claim_count AS total_claims,
	d.opioid_drug_flag
FROM prescription AS p
LEFT JOIN drug AS d
USING(drug_name)
WHERE total_claim_count >= 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT
	p.drug_name,
	p.total_claim_count AS total_claims,
	d.opioid_drug_flag,
	pr.nppes_provider_last_org_name AS last_name,
	pr.nppes_provider_first_name AS first_name
FROM prescription AS p
LEFT JOIN drug AS d
USING(drug_name)
LEFT JOIN prescriber AS pr
USING(npi)
WHERE total_claim_count >= 3000
ORDER BY last_name, first_name;


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT
	p.npi,
	d.drug_name
FROM prescriber AS p
CROSS JOIN drug AS d
WHERE p.specialty_description = 'Pain Management'
AND p.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
ORDER BY d.drug_name;

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT
	p.npi,
	d.drug_name,
	pn.total_claim_count AS tot_claims
FROM prescriber AS p
CROSS JOIN drug AS d
LEFT JOIN prescription AS pn
USING(drug_name, npi)
WHERE p.specialty_description = 'Pain Management'
AND p.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y';

	
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT
	p.npi,
	d.drug_name,
	pn.total_claim_count AS tot_claims,
	COALESCE(pn.total_claim_count, 0)
FROM prescriber AS p
CROSS JOIN drug AS d
LEFT JOIN prescription AS pn
USING(drug_name, npi)
WHERE p.specialty_description = 'Pain Management'
AND p.nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y';
