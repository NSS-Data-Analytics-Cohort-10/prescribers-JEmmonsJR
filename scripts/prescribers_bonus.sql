-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT
	COUNT(pr.npi)
FROM prescriber AS pr
WHERE NOT EXISTS (SELECT 1 
				 FROM prescription AS pn
				WHERE pn.npi = pr.npi)

--ANSWER: 4458

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.

SELECT
	d.generic_name,
	COUNT(pn.drug_name) AS tot_drug
FROM prescription AS pn
INNER JOIN drug AS d
USING(drug_name)
INNER JOIN prescriber AS pr
USING(npi)
WHERE pr.specialty_description = 'Family Practice'
GROUP BY d.generic_name
ORDER BY tot_drug DESC
LIMIT 5;

--ANSWER: Metformin HCL 2296, Albuterol Sulfate 2246, Levothyroxine Sodium 2084, Potassium Chloide 1992, Diltiazem HCL 1881

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT
	d.generic_name,
	COUNT(pn.drug_name) AS tot_drug
FROM prescription AS pn
INNER JOIN drug AS d
USING(drug_name)
INNER JOIN prescriber AS pr
USING(npi)
WHERE pr.specialty_description = 'Cardiology'
GROUP BY d.generic_name
ORDER BY tot_drug DESC
LIMIT 5;

--ANSWER: Diltazem HCL 961, Potassium Chloride 634, Nitroglycerin 502, Warfarin Sodoum 501, Digoxin 480

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

SELECT
	d.generic_name,
	COUNT(pn.drug_name) AS tot_drug
FROM prescription AS pn
INNER JOIN drug AS d
USING(drug_name)
INNER JOIN prescriber AS pr
USING(npi)
WHERE pr.specialty_description = 'Cardiology'
OR pr.specialty_description = 'Family Practice'
GROUP BY d.generic_name
ORDER BY tot_drug DESC
LIMIT 5;

--AMSWER: Diliazem HCL 2842, Potassium Chloride 2626, Metformin HCL 2363, Albuterol Sulfate 2275, Levothyroxine Sodium 2213

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
WHERE LOWER(pr.nppes_provider_city) = 'nashville'
GROUP BY pr.npi
ORDER BY tot_claim DESC
LIMIT 5;

-- --ANSWER: 
-- 1538103692	53622
-- 1497893556	29929
-- 1659331924	26013
-- 1881638971	25511
-- 1962499582	23703
	
--     b. Now, report the same for Memphis.

SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
FROM prescriber AS pr
INNER JOIN prescription AS pn
USING(npi)
WHERE LOWER(pr.nppes_provider_city) = 'memphis'
GROUP BY pr.npi
ORDER BY tot_claim DESC
LIMIT 5;

--ANSWER:
-- 1346291432	65659
-- 1225056872	62301
-- 1801896881	40169
-- 1669470316	39491
-- 1275601346	36190

--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

SELECT
	pr.nppes_provider_city,
	n.*,
	m.*,
	k.*,
	c.*
FROM prescriber AS pr
INNER JOIN 
	(SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
	FROM prescriber AS pr
	INNER JOIN prescription AS pn
	USING(npi)
	WHERE LOWER(pr.nppes_provider_city) = 'nashville'
	GROUP BY pr.npi
	ORDER BY tot_claim DESC
	LIMIT 5) AS n
USING(npi)
FULL OUTER JOIN 
	(SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
	FROM prescriber AS pr
	INNER JOIN prescription AS pn
	USING(npi)
	WHERE LOWER(pr.nppes_provider_city) = 'memphis'
	GROUP BY pr.npi
	ORDER BY tot_claim DESC
	LIMIT 5) AS m
USING(npi)
FULL OUTER JOIN 
	(SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
	FROM prescriber AS pr
	INNER JOIN prescription AS pn
	USING(npi)
	WHERE LOWER(pr.nppes_provider_city) = 'knoxville'
	GROUP BY pr.npi
	ORDER BY tot_claim DESC
	LIMIT 5) AS k
USING(npi)
FULL OUTER JOIN 
	(SELECT
	pr.npi,
	SUM(pn.total_claim_count) AS tot_claim
	FROM prescriber AS pr
	INNER JOIN prescription AS pn
	USING(npi)
	WHERE LOWER(pr.nppes_provider_city) = 'chattanooga'
	GROUP BY pr.npi
	ORDER BY tot_claim DESC
	LIMIT 5) AS c
USING(npi)

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.