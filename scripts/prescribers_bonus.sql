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
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.