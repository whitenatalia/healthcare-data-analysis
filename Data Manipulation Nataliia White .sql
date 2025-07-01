/* Data Manipulation */ 
/* In this part of the project, I will perform a mix of queries. 
Some queries will be based on actual data, while others will be based on imaginary 
scenarios. I'm using this approach to complete this section of the project because 
my data is synthetic and relatively clean, requiring minimal manipulation. */


/* Patients Table */
SELECT * FROM patients;

/* Query 1 */
/* This query fills missing values in the ZIP code based on the county 
where patients reside. The values are updated to the most frequent ZIP code
within each group.*/ 

SELECT 
    p1.id, 
    p1.county, 
    p1.zip AS old_zip,
    (
        SELECT MODE() WITHIN GROUP (ORDER BY p2.zip)
        FROM patients p2
        WHERE p2.county = p1.county
        AND p2.zip IS NOT NULL
        AND p2.zip != ''
    ) AS new_zip
FROM patients p1
WHERE p1.zip IS NULL OR p1.zip = '';


UPDATE patients p1
SET ZIP = (
    SELECT MODE() WITHIN GROUP (ORDER BY ZIP)
    FROM patients p2
    WHERE p2.county = p1.county
    AND p2.ZIP IS NOT NULL
    AND p2.ZIP != ''
)
WHERE p1.ZIP IS NULL OR p1.ZIP = '';

/* Query 2 */
/* In this dataset, the 'first', 'last', or 'maiden' name fields end with three numbers. 
This query removes those numbers at the end. */

SELECT id, first AS original_first, 
       REGEXP_REPLACE(first, '\d+$', '') AS cleaned_first,
       last AS original_last, 
       REGEXP_REPLACE(last, '\d+$', '') AS cleaned_last,
       maiden AS original_maiden,
       REGEXP_REPLACE(maiden, '\d+$', '') AS cleaned_maiden
FROM patients
WHERE first ~ '\d+$' OR last ~ '\d+$' OR maiden ~ '\d+$';


UPDATE patients
SET first = REGEXP_REPLACE(first, '\d+$', ''),
    maiden = REGEXP_REPLACE(maiden, '\d+$', ''),
    last = REGEXP_REPLACE(last, '\d+$', '');

/* Query 3 */
/* Adding a new patient */
/* This query is used to add a new patient record to a healthcare database, 
containing personal, medical, and financial information. */

INSERT INTO patients (id, birthdate, ssn, drivers, passport, prefix, 
	first, last, maiden, marital, race, ethnicity, gender, birthplace, 
	address, city, state, county, zip, lat, lon, healthcare_expenses, 
	healthcare_coverage) 
VALUES ('c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7', 
        '1985-07-22', '888-45-1234', 'S99919823', 'X55276438X', 'Dr.', 
        'Marcellus', 'Mayer', 'Davis', 'M', 'white', 'nonhispanic', 
        'M', 'Concord, Massachusetts, US', 
        '7898 Boyle Junction Suite 209', 'Concord', 'Massachusetts', 
        'Middlesex County', '01742',  42.457291, -71.348898, 
        715000.00, 310.25);

/* Validation query */
SELECT * FROM patients
WHERE id = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';

/* Query 4 */
/* We are removing the word "County" from the county column to eliminate redundancy 
in the data. This standardization improves data consistency and reduces unnecessary
repetition in the county names. */

UPDATE patients
SET county = TRIM(REPLACE(county, ' County', ''))
WHERE county LIKE '% County';

/* Query 5 */
/* This patient's marital status has recently changed, 
so we need to update this in our dataset.  
This ensures that the patient's information remains current and accurate. */

UPDATE patients
SET marital = 'M'
WHERE id = '961f61f8-ed32-f113-8450-192064b49aa9';

/* Validation query */
SELECT id, first, last, marital
FROM patients
WHERE id = '961f61f8-ed32-f113-8450-192064b49aa9';


/* Encounters Table */
SELECT * FROM encounters;

