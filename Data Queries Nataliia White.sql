/* Query Part */

/*  Query 1 */
/* Age Distribution of Patients with Totals */
/* This query sorts patients by age and counts how many patients are in each age group.
Why it's good for the hospital: Understanding the age breakdown helps the hospital customize healthcare 
services, allocate resources, and create specific health programs for different age groups.*/ 

/* There was a suspiciously high number of people listed as being over 100 
years old. To address this, we applied a filter that includes only those 
records where the death date is not recorded (death_date IS NULL) and the 
patient's age is 100 years or younger (EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) <= 100)." 
It's possible that not every record has been updated with the relevant death date. */ 

SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 30 THEN '18-30'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 30 AND 50 THEN '30-50'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 50 AND 65 THEN '50-65'
        ELSE 'Over 65'
    END AS age_group,
    COUNT(*) AS patient_count
FROM 
    patients
WHERE 
    deathdate IS NULL
    AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) <= 100
GROUP BY 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 30 THEN '18-30'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 30 AND 50 THEN '30-50'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 50 AND 65 THEN '50-65'
        ELSE 'Over 65'
    END
ORDER BY 
    age_group;
	
/* This indicates that the majority of our patients are between 30 and 50 years old, althougth age is 
contributed pretty even */


/* Query 2 */
/* Patient Demographics and Avarage Healthcare Costs */
/* The query shows a summary of patient details, such as the proportion of male and female patients, the average 
age of patients, and the typical healthcare costs and coverage. This information is important for financial 
planning and finding any differences in healthcare. Healthcare providers and insurers can use this information 
to customize their services, update coverage plans, and address any differences in healthcare costs or coverage
based on gender. */

SELECT 
    GENDER,
    COUNT(*) AS patient_count,
    AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, BIRTHDATE))) AS avg_age,
    ROUND(AVG(HEALTHCARE_EXPENSES),2) AS avg_expenses,
    ROUND(AVG(HEALTHCARE_COVERAGE),2) AS avg_coverage
FROM 
    patients
GROUP BY 
    GENDER
ORDER BY 
    patient_count DESC;

/* There are slightly more females in the dataset.
Males have a slightly higher average age.
Females have significantly higher average coverage than males, although 
their average expenses are quite similar. This could suggest differences in 
insurance policies, health conditions, or other factors influencing coverage
levels. We will investigate this futher in Python. */ 

/* Query 3 */
/* Comparison of top 5 most common conditions, procedures, and medications */
/* the description column has disorders and observations 
NOT LIKE '%(Finding)% filter allows us to eliminate observations 
focusing solely on disorders */

/* The query aims to identify and compare the top 5 most common conditions,
procedures, and medications in the healthcare system. The business value 
lies in providing a snapshot of prevalent health issues and common treatments
for resource allocation and healthcare planning. Healthcare providers can use
this information to ensure they are well-equipped to handle common health 
issues, stock frequently prescribed medications, and have the necessary 
resources for common procedures. */

(SELECT 'Condition' AS type, DESCRIPTION, COUNT(*) AS count
 FROM conditions
 WHERE DESCRIPTION NOT LIKE '%(Finding)%'
 GROUP BY DESCRIPTION
 ORDER BY count DESC
 LIMIT 5)
UNION ALL
(SELECT 'Procedure' AS type, DESCRIPTION, COUNT(*) AS count
 FROM procedures
 GROUP BY DESCRIPTION
 ORDER BY count DESC
 LIMIT 5)
UNION ALL
(SELECT 'Medication' AS type, DESCRIPTION, COUNT(*) AS count
 FROM medications
 GROUP BY DESCRIPTION
 ORDER BY count DESC
 LIMIT 5);

/* Query 4 */
/* Provider Speciality Analysis*/
/* This query examines the different types of medical specialties, displaying how many patient visits each 
type of provider has and the average cost of claims for each. This information helps identify the most active 
specialties and their associated costs, which is important for deciding on staffing and making financial plans.
Hospital administrators can use this information to ensure they have enough staff in high-demand specialties 
and to look into any unusually high claim costs in certain specialties. */

