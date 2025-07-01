# Healthcare Database Integration and Analysis

## 📍 Project Overview
This project aims to improve the data management system for Massachusetts healthcare services. The current system relies on Excel files, leading to data loss, entry errors, and limited analytical capabilities. To resolve these issues, I’ve built an integrated PostgreSQL database, conducted in-depth analysis using Python and SQL, and visualized insights in Tableau.

While fictional, this project simulates a real-world role as a data analyst hired by the state of Massachusetts to modernize its healthcare data infrastructure.

---

## 🎯 Project Goals
1. Design a normalized relational database schema suitable for healthcare data.
2. Transfer and clean synthetic patient data into PostgreSQL.
3. Perform analytical queries to extract health insights.
4. Connect the database with Python for advanced statistical analysis.
5. Develop an executive dashboard in Tableau for visual exploration.

---

## 🛠️ Tools & Technologies
- **Database**: PostgreSQL (via pgAdmin 4)
- **Schema Design**: LucidChart
- **Data Analysis**: Python (Pandas, NumPy, Seaborn), SQLAlchemy
- **Visualization**: Tableau, Seaborn
- **Data Source**: Synthetic healthcare data from [Synthea](https://synthea.mitre.org/)

---

## 🧩 Data Summary
- Synthetic dataset with **795,317 rows** across the following tables:

| Table           | Rows     |
|-----------------|----------|
| Patients        | 1,163    |
| Encounters      | 61,460   |
| Conditions      | 38,094   |
| Medications     | 56,430   |
| Procedures      | 83,823   |
| Observations    | 531,144  |
| Immunizations   | 17,010   |
| Providers       | 5,056    |
| Organizations   | 1,127    |
| Payers          | 10       |

---

## 🗃️ Database Design Highlights
- **10 interconnected tables** modeling realistic healthcare data
- Relational structure using **one-to-many** foreign key relationships
- Enforced **NOT NULL constraints** to improve data integrity

**Example Relationships:**
- Each **patient** can have many **encounters**
- Each **encounter** is linked to one **provider**, **payer**, and **patient**
- Tables like **Conditions**, **Medications**, and **Procedures** are linked to both **Patients** and **Encounters**

---

## 🧼 Data Cleaning & Processing
- Removed suffixes from names (e.g., "Damon455 Langosh790" → "Damon Langosh")
- Standardized date/time formats
- Removed duplicates
- Demonstrated SQL operations: `INSERT`, `UPDATE`, `DELETE`

---

## 📊 Python Analysis
- Connected PostgreSQL to Python using SQLAlchemy
- Conducted:
  - Descriptive statistics
  - Exploratory Data Analysis (EDA)
  - Visualizations (Seaborn)
  - Hypothesis testing (t-tests)
  - Correlation matrix analysis

---

## 📈 Tableau Dashboard
- Developed an interactive dashboard using **data blending** to handle complex one-to-many relationships
- Verified Tableau metrics against SQL and Python outputs

**Interactive Features Include:**
- Filter by **encounter class**
- Adjust **date range** with a slider
- Select specific **counties** for granular insights

---

## 🔍 Key Insights
- Successfully integrated and analyzed nearly 800K rows of synthetic healthcare data
- Built a scalable and normalized database for state-level analysis
- Delivered insights through a combination of SQL, Python, and Tableau
- Enabled decision-making support for non-technical stakeholders

---

## 🚀 Future Improvements
- Apply machine learning techniques to build predictive models for:
  - Hospital readmissions
  - Medication non-adherence
  - Disease outbreaks

---

## 👩‍💻 Author
**Natalia White**  
[LinkedIn Profile](https://linkedin.com/in/nataliawhite1)  
Data Analyst | SQL | Python | Tableau | Healthcare Analytics

---

## 📝 Notes
Data source: [Synthea - Synthetic Patient Data](https://synthea.mitre.org/downloads)  
Dataset used: *1K Sample Synthetic Patient Records*

*This project uses synthetic data and is intended solely for educational and portfolio purposes.*