/* Query 1 */
/* Update the 'encounterclass' column to capitalize the first letter of each word. */
UPDATE encounters
SET encounterclass = INITCAP(encounterclass)
WHERE encounterclass IS NOT NULL;

/* Query 2 */
/* Update descriptions to ensure the first word starts with a capital letter. */

UPDATE encounters
SET description = regexp_replace(description, '^(\w)', '\u\1')
WHERE description ~ '^[a-z]';

/* Query 3 */
/* Update the 'description' column to make all text lowercase except for the first word. */
UPDATE encounters
SET description = CONCAT(
    INITCAP(SUBSTRING(description FROM '^[^\s]+')), -- Capitalize the first word
    LOWER(SUBSTRING(description FROM '\s.*'))      -- Convert the rest of the text to lowercase
)
WHERE description IS NOT NULL
AND description ~ '\s';  -- Ensures there is more than one word

/* Query 4 */
/* Removing extra spaces from description column */
UPDATE encounters
SET description = TRIM(REGEXP_REPLACE(description, '\s+', ' ', 'g'))
WHERE description IS NOT NULL;

/* Validation query */
SELECT reasondescription 
FROM encounters
GROUP BY reasondescription;

/* Query 5 */
/* Insert a new entry into the encounters table. */
INSERT INTO encounters (
		ID, START, STOP, PATIENT, ORGANIZATION, PROVIDER, PAYER, 
        ENCOUNTERCLASS, CODE, DESCRIPTION, BASE_ENCOUNTER_COST, 
        TOTAL_CLAIM_COST, PAYER_COVERAGE, REASONCODE, REASONDESCRIPTION
	)
VALUES (
		'c5f8b1f8-6903-744e-18e7-03496db30723',
		'2011-09-14 05:53:58',
		'2011-09-14 06:08:58',
		'2f031d4a-b070-ce15-6372-30c8fecf1164',
		NULL,
		'82608ebb-037c-3cef-9d34-3736d69b29e8',
		NULL,
		'Outpatient',
		'698314001',
		'Consultation for treatment',
		129.16,
		129.16,
		0.00,
		NULL,
		NULL
	);

/* Validation query */
SELECT * FROM encounters
WHERE id = 'c5f8b1f8-6903-744e-18e7-03496db30723';


/* Conditions Table */
SELECT * FROM conditions;

/* Query 1 */
/* The start and stop columns represent not only date but also time. 
However, the time seems redundant because "00:00:00" doesn't provide much information.*/

/* Adding temporary columns. */
ALTER TABLE conditions ADD COLUMN start_date date;
ALTER TABLE conditions ADD COLUMN stop_date date;

/* Updating temporary columns. */
UPDATE conditions SET start_date = start::date, stop_date = stop::date;

/* Dropping original columns and renaming temporary columns. */
ALTER TABLE conditions DROP COLUMN start;
ALTER TABLE conditions DROP COLUMN stop;
ALTER TABLE conditions RENAME COLUMN start_date TO start;
ALTER TABLE conditions RENAME COLUMN stop_date TO stop;

/* Query 2 */
/* Setting conditions starting with capital */
UPDATE conditions
SET description = INITCAP(description)
WHERE description IS NOT NULL;

/* Validation query */
SELECT DISTINCT description FROM conditions ORDER BY description;

/* Query 3 */
/* Inserting new record in conditions table as new patient was 
recorded earlier*/
INSERT INTO conditions (start, stop, patient, encounter, code, description)
VALUES (
    '2024-08-15', 
    NULL, 
    'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7', 
    'cff8b1f8-6903-744e-18e7-03496db30723', 
    '840539006', 
    'Covid-19'
);

/* Validation query */
SELECT * FROM conditions 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
ORDER BY start DESC;

/* Query 5 */
/* Deleting record now */
DELETE FROM conditions
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
AND code = '840539006';

/* Validation query */
SELECT * FROM conditions 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';









/* Medications Table */
SELECT * FROM medications;

/* Query 1 */
/* We are going to update the description column so that all records start
with a capital letter. */
UPDATE medications
SET description = INITCAP(description);

