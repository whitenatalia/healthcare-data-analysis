/* Data Insertion */

CREATE DATABASE synthea;

/* Patients and Encounters. Each patient can have multiple encounters. 
Each encounter is linked to only one patient. 
The "PATIENT" column in the encounters table connects to the "Id" in the patients table.

Providers and Encounters. Each encounter involves one provider. A provider can have multiple encounters. 
The "PROVIDER" column in the encounters table connects to the "Id" in the providers table.

Organizations and Providers.  Providers work for organizations. An organization can have multiple providers.
The "ORGANIZATION" column in the providers table connects to the "Id" in the organizations table.

Payers and Encounters. Each encounter is covered by one payer. A payer can cover many encounters.
The "PAYER" column in the encounters table connects to the "Id" in the payers table.

Tables such as conditions, medications, procedures, immunizations, and observations store specific health details
for patients during encounters. They are connected to the encounters table and the patients table to show which 
patient received each treatment or had a specific condition.

Some NOT NULL constraints were incorporated to prevent missing entries in the future. */


/* Patients table */
CREATE TABLE patients (
    Id UUID PRIMARY KEY,
    BIRTHDATE DATE NOT NULL,
    DEATHDATE DATE,
    SSN VARCHAR(11),
    DRIVERS VARCHAR(50),
    PASSPORT VARCHAR(50),
    PREFIX VARCHAR(10),
    FIRST VARCHAR(50) NOT NULL,
    LAST VARCHAR(50) NOT NULL,
    SUFFIX VARCHAR(10),
    MAIDEN VARCHAR(50),
    MARITAL VARCHAR(20),
    RACE VARCHAR(50),
    ETHNICITY VARCHAR(50),
    GENDER VARCHAR(1),
    BIRTHPLACE VARCHAR(100),
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(50),
    COUNTY VARCHAR(50),
    ZIP VARCHAR(10),
    LAT DECIMAL(17,14),
    LON DECIMAL(17,14),
    HEALTHCARE_EXPENSES DECIMAL(12,4),
    HEALTHCARE_COVERAGE DECIMAL(12,4)
);

/* Organizations table */
CREATE TABLE organizations (
    Id UUID PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(2),
    ZIP VARCHAR(10),
    LAT DECIMAL(9,6),
    LON DECIMAL(9,6),
    PHONE VARCHAR(50),
    REVENUE DECIMAL(15,2),
    UTILIZATION INTEGER
);

/* Providers table */
CREATE TABLE providers (
    Id UUID PRIMARY KEY,
    ORGANIZATION UUID REFERENCES organizations(Id),
    NAME VARCHAR(100) NOT NULL,
    GENDER VARCHAR(1),
    SPECIALITY VARCHAR(100),
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE VARCHAR(2),
    ZIP VARCHAR(10),
    LAT DECIMAL(9,6),
    LON DECIMAL(9,6),
    UTILIZATION INTEGER
);

/* Payers table */
CREATE TABLE payers (
    Id UUID PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    ADDRESS VARCHAR(100),
    CITY VARCHAR(50),
    STATE_HEADQUARTERED VARCHAR(2),
    ZIP VARCHAR(10),
    PHONE VARCHAR(20),
    AMOUNT_COVERED DECIMAL(12,2),
    AMOUNT_UNCOVERED DECIMAL(12,2),
    REVENUE DECIMAL(12,2),
    COVERED_ENCOUNTERS INTEGER,
    UNCOVERED_ENCOUNTERS INTEGER,
    COVERED_MEDICATIONS INTEGER,
    UNCOVERED_MEDICATIONS INTEGER,
    COVERED_PROCEDURES INTEGER,
    UNCOVERED_PROCEDURES INTEGER,
    COVERED_IMMUNIZATIONS INTEGER,
    UNCOVERED_IMMUNIZATIONS INTEGER,
    UNIQUE_CUSTOMERS INTEGER,
    QOLS_AVG DECIMAL(20,16),
    MEMBER_MONTHS INTEGER
);

/* Encounters table */
CREATE TABLE encounters (
    Id UUID PRIMARY KEY,
    START TIMESTAMP,
    STOP TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    ORGANIZATION UUID REFERENCES organizations(Id),
    PROVIDER UUID REFERENCES providers(Id),
    PAYER UUID REFERENCES payers(Id),
    ENCOUNTERCLASS VARCHAR(50),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    BASE_ENCOUNTER_COST DECIMAL(12,2),
    TOTAL_CLAIM_COST DECIMAL(12,2),
    PAYER_COVERAGE DECIMAL(12,2),
    REASONCODE VARCHAR(50),
    REASONDESCRIPTION TEXT
);

/* Conditions table */
CREATE TABLE conditions (
    START TIMESTAMP,
    STOP TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    ENCOUNTER UUID REFERENCES encounters(Id),
    CODE VARCHAR(50),
    DESCRIPTION TEXT
);

/* Medications table */
CREATE TABLE medications (
    START TIMESTAMP,
    STOP TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    PAYER UUID REFERENCES payers(Id),
    ENCOUNTER UUID REFERENCES encounters(Id),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    BASE_COST DECIMAL(12,2),
    PAYER_COVERAGE DECIMAL(12,2),
    DISPENSES INTEGER,
    TOTALCOST DECIMAL(12,2),
    REASONCODE VARCHAR(50),
    REASONDESCRIPTION TEXT
);

/* Procedures table */
CREATE TABLE procedures (
    START TIMESTAMP,
    STOP TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    ENCOUNTER UUID REFERENCES encounters(Id),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    BASE_COST DECIMAL(12,2),
    REASONCODE VARCHAR(50),
    REASONDESCRIPTION TEXT
);

/* Observations table */
CREATE TABLE observations (
    DATE TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    ENCOUNTER UUID REFERENCES encounters(Id),
    CATEGORY VARCHAR(50),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    VALUE VARCHAR(200),
    UNITS VARCHAR(50),
    TYPE VARCHAR(50)
);

/* Immunizations table */
CREATE TABLE immunizations (
    DATE TIMESTAMP,
    PATIENT UUID REFERENCES patients(Id),
    ENCOUNTER UUID REFERENCES encounters(Id),
    CODE VARCHAR(50),
    DESCRIPTION TEXT,
    BASE_COST DECIMAL(12,2)
);

/* Importing Data */
COPY organizations FROM '/Users/nataliabelkina/Public/csv 3/organizations.csv' WITH CSV HEADER;
COPY patients FROM '/Users/nataliabelkina/Public/csv 3/patients.csv' WITH CSV HEADER;
COPY providers FROM '/Users/nataliabelkina/Public/csv 3/providers.csv' WITH CSV HEADER;
COPY payers FROM '/Users/nataliabelkina/Public/csv 3/payers.csv' WITH CSV HEADER;
COPY encounters FROM '/Users/nataliabelkina/Public/csv 3/encounters.csv' WITH CSV HEADER;
COPY conditions FROM '/Users/nataliabelkina/Public/csv 3/conditions.csv' WITH CSV HEADER;
COPY medications FROM '/Users/nataliabelkina/Public/csv 3/medications.csv' WITH CSV HEADER;
COPY procedures FROM '/Users/nataliabelkina/Public/csv 3/procedures.csv' WITH CSV HEADER;
COPY observations FROM '/Users/nataliabelkina/Public/csv 3/observations.csv' WITH CSV HEADER;
COPY immunizations FROM '/Users/nataliabelkina/Public/csv 3/immunizations.csv' WITH CSV HEADER;