SELECT p.NAME, p.SPECIALITY, COUNT(e.Id) AS encounter_count, ROUND(AVG(e.TOTAL_CLAIM_COST),2) AS avg_claim_cost
FROM providers p 
LEFT JOIN encounters e ON p.Id = e.PROVIDER
GROUP BY p.Id, p.NAME, p.SPECIALITY
ORDER BY encounter_count DESC
LIMIT 10;

/* These are 10 most active general practitioners (based on encounter count), along with their average claim costs.
For instance, Demetrice Crooks has managed the most encounters (2,184) with an average claim cost 
of $3,021.68, while Regena Kunde has the highest average claim cost of $6,404.46 but with fewer encounters 
(877). */

/* Query 5 */
/* Encounter Class Analysis */
/* This query shows the different healthcare services used in various counties. It includes information on 
the number of encounters, average claim cost, and average payer coverage. The goal is to help plan healthcare 
services and understand their costs in different regions. This information can be used by healthcare planners
to identify areas with high demand for specific types of healthcare services and to understand the financial 
impact of these services in each region. */

SELECT 
    p.COUNTY, 
    e.ENCOUNTERCLASS, 
    COUNT(*) AS encounter_count,
    ROUND(AVG(e.TOTAL_CLAIM_COST),2) AS avg_claim_cost,
    ROUND(AVG(e.PAYER_COVERAGE),2) AS avg_payer_coverage
FROM 
    encounters e
JOIN 
    patients p ON e.PATIENT = p.Id
GROUP BY 
    p.COUNTY, e.ENCOUNTERCLASS
ORDER BY 
    p.COUNTY, encounter_count DESC;

/* In Barnstable, the average cost of Wellness encounters is about $2,777, with an average payment from insurers 
of $960. However, for Urgentcare encounters, the average cost is $3,192, but the insurer typically covers more 
at $2,697.
In Essex county, Ambulatory services have the highest average cost at $8,046, but the average insurance coverage 
is $1,840, indicating that patients may face significant out-of-pocket expenses.
In Suffolk county, Urgentcare encounters have a very high average cost of $23,132, but the insurer's coverage 
is relatively low at $492, suggesting high patient expenses.
In Worcester county, the average costs for Ambulatory and Inpatient encounters are relatively high at $4,566 
and $8,549 respectively, with particularly low insurance coverage for Inpatient services at $547. */ 


/* Query 6 */
/* Medication Cost Analysis */
/* The query analyzes medication costs, showing the most frequently prescribed medications along with their 
average base cost, payer coverage,and total cost. This provides insights for pharmacy management and healthcare
cost control, helping healthcare providers and insurers negotiate better prices, identify potential cost savings,
and ensure adequate stock of commonly used medications. */

SELECT 
    DESCRIPTION,
	CODE,
    COUNT(*) AS prescription_count,
    ROUND(AVG(BASE_COST),2) AS avg_base_cost,
    ROUND(AVG(PAYER_COVERAGE),2) AS avg_payer_coverage,
    ROUND(AVG(TOTALCOST),2) AS avg_total_cost
FROM 
    medications
GROUP BY 
    DESCRIPTION, CODE
ORDER BY 
    prescription_count DESC, avg_total_cost DESC
LIMIT 10;

/* Lisinopril 10 Mg Oral Tablet and Hydrochlorothiazide 25 Mg Oral Tablet are the most prescribed medications 
with 8,166 and 7509 prescriptions. (This is used to treat high blood pressure). As stated in the previous query, 
prediabetes is one of the five most common conditions in this dataset, so that makes sense.

Certain medications like insulin and inhalers have very high total costs. While some payer coverage 
is present, it is not enough to offset the significant expenses patients might have. Many medications, 
despite having a low base cost, seem to have minimal to no payer coverage, resulting in higher total costs 
for patients. */


/* Query 7 */
/* City-Level Analysis of Patients with Above-Average Healthcare Expenses */
/* Analyzing patients with healthcare expenses above the average, sorted by 
city to prioritize areas with high expenses. Businesses can use this to 
implement targeted interventions efficiently, while policymakers can pinpoint
cities that may require additional resources or interventions. This data 
helps in making informed decisions to reduce costs and improve health.*/ 