/* Validation Query */
SELECT description 
FROM medications
GROUP BY description
ORDER BY description;

/* Query 2 */
/* This patient ('c0219ca9-576f-f7c2-9c44-de030e94969b') is currently taking 
"Jolivette 28 Day Pack" but wants to switch to "Yaz 28 Day Pack". 
First, we are going to update the existing record by setting an end date 
for the current medication. Then, we will insert a new record for the new 
medication. */

/* Selecting the current record to be manipulated. */ 
SELECT * FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' AND start = '2021-09-29 11:07:35';

/* Updating the end date of the current medication to the current date. */ 
UPDATE medications
SET stop = CURRENT_DATE
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' AND start = '2021-09-29 11:07:35';

/* Validation Query */
SELECT * FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' AND start = '2021-09-29 11:07:35';

/* Query 3 */
/* Now, let's insert a new record for the new birth control prescription. */ 
INSERT INTO medications (start, stop, patient, payer, encounter, code, description,
base_cost, payer_coverage, dispenses, totalcost)
VALUES (CURRENT_DATE, NULL,'c0219ca9-576f-f7c2-9c44-de030e94969b',
'047f6ec3-6215-35eb-9608-f9dda363a44c','3f8b88d9-24c5-7aac-de26-8c5638b4fb3c',
'748856','Yaz 28 Day Pack',30.99, 0.00, 1, 30.99);

/* Now let's ensure that the record was added. */
SELECT * FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' 
AND description = 'Yaz 28 Day Pack' ;

/* Query 4 */
/* Patient payer information was updated, which changed the base cost, 
payer coverage, and total cost. */
UPDATE medications
SET payer = '047f6ec3-6215-35eb-9608-f9dda363a44c', 
    base_cost = 30.99,                               
    payer_coverage = 10.00,                          
    totalcost = 20.99                             
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b'
AND code = '748856'
AND description = 'Yaz 28 Day Pack'
AND start = CURRENT_DATE;

/* Validation Query */
SELECT * FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' 
AND description = 'Yaz 28 Day Pack' ;

/* Query 5 */
/* I am going to delete this record now to preserve data integrity. */
DELETE FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' 
AND description = 'Yaz 28 Day Pack';

/* Validating the deletion. */ 
SELECT * 
FROM medications 
WHERE patient = 'c0219ca9-576f-f7c2-9c44-de030e94969b' 
AND description = 'Yaz 28 Day Pack';

/* Procedures Table */
SELECT * FROM procedures;

/* Query 1 */
/* Insert a record for a new medical procedure performed on a patient. */
INSERT INTO procedures (start, stop, patient, encounter, code, description, base_cost)
VALUES (
    '2024-08-10 10:00:00', 
    '2024-08-10 10:30:00', 
    'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7', 
    'cff8b1f8-6903-744e-18e7-03496db30723', 
    '710841007', 
    'Assessment of anxiety (procedure)', 
    516.65
);

/* Validation query */
SELECT * FROM procedures 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';

/* Query 2 */
/* Ensure all procedure descriptions are standardized with proper capitalization. */
UPDATE procedures
SET description = INITCAP(description)
WHERE description IS NOT NULL;

/* Validation: Check that the descriptions have been updated. */
SELECT DISTINCT description FROM procedures ORDER BY description;

/* Query 3 */
/* Adjust the cost of a procedure due to a billing error. */
UPDATE procedures
SET base_cost = 150.00
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
AND code = '710841007';

/* Validation: Check that the cost has been updated. */
SELECT * FROM procedures 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
AND code = '710841007';

/* Query 4 */
/* Adding a reason code for this record. */
UPDATE procedures
SET reasoncode = '72892002', 
    reasondescription = 'Normal pregnancy'
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
  AND encounter = 'cff8b1f8-6903-744e-18e7-03496db30723'
  AND code = '710841007';

/* Checking that the reason code and reason description have been updated. */
SELECT * FROM procedures 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
  AND encounter = 'cff8b1f8-6903-744e-18e7-03496db30723'
  AND code = '710841007';

