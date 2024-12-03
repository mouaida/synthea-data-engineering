library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(janitor)

## 1.	Load the dataset into your environment.

# Load the CSV data files into environment
conditions <- read_csv("conditions.csv")
encounters <- read_csv("encounters.csv")
medications <- read_csv("medications.csv")
organizations <- read_csv("organizations.csv")
patients <- read_csv("patients.csv")
procedures <- read_csv("procedures.csv")

# Check datasets imported correctly by previewing the structure and first few rows
glimpse(encounters)
head(procedures)

## Creating sample dataset with only the required columns from the 6 datasets

# Create a new transformed patients dataset
patients_transformed <- patients %>%
  rename(
    patient_id = Id
  ) %>% 
  mutate(
    # Convert date columns to Date format
    BIRTHDATE = as.Date(BIRTHDATE, format = "%d/%m/%Y"),
    # Create `age` by calculating the difference between today’s date and the BIRTHDATE
    # The result is the difference in days that gets divided by 365 to get age in years
    age = as.numeric(as.integer((Sys.Date() - as.Date(BIRTHDATE)) / 365)),
    INCOME = as.numeric(INCOME),
    # Remove 00000 values in zip code as they are likely a placeholder for missing data
    # Converting to empty allows more accurate analysis
    ZIP = na_if(ZIP, "00000")) %>%
  select(patient_id, BIRTHDATE, age, GENDER, CITY, ZIP, INCOME) %>% 
  # clean_names() used to standardise column names for all datasets
  clean_names() # %>% View()
  

# Create a new transformed conditions dataset with standardised column names
conditions_transformed <- conditions %>% 
  # Rename and standardise column names
  rename( 
    patient_id = PATIENT,           
    encounter_id = ENCOUNTER,
    diagnosis_code = CODE,             
    diagnosis_description = DESCRIPTION,
    diagnosis_start = START,
    diagnosis_stop = STOP
  ) %>%
  mutate(
    # Convert date columns to Date format
    diagnosis_start = as.Date(diagnosis_start, format = "%d/%m/%Y"),
    diagnosis_stop = as.Date(diagnosis_stop, format = "%d/%m/%Y"),
    # Convert code columns to character due to long code values being displayed in other formats
    diagnosis_code = as.character(diagnosis_code)
  ) %>% 
  # Select only the relevant columns with standardised column names
  select(diagnosis_start, diagnosis_stop, patient_id, encounter_id, diagnosis_code, diagnosis_description) %>%
  clean_names()# %>% View()

# Create a new transformed medications dataset
medications_transformed <- medications %>%
  # Rename and standardise column names
  rename(
    patient_id = PATIENT,
    encounter_id = ENCOUNTER,
    medication_code = CODE,
    medication_name = DESCRIPTION,
    medication_start = START,
    medication_stop = STOP
  ) %>%
  mutate(
    # Convert datetime columns to POSIXct format
    medication_start = as.POSIXct(medication_start, format = "%d/%m/%Y %H:%M"),
    medication_stop = as.POSIXct(medication_stop, format = "%d/%m/%Y %H:%M"),
    # Convert code columns to character due to long code values being displayed in other formats
    medication_code = as.character(medication_code)
  ) %>% 
  select(medication_start, medication_stop, patient_id, encounter_id, medication_code, medication_name) %>%
  clean_names() # %>% View()

# Create a new transformed procedures dataset with standardised column names
procedures_transformed <- procedures %>%
  rename(
    patient_id = PATIENT,
    encounter_id = ENCOUNTER,
    procedure_code = CODE,
    PROCEDURE_DESCRIPTION = DESCRIPTION,
    procedure_start = START,
    procedure_stop = STOP
  ) %>%
  mutate(
    # Convert datetime columns to POSIXct format
    procedure_start = as.POSIXct(procedure_start, format = "%d/%m/%Y %H:%M"),
    procedure_stop = as.POSIXct(procedure_stop, format = "%d/%m/%Y %H:%M"),
    # Convert all code columns to character due to long code values being displayed in other formats
    procedure_code = as.character(procedure_code)
  ) %>% 
  select(procedure_start, procedure_stop, patient_id, encounter_id, procedure_code, PROCEDURE_DESCRIPTION) %>% 
  clean_names()# %>% View()


