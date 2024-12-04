library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)

combined_data <- read.csv("combined_data.csv")

## Create new variables to be used for analysis
combined_data <- combined_data %>%
  mutate( 
    # Used broad age groups to have sufficient number of records in each group for analysis
    age_group = case_when(
      age <= 17 ~ "0-17",
      age >= 18 & age <= 34 ~ "18-34",
      age >= 35 & age <= 64 ~ "35-64",
      age >= 65 ~ "65+"
    ),
    # Numeric code will be useful for sorting and analysis
    age_group_code = case_when(
      age <= 17 ~ 1,
      age >= 18 & age <= 34 ~ 2,
      age >= 35 & age <= 64 ~ 3,
      age >= 65 ~ 4
    ),
    # Calculating the length of stay at a hospital
    # Can be used to identify factors influencing long stays
    length_of_stay = as.numeric(difftime(encounter_stop, encounter_start, units = "days"))
  )

## Create data aggregates

visits_per_patient <- combined_data %>%
  group_by(patient_id) %>%
  # Calculating number of visits for each patient
  summarise(total_visits = n_distinct(encounter_id)) %>%
  arrange(desc(total_visits))

View(visits_per_patient)

diagnosis_frequency <- combined_data %>% 
  group_by(diagnosis_code, diagnosis_description) %>%
  # count the number of times a patient came in for each diagnosis
  summarise(dg_frequency = n(), .groups = "drop") %>% 
  arrange(desc(dg_frequency))

View(diagnosis_frequency)

# Calculate the numbers of meds taken by age group
medications_by_age <- combined_data %>%
  group_by(age_group, medication_code, medication_name) %>%
  summarise(total_prescriptions = n(), .groups = "drop") %>% 
  arrange(desc(total_prescriptions))

View(medications_by_age)

# Calculate the number of medications taken for each encounter
medications_per_encounter <- combined_data %>%
  group_by(encounter_id) %>%
  # For each encounter, return number of medications taken
  summarise(total_medications = sum(!is.na(medication_code)), .groups = "drop")

View(medications_per_encounter)

# Calculate the number of procedures by Hospital
procedures_per_hospital <- combined_data %>% 
  group_by(hospital_id, hospital_name) %>% 
  summarise(total_procedures= n(), .groups = "drop") %>% 
  arrange(desc(total_procedures))

View(procedures_per_hospital)