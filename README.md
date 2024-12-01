## Data Engineering Synthetic Health Data Project

This project's objective is to clean and analyse synthetic healthcare data from Synthea. The goal is to uncover trends in patient demographics, diagnoses, procedures, and medications to inform healthcare insights.

----

## Tools Used
- **Programming Language**: R
- **IDE**: RStudio
- **Libraries**: `readr`, `dplyr`, `tidyr`

----

## Progress in Current Branch: `data-cleaning`
### Overview
- Initialised R environment with required libraries.
- Loaded six datasets from CSV files into RStudio.
- Standardised each dataset to ensure consistent column naming and retained only relevant fields for analysis.

### Transformed Datasets
1. **patients_transformed**:
   - Retained: `PATIENT_ID`, `BIRTHDATE`, `AGE`, `GENDER`, `CITY`, `ZIP`, `INCOME`
   - Added: `AGE` calculated from `BIRTHDATE`.

2. **conditions_transformed**:
   - Retained: `DIAGNOSIS_START`, `DIAGNOSIS_STOP`, `PATIENT_ID`, `ENCOUNTER_ID`, `DIAGNOSIS_CODE`, `DIAGNOSIS_DESCRIPTION`.

3. **medications_transformed**:
   - Retained: `MEDICATION_START`, `MEDICATION_STOP`, `PATIENT_ID`, `ENCOUNTER_ID`, `MEDICATION_CODE`, `MEDICATION_NAME`.

4. **procedures_transformed**:
   - Retained: `PROCEDURE_START`, `PROCEDURE_STOP`, `PATIENT_ID`, `ENCOUNTER_ID`, `PROCEDURE_CODE`, `PROCEDURE_DESCRIPTION`.

5. **organizations_transformed**:
   - Retained: `HOSPITAL_ID`, `HOSPITAL_NAME`.

6. **encounters_transformed**:
   - Retained: `ENCOUNTER_ID`, `ENCOUNTER_START`, `ENCOUNTER_STOP`, `PATIENT_ID`, `ORGANIZATION_ID`, `ENCOUNTER_CODE`, `ENCOUNTER_DESCRIPTION`.

----

## Code Subdirectory
- **`code/data_cleaning.R`**:
   - A script to load datasets, inspect for issues, and perform data cleaning and transformations.
   - **Status**: Currently under development.
