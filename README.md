## Data Engineering Synthetic Health Data Project

This project's objective is to clean and analyse synthetic healthcare data from Synthea. The goal is to uncover trends in patient demographics, diagnoses, procedures, and medications to inform healthcare insights.

----

## Tools Used
- **Programming Language**: R
- **IDE**: RStudio
- **Libraries**: `readr`, `dplyr`, `tidyr`, `tidyverse`, `janitor`

----

## Progress in Current Branch: `data-cleaning`
### Overview
- Initialised R environment with required libraries.
- Loaded six datasets from CSV files into RStudio.
- Standardised each dataset to ensure consistent column naming and retained only relevant fields for analysis.
- Standardised all date column formats for consistency. (`Date` for dates, `POSIXct` for datetimes).
- Combined datasets into a unified `combined_data` dataset for further analysis.
- Initiated some data quality checks and exploring inconsistencies in the data.

### Transformed Datasets
1. **patients_transformed**:
   - Retained: `patient_id`, `birthdate`, `age`, `gender`, `city`, `zip`, `income`.
   - Added: `age` calculated from `birthdate`.
   - Applied `clean_names()` to ensure standardised column naming.

2. **conditions_transformed**:
   - Retained: `diagnosis_start`, `diagnosis_stop`, `patient_id`, `encounter_id`, `diagnosis_code`, `diagnosis_description`.
   - Applied `clean_names()` for consistency.

3. **medications_transformed**:
   - Retained: `medication_start`, `medication_stop`, `patient_id`, `encounter_id`, `medication_code`, `medication_name`.
   - Applied `clean_names()` for consistency.

4. **procedures_transformed**:
   - Retained: `procedure_start`, `procedure_stop`, `patient_id`, `encounter_id`, `procedure_code`, `procedure_description`.
   - Applied `clean_names()` for consistency.

5. **organizations_transformed**:
   - Retained: `hospital_id`, `hospital_name`.
   - Applied `clean_names()` for consistency.

6. **encounters_transformed**:
   - Retained: `encounter_id`, `encounter_start`, `encounter_stop`, `patient_id`, `hospital_id`, `encounter_code`, `encounter_description`.
   - Applied `clean_names()` for consistency.

----

### Combined Dataset: `combined_data`
- **Joined Tables**:
   - Used `patient_id` to join `patients_transformed` with `encounters_transformed`.
   - Then used `encounter_id` to join `encounters_transformed` with:
     - `conditions_transformed`
     - `medications_transformed`
     - `procedures_transformed`.
   - Lastly, used `hospital_id` to join `encounters_transformed` with `organizations_transformed`.

- **Standardised Date Columns**:
   - Converted all date columns (`birthdate`, `encounter_start`, `encounter_stop`, etc.) into consistent formats:
     - Dates: `Date` format (`YYYY-MM-DD`).
     - Datetimes: `POSIXct` format (`YYYY-MM-DD HH:MM:SS`).

- **Checked Data Quality**:
   - Inspected for missing values, inconsistencies, and duplicates.
   - Validated relationships between patients, encounters, and other entities.

---

## Code Subdirectory
- **`code/data_cleaning.R`**:
 - A script to:
     - Load and clean datasets.
     - Standardise column names and date formats.
     - Combine the datasets into a joined dataset for analysis.
   - **Status**: Completed initial cleaning and transformation.