/* Query 5 */
/* Remove a record that was incorrectly added. */
DELETE FROM procedures
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7'
AND code = '710841007'
AND start = '2024-08-10 10:00:00';

/* Validation query */
SELECT * FROM procedures 
WHERE patient = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';

/* Immunizations Table */
SELECT * FROM immunizations;

/* For the above examples, I used this query to find specific records, 
such as patients who didn't get the Covid vaccine, in order to perform 
insert, update, and delete queries. */

SELECT PATIENT, DATE, DESCRIPTION, CODE, BASE_COST
FROM immunizations
ORDER BY PATIENT, DATE;

/* Query 1 */
UPDATE immunizations
SET description = INITCAP(description);

/* Validation query */
SELECT PATIENT, DATE, DESCRIPTION, CODE, BASE_COST
FROM immunizations
ORDER BY PATIENT, DATE;

/* Query 2 */
/* This patient recently received a COVID-19 vaccination. 
Let's add a record to our dataset. */

SELECT * FROM immunizations
WHERE PATIENT = '01f8bbfd-cfc6-3b97-8bc1-8da6f0b4a9a8'
ORDER BY DATE DESC;

/* Inserting values */
INSERT INTO immunizations (DATE, PATIENT, ENCOUNTER, CODE, DESCRIPTION, BASE_COST)
VALUES ('2021-05-15 10:30:00', '01f8bbfd-cfc6-3b97-8bc1-8da6f0b4a9a8', 
(SELECT ENCOUNTER FROM immunizations WHERE PATIENT = '01f8bbfd-cfc6-3b97-8bc1-8da6f0b4a9a8' LIMIT 1),
'207', 'Sars-Cov-2 (Covid-19) Vaccine Mrna Spike Protein Lnp Preservative Free 100 Mcg/0.5ml Dose',
140.52);

/* Verifying that the record is present now */
SELECT * FROM immunizations
WHERE PATIENT = '01f8bbfd-cfc6-3b97-8bc1-8da6f0b4a9a8'
ORDER BY DATE DESC;

/* Query 3 */
/* There has been a mistake in the records, and a patient says that they didn't 
get their second Covid shot yet. */
SELECT * FROM immunizations
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
  AND DATE = '2021-04-06 05:34:46';

 /* Proceeding with deletion */
DELETE FROM immunizations
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
  AND DATE = '2021-04-06 05:34:46';

/* Verifying that the record has been deleted */
SELECT * FROM immunizations
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
  AND DATE = '2021-04-06 05:34:46';

/* Query 4 */
/* The patient with ID '00209bf2-8e4d-06d1-82a4-daad02f25829' is ready to receive 
their Covid-19 vaccine shot today. We need to update their records to reflect this 
change in immunization. */

INSERT INTO immunizations (DATE, PATIENT, ENCOUNTER, CODE, DESCRIPTION, BASE_COST)
VALUES (CURRENT_DATE, '00209bf2-8e4d-06d1-82a4-daad02f25829','ea8d3f14-23da-3aef-5474-55961b44d7fb',
'208','Sars-Cov-2 (Covid-19) Vaccine Mrna Spike Protein Lnp Preservative Free 30 Mcg/0.3ml Dose',
 140.52);

/* Verifying that the record is present now */
SELECT * FROM immunizations
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
ORDER BY DATE DESC
LIMIT 1;

/* Query 5 */
/* Immunization was actually done at 2:45 pm; let's update it. */
UPDATE immunizations
SET DATE = CURRENT_DATE + TIME '14:45:00'
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
  AND CODE = '208'
  AND DATE = CURRENT_DATE;

/* Verification query */
SELECT PATIENT, DATE, DESCRIPTION, CODE, BASE_COST
FROM immunizations
WHERE PATIENT = '00209bf2-8e4d-06d1-82a4-daad02f25829'
  AND CODE = '208'
  AND DATE::date = CURRENT_DATE
ORDER BY DATE DESC
LIMIT 1;

/* Observations Table */
SELECT * FROM observations;

