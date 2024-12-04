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
- Transformed and cleaned columns, including:
  - Converted date columns to consistent formats (`Date` or `POSIXct`).
  - Replaced invalid `ZIP` values (`00000`) with `NA`.
  - Converted long numeric codes (e.g., `procedure_code`, `diagnosis_code`) to character format.
- Combined datasets into a single `combined_data` dataset for further analysis.
- Conducted initial data quality checks, including:
  - Validating relationships between patients, encounters, and other entities.
  - Inspecting for missing values, inconsistencies, and duplicates.

---

### Transformed Datasets
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

### Combined Dataset: `combined_data`
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

### Data Quality Checks
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

## Code Subdirectory
- **`code/data_cleaning.R`**:
 - A script to:
     - Load and clean datasets.
     - Standardise column names and data types/formats.
     - Combine the datasets into a joined dataset for analysis.
   - **Status**: Completed cleaning and transformations.
