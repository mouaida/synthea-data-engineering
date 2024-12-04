## Data Engineering Synthetic Health Data Project

This project's objective is to clean and analyse synthetic healthcare data from Synthea. The goal is to uncover trends in patient demographics, diagnoses, procedures, and medications to inform healthcare insights.

----

## Tools Used
- **Programming Language**: R
- **IDE**: RStudio
- **Libraries**: `readr`, `dplyr`, `tidyr`, `tidyverse`, `janitor`, `ggplot2`

---

## Repository Structure
- `data/`: Contains the raw CSV files.
- `code/`: Contains R scripts for data processing and analysis.
    - `data_cleaning.R`: Script for loading, cleaning, and transforming the data.
    - `data_analysis.R`: Script for exploratory analysis and aggregating data insights.
- `README.md`: This file, provides detailed explanations of each step taken in this project.

---

## Progress in Branches

### Branch: `data-cleaning`
- Initialised R environment with required libraries.
- Loaded six datasets from CSV files into RStudio.
- Standardised each dataset to ensure consistent column naming and retained only relevant fields for analysis.
- Transformed and cleaned columns, including:
  - Converted date columns to consistent formats (`Date` or `POSIXct`).
  - Replaced invalid `ZIP` values (`00000`) with `NA`.
  - Converted long numeric codes (e.g., `procedure_code`, `diagnosis_code`) to character format.
- Combined datasets into a single `combined_data` dataset for further analysis.
- Conducted data quality checks, including:
  - Validating relationships between patients, encounters, and other entities.
  - Inspecting for missing values, inconsistencies, and duplicates.

### Branch: `data-analysis`
- **Exploratory Data Analysis (EDA)**:
  - Conducted an initial exploration of the dataset to understand its characteristics:
    - Analysed the distribution of patients by `age_group`, `gender`, and `diagnosis_description`.
    - Identified the most frequent `diagnoses` and `medications`.
    - Investigated trends in medical procedures over time.
    - Explored relationships between patient demographics (e.g., `age_group`, `gender`) and diagnosis/medication types.
  - Generated tables and graphs to summarise key insights:
    - Patient distribution by age groups, gender, and diagnosis.
    - Diagnosis and medication frequencies by demographics.
    - Trends in medical procedures over recent years.

- **Statistical Analysis**:
  - Performed basic statistical summaries:
    - Calculated mean, median, and standard deviation for numerical columns such as `age`, `length_of_stay`, and `total_visits`.
    - Summarised patient visits, diagnoses, and medications for insights into common patterns.
  - Identified outliers and potential skewed distributions:
    - Created boxplots for variables such as `age`, `length_of_stay`, and `total_visits` to visually detect anomalies.
    - Applied log transformations where necessary to better represent skewed data (e.g., `length_of_stay`, `total_visits`).

---

## Detailed steps taken for each Branch

### Branch: `data-cleaning`

#### Transformed Datasets
1. **patients_transformed**:
   - Retained: `patient_id`, `birthdate`, `age`, `gender`, `city`, `zip`, `income`.
   - Transformed:
     - Calculated `age` from `birthdate`.
     - Converted `ZIP` to replace `00000` with `NA`.

2. **conditions_transformed**:
   - Retained: `diagnosis_start`, `diagnosis_stop`, `patient_id`, `encounter_id`, `diagnosis_code`, `diagnosis_description`.
   - Transformed:
     - Converted `diagnosis_start` and `diagnosis_stop` to `Date`.
     - Converted `diagnosis_code` to `character`.

3. **medications_transformed**:
   - Retained: `medication_start`, `medication_stop`, `patient_id`, `encounter_id`, `medication_code`, `medication_name`.
   - Transformed:
     - Converted `medication_start` and `medication_stop` to `POSIXct`.
     - Converted `medication_code` to `character`.

4. **procedures_transformed**:
   - Retained: `procedure_start`, `procedure_stop`, `patient_id`, `encounter_id`, `procedure_code`, `procedure_description`.
   - Transformed:
     - Converted `procedure_start` and `procedure_stop` to `POSIXct`.
     - Converted `procedure_code` to `character`.

5. **organizations_transformed**:
   - Retained: `hospital_id`, `hospital_name`.

6. **encounters_transformed**:
   - Retained: `encounter_id`, `encounter_start`, `encounter_stop`, `patient_id`, `hospital_id`, `encounter_code`, `encounter_description`.
   - Transformed:
     - Converted `encounter_start` and `encounter_stop` to `POSIXct`.

---

#### Combined Dataset: `combined_data`
- **Joined Tables**:
   - Used `patient_id` to join `patients_transformed` with `encounters_transformed`.
   - Then used `encounter_id` to join `encounters_transformed` with:
     - `conditions_transformed`
     - `medications_transformed`
     - `procedures_transformed`.
   - Lastly, used `hospital_id` to join `encounters_transformed` with `organizations_transformed`.

- **Standardised Columns**:
   - Converted date columns to consistent formats:
     - **Date Format (`YYYY-MM-DD`)**: Applied to columns like `birthdate`, `diagnosis_start`, and `diagnosis_stop`.
     - **Datetime Format (`YYYY-MM-DD HH:MM:SS`)**: Applied to columns like `encounter_start`, `encounter_stop`, `medication_start`, `medication_stop`, `procedure_start`, and `procedure_stop`.
   - Replaced invalid `ZIP` values (`00000`) with `NA` to better handle missing or placeholder data.
   - Converted long numeric codes (`diagnosis_code`, `procedure_code`, `medication_code`) to `character` format to prevent issues with scientific notation (e.g., `4.56191E+14`).
   - Converted numeric columns (`age`, `income`) to ensure proper data types for analysis.
   