/* Query 1 */
/* After grouping units, we can see the inconsistency in how missing data are represented. 
For example, there are some 'null', 'n/a' values that are not recognizable by SQL. 
Let's change that. */
SELECT units, COUNT(*) AS unit_count
FROM observations
GROUP BY units;

/* Identification Query */
SELECT units, COUNT(*) AS unit_count
FROM observations
WHERE units IN ('null', 'n/a')
GROUP BY units;

/* Update Query */
UPDATE observations
SET units = NULL
WHERE units IN ('null', 'n/a');

/* Validation Query */
SELECT units, COUNT(*) AS unit_count
FROM observations
WHERE units IS NULL 
GROUP BY units;


/* Query 2 */
/* Previously we inserted a new record into the encounter table. Based on this record,
we insert a new observation for a vital sign related to systolic blood pressure. */

INSERT INTO observations (
    DATE, PATIENT, ENCOUNTER, CATEGORY, CODE, DESCRIPTION, VALUE, UNITS, TYPE
) VALUES (
    '2024-08-10 11:00:00', 
    '2f031d4a-b070-ce15-6372-30c8fecf1164', 
    'cff8b1f8-6903-744e-18e7-03496db30723', 
    'Vital Signs', 
    '8462-4', 
    'Systolic Blood Pressure', 
    '120', 
    'mmHg', 
    'Numeric'
);

/* Validation Query */
SELECT * 
FROM observations 
WHERE PATIENT = '2f031d4a-b070-ce15-6372-30c8fecf1164' AND code = '8462-4' 
	AND date = '2024-08-10 11:00:00';

/* Query 3 */
/* The units were incorrectly input in the dataset for this record. */   
UPDATE observations
SET units = 'mm[Hg]'
WHERE patient = '2f031d4a-b070-ce15-6372-30c8fecf1164'
  AND code = '8462-4'
  AND date = '2024-08-10 11:00:00';

/* Validation: Checking that the units have been updated. */
SELECT * 
FROM observations 
WHERE patient = '2f031d4a-b070-ce15-6372-30c8fecf1164'
  AND code = '8462-4'
  AND date = '2024-08-10 11:00:00';

/* Query 4 */
DELETE FROM observations
WHERE patient = '2f031d4a-b070-ce15-6372-30c8fecf1164'
  AND code = '8462-4'
  AND date = '2024-08-10 11:00:00';

/* Validation: Ensuring the record has been deleted. */
SELECT * 
FROM observations 
WHERE patient = '2f031d4a-b070-ce15-6372-30c8fecf1164'
  AND code = '8462-4'
  AND date = '2024-08-10 11:00:00';

/* Query 5 */
UPDATE observations
SET category = INITCAP(category)
WHERE category IS NOT NULL;

/* Validation: Check that the categories have been updated. */
SELECT DISTINCT category 
FROM observations 
ORDER BY category;

/* Query 6 */
/* To standardize the category values in the observations table so that all 
instances of "Vital Signs" and "Vital-Signs" follow a consistent format, 
you can use an UPDATE query. */ 

UPDATE observations
SET category = 'Vital Signs'
WHERE category IN ('Vital Signs', 'Vital-Signs');

/* Validation: Checking that the categories have been updated. */
SELECT DISTINCT category 
FROM observations 
ORDER BY category;

/* Organizations Table */ 
SELECT * FROM organizations;

/* Query 1 */
/* Many phone numbers in this dataset are formatted inconsistently. 
For example, some entries appear as "413-731-6000 Or 413-731-6000", 
which repeats the number after "Or". 
We need to standardize this format by removing everything after "Or". */
SELECT phone
	FROM organizations
WHERE phone LIKE '%Or%';

/* Identify and replace phone numbers with only the first occurrence before ' Or'. */
UPDATE organizations
SET phone = TRIM(SPLIT_PART(phone, 'Or', 1))
WHERE phone LIKE '%Or%';

/* Validation query */
SELECT phone FROM organizations;

