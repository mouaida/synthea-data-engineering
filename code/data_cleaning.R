library(readr)
library(dplyr)
library(tidyr)

## 1.	Load the dataset into your environment.

# Load the CSV data files into environment
conditions <- read_csv("conditions.csv")
encounters <- read_csv("encounters.csv")
medications <- read_csv("medications.csv")
organizations <- read_csv("organizations.csv")
patients <- read_csv("patients.csv")
procedures <- read_csv("procedures.csv")

# Check datasets imported correctly by previewing the structure and first few rows
glimpse(procedures)
head(procedures)

## Creating sample dataset with only the required columns from the 6 datasets

# 1. Create a new transformed patients dataset
patients_transformed <- patients %>%
  rename(
    PATIENT_ID = Id
  ) %>% 
  # Create `age` by calculating the difference between today’s date and the BIRTHDATE
  # The result is the difference in days that gets divided by 365 to get age in years
  mutate(AGE = as.integer((Sys.Date() - as.Date(BIRTHDATE)) / 365)) %>%
  select(PATIENT_ID, BIRTHDATE, AGE, GENDER, CITY, ZIP, INCOME) # %>% View()
  

# 2. Create a new transformed conditions dataset with standardised column names
conditions_transformed <- conditions %>% 
  # Rename and standardise column names
  rename( 
    PATIENT_ID = PATIENT,           
    ENCOUNTER_ID = ENCOUNTER,        
    DIAGNOSIS_CODE = CODE,             
    DIAGNOSIS_DESCRIPTION = DESCRIPTION,
    DIAGNOSIS_START = START,
    DIAGNOSIS_STOP = STOP
  ) %>%
  # Select only the relevant columns with standardised column names
  select(DIAGNOSIS_START, DIAGNOSIS_STOP, PATIENT_ID, ENCOUNTER_ID, DIAGNOSIS_CODE, DIAGNOSIS_DESCRIPTION) # %>% View()

# 3. Create a new transformed medications dataset
medications_transformed <- medications %>%
  # Rename and standardise column names
  rename(
    PATIENT_ID = PATIENT,
    ENCOUNTER_ID = ENCOUNTER,
    MEDICATION_CODE = CODE,
    MEDICATION_NAME = DESCRIPTION,
    MEDICATION_START = START,
    MEDICATION_STOP = STOP
  ) %>%
  select(MEDICATION_START, MEDICATION_STOP, PATIENT_ID, ENCOUNTER_ID, MEDICATION_CODE, MEDICATION_NAME) # %>% View()

# 4. Create a new transformed procedures dataset with standardised column names
procedures_transformed <- procedures %>%
  rename(
    PATIENT_ID = PATIENT,
    ENCOUNTER_ID = ENCOUNTER,
    PROCEDURE_CODE = CODE,
    PROCEDURE_DESCRIPTION = DESCRIPTION,
    PROCEDURE_START = START,
    PROCEDURE_STOP = STOP
  ) %>%
  select(PROCEDURE_START, PROCEDURE_STOP, PATIENT_ID, ENCOUNTER_ID, PROCEDURE_CODE, PROCEDURE_DESCRIPTION) # %>% View()


# 5. Create a new transformed organizations dataset with standardised column names
organizations_transformed <- organizations %>%
  rename(
    HOSPITAL_ID = Id,
    HOSPITAL_NAME = NAME
  ) %>%
  select(HOSPITAL_ID, HOSPITAL_NAME) # %>% View()

# 6. Create a new transformed encounters dataset with relevant columns
encounters_transformed <- encounters %>%
  rename(
    ENCOUNTER_ID = Id,
    ENCOUNTER_START = START,
    ENCOUNTER_STOP = STOP,
    PATIENT_ID = PATIENT,
    ORGANIZATION_ID = ORGANIZATION,
    ENCOUNTER_CODE = CODE,
    ENCOUNTER_DESCRIPTION = DESCRIPTION
  ) %>%
  select(ENCOUNTER_ID, ENCOUNTER_START, ENCOUNTER_STOP, PATIENT_ID, ORGANIZATION_ID, ENCOUNTER_CODE, ENCOUNTER_DESCRIPTION) # %>% View()

# Joining the tables.


## 2.	Inspect the data for missing values, inconsistencies, and data types 

# Count missing values in each required column

# patients %>%
#   summarise(across(everything(), ~ sum(is.na(.)))) %>%
#   pivot_longer(cols = everything(), names_to = "Column_name", values_to = "Missing_Values") %>%
#   filter(Missing_Values > 0)