WITH city_expense AS (
    SELECT
        p.CITY,
        COUNT(*) AS total_patients,
        COUNT(*) FILTER (WHERE p.HEALTHCARE_EXPENSES > (SELECT AVG(HEALTHCARE_EXPENSES) FROM patients)) AS above_avg_expense_patients,
        AVG(p.HEALTHCARE_EXPENSES) AS avg_healthcare_expense
    FROM 
        patients p
    GROUP BY 
        p.CITY
),
city_ranking AS (
    SELECT
        CITY,
        above_avg_expense_patients,
        avg_healthcare_expense,
        RANK() OVER (ORDER BY above_avg_expense_patients DESC) AS city_rank
    FROM
        city_expense
)
SELECT
    CITY,
    above_avg_expense_patients,
    avg_healthcare_expense,
    city_rank,
    CASE 
        WHEN avg_healthcare_expense >= 1500000 THEN 'High'
        WHEN avg_healthcare_expense BETWEEN 750000 AND 1500000 THEN 'Medium'
        ELSE 'Low'
    END AS expense_category
FROM
    city_ranking
ORDER BY
    city_rank ASC;


/* Query 8 */
/* Average Duration of Encounters */ 
/* The query calculates the average duration of encounters for each encounter
class. Understanding the typical duration of different types of encounters 
is crucial for scheduling, staffing, and resource allocation in healthcare.
This information can help optimize scheduling, ensure appropriate staffing 
levels, and identify potential inefficiencies in care delivery. */

SELECT 
    ENCOUNTERCLASS,
    AVG(EXTRACT(EPOCH FROM (STOP - START)) / 3600) AS avg_duration_hours
FROM 
    encounters
GROUP BY 
    ENCOUNTERCLASS
ORDER BY 
    avg_duration_hours DESC;

/* Query 9 */
/* Top 10 Most Expensive Procedures */
/*  query to identify the top 10 most expensive procedures based on 
average cost along with count. This information can help with financial 
planning and cost management for businesses. This includes negotiating better
prices, finding ways to save money, and making sure that high-cost procedures
are used appropriately by healthcare administrators. */

SELECT 
    CODE,
    DESCRIPTION,
    AVG(BASE_COST) AS avg_cost,
    COUNT(*) AS procedure_count
FROM 
    procedures
GROUP BY 
    CODE, DESCRIPTION
ORDER BY 
    avg_cost DESC
LIMIT 10;

/* Query 10 */
/* Patients with Multiple Chronic Conditions with Total Condition Count */
/* This query finds patients with multiple chronic conditions and ranks 
them based on the number of conditions. The goal is to find high-risk 
patients who may need more intensive care management. Care coordinators can 
then prioritize patients for care management programs based on this 
information, ensuring that those with multiple chronic conditions get the
attention and resources they need. */ 

SELECT 
    p.ID, 
    p.FIRST, 
    p.LAST, 
    COUNT(DISTINCT c.CODE) AS chronic_condition_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT c.CODE) DESC) AS rank
FROM 
    patients p
JOIN 
    conditions c ON p.ID = c.PATIENT
WHERE 
    c.STOP IS NULL OR c.STOP > CURRENT_DATE
GROUP BY 
    p.ID, p.FIRST, p.LAST
HAVING 
    COUNT(DISTINCT c.CODE) > 1
ORDER BY 
    chronic_condition_count DESC
LIMIT 10;



/* Query 11 */
/* Geographical Immunization Coverage */
/* The query calculates the immunization rate for each county. This is 
important for public health planning and interventions because understanding 
the geographical variations is crucial. It helps public health officials 
identify areas with low immunization rates for targeted interventions and 
vaccination campaigns.*/ 

SELECT 
    p.COUNTY,
    COUNT(DISTINCT p.Id) AS total_patients,
    COUNT(DISTINCT i.PATIENT) AS immunized_patients,
    CAST((COUNT(DISTINCT i.PATIENT)::float / COUNT(DISTINCT p.Id)) * 100 AS DECIMAL(5,2)) AS immunization_rate
FROM 
    patients p
LEFT JOIN 
    immunizations i ON p.Id = i.PATIENT