- **Exported Dataset**:
   - Saved the joined dataset `combined_data` to `combined_data.csv` for further analysis.

---

#### Data Quality Checks
1. **Basic Structure Validation**:
   - Confirmed the dataset dimensions to ensure the number of rows and columns match expectations.
   - Validated column names to confirm they are correctly standardised.

2. **Missing Values**:
   - Calculated the count and percentage of missing values for all columns.
   - Presented results in a readable long-format table, sorted by the highest missing values.

3. **Relationship Validation**:
   - Verified that each `encounter_id` is tied to a single `patient_id`.
   - Checked that all `patient_id` values are linked to encounters.

4. **Uniqueness and Duplicates**:
   - Counted distinct values for key columns (`patient_id`, `encounter_id`, etc.).
   - Identified duplicate rows by comparing total rows with unique rows.

5. **Encounter Linkage**:
   - Aggregated the number of related records (`diagnosis_code`, `procedure_code`, `medication_code`) for each `encounter_id`.
   - Counted non-missing values for these columns to get an overview of their distribution across encounters.

---

## Branch: `data-analysis`

### Overview
- Developed `data_analysis.R` to perform exploratory data analysis (EDA) and generate insights from the cleaned `combined_data.csv` dataset.
- Focused on understanding patient demographics, temporal trends, and diagnosis/procedure frequencies.
- Created new variables, aggregated data, and visualised insights to identify patterns.

---

### New Variables
1. **`age_group`**:
   - Categorised patients into broad age groups (`0-17`, `18-34`, `35-64`, and `65+`) to ensure sufficient records for meaningful analysis.

2. **`age_group_code`**:
   - Assigned numeric codes to age groups for easier sorting and statistical operations.

3. **`length_of_stay`**:
   - Calculated the number of days between `encounter_start` and `encounter_stop` for each hospital visit.

---

### Aggregated Data
1. **Visits Per Patient**:
   - Summarised the total number of unique hospital visits for each patient.

2. **Diagnosis Frequency**:
   - Aggregated the frequency of each `diagnosis_description` and its corresponding `diagnosis_code`.

3. **Medications By Age Group**:
   - Counted the number of medications prescribed within each age group.

4. **Procedures Per Hospital**:
   - Calculated the total number of procedures performed per hospital.

---

### EDA and Statistical Analysis

#### Key Steps
1. **Demographic Distributions**:
   - Grouped patients by `age_group`, `gender`, and `diagnosis_description`.
   - Visualised the top 10 diagnoses distributed by age groups and gender.

2. **Temporal Analysis**:
   - Examined hospital visits and medication use over time.
   - Created yearly and monthly summaries to capture trends post-2000.

3. **Statistical Summaries**:
   - Calculated the mean, median, and standard deviation for:
     - Patient `age`
     - `Length of Stay`
     - `Total Visits`
   - Identified and visualised outliers using boxplots, applying log transformations for skewed data.

4. **Most Common Diagnoses and Procedures**:
   - Bar charts highlighted the top 10 diagnoses and procedures based on their frequency.
   - Provided demographic breakdowns for better understanding.

---

### Insights Generated

#### 1. Diagnoses by Age Groups and Gender
- **Key Findings**:
  - **Age Groups**:
    - Middle-aged adults (35–64) show the highest frequency of diagnoses like "Stress" and "Social Isolation."
    - Older adults (65+) exhibit a higher prevalence of "Medication Review Due" and "Gingivitis."
  - **Gender**:
    - Males are disproportionately represented in employment-related diagnoses like "Not in Labor Force."
    - Females show higher frequencies for social conditions like "Victim of Intimate Partner Abuse."

#### 2. Temporal Trends
- **Hospital Visits**:
  - Significant increase post-2000, peaking around 2020, reflecting potential synthetic data trends.
- **Medication Use**:
  - Temporal trends closely mirror hospital visits, suggesting linked treatment patterns.

#### 3. Most Common Diagnoses and Procedures
- **Diagnoses**:
  - The most frequent diagnoses include "Medication Review Due," "Stress," and "Gingivitis."
  - Many diagnoses are related to lifestyle and mental health conditions.
- **Procedures**:
  - "Depression Screening" and "Substance Use Assessment" dominate the dataset, indicating a focus on mental health.

---

### Visualisation Summary
1. **Demographic Trends**:
   - Bar charts for diagnoses by age group and gender reveal demographic-specific health patterns.
2. **Temporal Trends**:
   - Line charts highlight the steady growth in hospital visits and medication use over time.
3. **Diagnosis and Procedure Insights**:
   - Horizontal bar charts visualise the top 10 diagnoses and procedures, providing actionable insights.

---

### Code Subdirectory
- **`code/data_cleaning.R`**:
   - A script to:
     - Load and clean datasets.
     - Standardise column names and data types/formats.
     - Combine the datasets into a joined dataset for analysis.
   - **Status**: Completed cleaning and transformations.

- **`code/data_analysis.R`**:
   - A script to:
     - Load the cleaned dataset.
     - Create new variables (`age_group`, `length_of_stay`).
     - Aggregate data for exploratory insights (e.g., visits per patient, diagnosis frequency).
   - **Status**: Initial analysis complete.