# Create a new transformed organizations dataset with standardised column names
organizations_transformed <- organizations %>%
  rename(
    hospital_id = Id,
    hospital_name = NAME
  ) %>%
  select(hospital_id, hospital_name) %>% 
  clean_names() # %>% View()

# Create a new transformed encounters dataset with relevant columns
encounters_transformed <- encounters %>%
  rename(
    encounter_id = Id,
    encounter_start = START,
    encounter_stop = STOP,
    patient_id = PATIENT,
    hospital_id = ORGANIZATION,
    encounter_code = CODE,
    encounter_description = DESCRIPTION
  ) %>%
  mutate(
    # Convert datetime columns to POSIXct format
    encounter_start = as.POSIXct(encounter_start, format = "%d/%m/%Y %H:%M"),
    encounter_stop = as.POSIXct(encounter_stop, format = "%d/%m/%Y %H:%M")
  ) %>% 
  select(encounter_id, encounter_start, encounter_stop, patient_id, hospital_id, encounter_code, encounter_description) %>% 
  clean_names()# %>% View()

## Merge datasets
combined_data <- patients_transformed %>% 
  left_join(encounters_transformed, by = "patient_id") %>% 
  left_join(conditions_transformed, by = c("patient_id", "encounter_id")) %>%
  left_join(medications_transformed, by = c("patient_id", "encounter_id"), relationship = "many-to-many") %>%
  left_join(procedures_transformed, by = c("patient_id", "encounter_id"), relationship = "many-to-many") %>%
  left_join(organizations_transformed, by = "hospital_id")

View(combined_data)

## 2.	Inspect the data for missing values, inconsistencies, and data types - Data quality checks

# Confirm the number of rows and cols
dim(combined_data)

# Confirm col names as expected
colnames(combined_data)

# Confirm if missing data is as expected
combined_data %>%
  # Apply the missing value count function (sum(is.na(.))) to all columns
  summarise(across(everything(), ~ sum(is.na(.)))) %>% 
  # Pivot the data to have a narrow readable format
  pivot_longer(cols = everything(), names_to = "Column", values_to = "Missing_Count") %>%
  # Calculate the percentage of missing values using Missing_Count and nrow(combined_data)
  mutate(Missing_Percentage = round(Missing_Count / nrow(combined_data) * 100, 2)) %>%
  # Sort in descending order by the number of missing values
  arrange(desc(Missing_Count)) %>% View()
  
# Check encounters are tied to one patient - Returns no data if true
combined_data %>%
  group_by(encounter_id) %>%
  # Count the number of unique patients for each encounter_id
  # .groups = "drop" removes grouping after summarisation
  summarise(unique_patients = n_distinct(patient_id), .groups = "drop") %>%
  filter(unique_patients > 1) %>% View()

# Check unique columns are as expected
combined_data %>% 
  summarise( # Count number of distinct values for key columns
    distinct_patients = n_distinct(patient_id),
    distinct_encounters = n_distinct(encounter_id),
    distinct_procedures = n_distinct(procedure_code),
    distinct_medications = n_distinct(medication_code),
    distinct_diagnoses = n_distinct(diagnosis_code),
    total_rows = n()
  )

# Confirm no duplicates are present
combined_data %>%
  summarise(duplicate_rows = n() - n_distinct(.)) %>% View()

# Check that each patient is linked to an encounter
combined_data %>%
  group_by(patient_id) %>% 
  # counts number of encounters for each patient
  summarise(total_encounters = n_distinct(encounter_id)) %>%
  arrange(desc(total_encounters)) %>% View()

# Check what each encounter is linked to 
combined_data %>%
  group_by(encounter_id) %>%
  summarise( # counts every non empty value for each column
    conditions_count = sum(!is.na(diagnosis_code)),
    procedures_count = sum(!is.na(procedure_code)),
    medications_count = sum(!is.na(medication_code))
  ) %>% View()

# Export to CSV to inspect data further
write.csv(combined_data, "combined_data.csv", row.names = FALSE)