/* Query 2 */
INSERT INTO organizations (id, name, address, city, state, zip, lat, lon, phone, revenue, utilization)
VALUES ('e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78', 
    'Health Kids Center', 
    '123 Health St', 
    'Boston', 
    'MA', 
    '02118', 
    42.336, 
    -71.071, 
    '617-555-1234', 
    5000000.00, 
    85
);

/* Validation Query */
SELECT * FROM organizations 
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Query 3 */
UPDATE organizations
SET revenue = '15.000'
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Validation Query */
SELECT * FROM organizations 
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Query 4 */
/* The phone number changed for the clinic. */ 
UPDATE organizations
SET phone = '617-555-1244'
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Validation: Checking that the phone number has been updated. */
SELECT * FROM organizations 
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Query 5 */
/* Remove an organization record that is no longer active. */
DELETE FROM organizations
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Validation query */
SELECT * FROM organizations 
WHERE id = 'e9f6a0d8-6c73-4e5a-8f4d-9b4f3f1b5c78';

/* Providers Table */
SELECT * FROM providers; 

/* Query 1 */
/* Remove Numeric Characters from Provider Names */
/* This query removes any numeric characters from the 'name' field in the providers table.
Purpose: To clean and standardize provider names by eliminating unexpected numerical values. */
UPDATE providers
SET name = REGEXP_REPLACE(name, '\d', '', 'g')
WHERE name ~ '\d';

/* Validation: Check that the numbers have been removed from provider names. */
SELECT id, name 
FROM providers;

/* Query 2 */
/* Standardize Provider Addresses */ 
/* This query identifies providers with numeric-only addresses and appends 'SW' to them.
Purpose: To standardize address formats and add missing street designations. */
SELECT id, name, address, city, state, zip
FROM providers
WHERE address ~ '^\d+$';

UPDATE providers
SET address = address || ' SW'
WHERE address ~ '^\d+$';

/* Validation: Checking the updated addresses. */
SELECT id, name, address, city, state, zip
FROM providers
WHERE address LIKE '% SW';

/* Query 3 */
/* Add New Provider Record */ 
/* This query inserts a new provider record into the database. */
INSERT INTO providers (id, organization, name, gender, speciality, address, city, state, zip, lat, lon, utilization)
VALUES (
    '580a86a1-8b91-360b-a9fe-f52abe01aa54',
    'a0b6ec0c-e587-3b2a-bf9f-248849f29ee5', 
    'Jane Micheal',                    
    'F',                                  
    'Cardiology',                         
    '456 Wellness Blvd',               
    'Boston',                           
    'MA',                               
    '02118',                             
    42.3601,                            
    -71.0589,                             
    90                                   
);

/* Validation: Checking that the new provider was added successfully. */
SELECT * FROM providers 
WHERE id = '580a86a1-8b91-360b-a9fe-f52abe01aa54';

/* Query 4 */
/* Update Provider Information */ 
/* This query updates the address and specialty of a specific provider. */
UPDATE providers
SET address = '789 Rutland Sq', 
    speciality = 'Wellness Medicine'
WHERE id = '580a86a1-8b91-360b-a9fe-f52abe01aa54';

/* Validation: Checking that the provider's details have been updated correctly. */
SELECT * FROM providers 
WHERE id = '580a86a1-8b91-360b-a9fe-f52abe01aa54';

/* Query 5 */
/* Delete Provider Record */ 
/* This query removes a specific provider record from the database. */
DELETE FROM providers
WHERE id = '580a86a1-8b91-360b-a9fe-f52abe01aa54';

/* Validation: Ensuring the provider has been deleted successfully. */
SELECT * FROM providers 
WHERE id = '580a86a1-8b91-360b-a9fe-f52abe01aa54';

/* Payers Table */ 
SELECT * FROM payers;