GROUP BY 
    p.COUNTY
ORDER BY 
    immunization_rate DESC;


/* Query 12 */
/* Patients with Above Average Healthcare Expenses with Overall Comparison */
/* The following query finds patients with higher than average healthcare 
expenses and compares their costs to the overall average. This helps 
identify high-cost patients for cost management strategies. These strategies
can benefit from more intense care management or preventive interventions 
to reduce future healthcare costs. */

SELECT 
    ID, 
    FIRST, 
    LAST, 
    HEALTHCARE_EXPENSES,
    AVG(HEALTHCARE_EXPENSES) OVER () AS overall_avg_expenses
FROM 
    patients
WHERE 
    HEALTHCARE_EXPENSES > (SELECT AVG(HEALTHCARE_EXPENSES) FROM patients)
ORDER BY 
    HEALTHCARE_EXPENSES DESC
LIMIT 10;

/* Query 13 */
/* Patients with Their Most Recent Condition  */
/* The query gathers details about each patient's most recent condition, 
providing a brief summary of their current health. Healthcare providers 
can use this information to quickly understand a patient's most recent 
health issue, which is valuable for managing ongoing care and helpful for
follow-up appointments or when coordinating care across different providers.*/

SELECT p.ID, p.FIRST, p.LAST, c.DESCRIPTION, c.START
FROM patients p
JOIN conditions c ON p.ID = c.PATIENT
WHERE c.START = (
    SELECT MAX(START) 
    FROM conditions 
    WHERE PATIENT = p.ID
) AND c.DESCRIPTION NOT LIKE '%(Finding)%'
LIMIT 10;


/* Query 14 */
/* Organizations and Their Top Provider  */
/* The query shows the top healthcare providers for each organization based 
on the number of encounters. This information is important for evaluating
performance and allocating resources. Healthcare administrators can use it to
find high-performing providers, understand which specialties are in demand, 
and make informed decisions about staffing and resource allocation. */

SELECT o.NAME AS org_name, p.NAME AS top_provider, p.SPECIALITY
FROM organizations o
JOIN providers p ON o.ID = p.ORGANIZATION
WHERE p.ID = (
    SELECT PROVIDER
    FROM encounters
    WHERE ORGANIZATION = o.ID
    GROUP BY PROVIDER
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
LIMIT 10;

SELECT 
    o.NAME AS org_name, 
    p.NAME AS top_provider, 
    p.SPECIALITY, 
    COUNT(e.ID) AS encounter_count
FROM 
    organizations o
JOIN 
    providers p ON o.ID = p.ORGANIZATION
JOIN 
    encounters e ON p.ID = e.PROVIDER
WHERE 
    p.ID = (
        SELECT 
            PROVIDER
        FROM 
            encounters
        WHERE 
            ORGANIZATION = o.ID
        GROUP BY 
            PROVIDER
        ORDER BY 
            COUNT(*) DESC
        LIMIT 1
    )
GROUP BY 
    o.NAME, p.NAME, p.SPECIALITY
ORDER BY 
    encounter_count DESC
LIMIT 10;



/* Query 15 */
/* Comparison of average costs for encounters, procedures, and medications:*/
/* This query compares the average costs of healthcare services, procedures, 
and medications. This helps with financial planning and cost management. 
Healthcare administrators and financial planners can use this information to 
find potential cost savings, make better decisions about where to allocate 
resources and how to set prices, and understand the main sources of 
healthcare costs. */ 

WITH encounter_costs AS (
    SELECT 'Encounter' AS type, AVG(TOTAL_CLAIM_COST) AS avg_cost
    FROM encounters
),
procedure_costs AS (
    SELECT 'Procedure' AS type, AVG(BASE_COST) AS avg_cost
    FROM procedures
),
medication_costs AS (
    SELECT 'Medication' AS type, AVG(TOTALCOST) AS avg_cost
    FROM medications
)
SELECT type, avg_cost
FROM encounter_costs
UNION ALL
SELECT type, avg_cost
FROM procedure_costs
UNION ALL
SELECT type, avg_cost
FROM medication_costs
ORDER BY avg_cost DESC;