/* Query 1 */
/* Adding New Payer Record */ 
INSERT INTO payers (
    Id, NAME, ADDRESS, CITY, STATE_HEADQUARTERED, ZIP, PHONE, 
    AMOUNT_COVERED, AMOUNT_UNCOVERED, REVENUE, COVERED_ENCOUNTERS, 
    UNCOVERED_ENCOUNTERS, COVERED_MEDICATIONS, UNCOVERED_MEDICATIONS, 
    COVERED_PROCEDURES, UNCOVERED_PROCEDURES, COVERED_IMMUNIZATIONS, 
    UNCOVERED_IMMUNIZATIONS, UNIQUE_CUSTOMERS, QOLS_AVG, MEMBER_MONTHS
) VALUES (
    '4f6f8b8e-d3f5-45f7-93b7-832a81b1e8b7', 
    'Kaiser Health Insurance', '123 Sun St', 'San Francisco', 'CA', '62704', '555-555-5555', 
    150000.00, 50000.00, 200000.00, 500, 200, 300, 100, 150, 50, 250, 75, 1000, 
    0.8754567890123456, 24
);

/* Validation Query 1 */
/* Verify that the new payer record was added */
SELECT * FROM payers 
WHERE Id = '4f6f8b8e-d3f5-45f7-93b7-832a81b1e8b7';

/* Query 2 */
/* Updating the revenue and covered encounters for a specific payer. */
UPDATE payers
SET REVENUE = 250000.00, 
    COVERED_ENCOUNTERS = 600
WHERE Id = '4f6f8b8e-d3f5-45f7-93b7-832a81b1e8b7';

/* Validation Query 2 */
/* Verify that the revenue and covered encounters were updated */
SELECT REVENUE, COVERED_ENCOUNTERS 
FROM payers 
WHERE Id = '4f6f8b8e-d3f5-45f7-93b7-832a81b1e8b7';

/* Query 3 */
/* Deleting a payer record from the payers table. */
DELETE FROM payers
WHERE Id = '4f6f8b8e-d3f5-45f7-93b7-832a81b1e8b7';

/* Query 4 */
/* Inserting another new payer record into the payers table. */
INSERT INTO payers (
    Id, NAME, ADDRESS, CITY, STATE_HEADQUARTERED, ZIP, PHONE, 
    AMOUNT_COVERED, AMOUNT_UNCOVERED, REVENUE, COVERED_ENCOUNTERS, 
    UNCOVERED_ENCOUNTERS, COVERED_MEDICATIONS, UNCOVERED_MEDICATIONS, 
    COVERED_PROCEDURES, UNCOVERED_PROCEDURES, COVERED_IMMUNIZATIONS, 
    UNCOVERED_IMMUNIZATIONS, UNIQUE_CUSTOMERS, QOLS_AVG, MEMBER_MONTHS
) VALUES (
    'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8', 
    'Life Inc', '456 Sandae St', 'Chicago', 'IL', '60605', '555-555-1234', 
    500000.00, 100000.00, 600000.00, 1000, 400, 500, 200, 300, 150, 400, 100, 2000, 
    0.9254567890123456, 36
);

/* Validation Query 4 */
/* Verify that the new payer record was added */
SELECT * FROM payers 
WHERE Id = 'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8';

/* Query 5 */
/* Updating the phone number, revenue, and amount uncovered for a specific payer. */
UPDATE payers
SET PHONE = '555-555-9999', 
    REVENUE = 550000.00, 
    AMOUNT_UNCOVERED = 120000.00
WHERE Id = 'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8';

/* Validation Query 5 */
/* Verify that the phone number, revenue, and amount uncovered were updated */
SELECT PHONE, REVENUE, AMOUNT_UNCOVERED 
FROM payers 
WHERE Id = 'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8';

/* Query 6 */
/* Deleting the specific payer record from the payers table. */
DELETE FROM payers
WHERE Id = 'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8';

/* Validation Query 6 */
/* Verify that the payer record was deleted */
SELECT * FROM payers 
WHERE Id = 'f4b8e6d3-8347-43f7-b3e8-7d93a8b1e8c8';


/* I am going to delete patient records that were created for demonstrational 
purposes only, in order to maintain the integrity of the dataset.*/
/* Query 7 */
/* Deleting patient's record */
DELETE FROM patients
WHERE id = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';

/* Validation query */
SELECT * FROM patients 
WHERE id = 'c7f6bdf1-11a4-5a8e-963d-4f8e33f2c6b7';



