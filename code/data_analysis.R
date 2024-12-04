library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)

# Load combined data
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

# Calculating the number of visits for each patient
visits_per_patient <- combined_data %>%
  group_by(patient_id) %>%
  summarise(total_visits = n_distinct(encounter_id)) %>%
  arrange(desc(total_visits))

View(visits_per_patient)

# Count the frequency of diagnoses
diagnosis_frequency <- combined_data %>% 
  group_by(diagnosis_code, diagnosis_description) %>%
  summarise(dg_frequency = n(), .groups = "drop") %>% 
  arrange(desc(dg_frequency))

View(diagnosis_frequency)

# Count the number of medications taken by age group
medications_by_age <- combined_data %>%
  group_by(age_group, medication_code, medication_name) %>%
  summarise(total_prescriptions = n(), .groups = "drop") %>% 
  arrange(desc(total_prescriptions))

View(medications_by_age)

# Calculate the number of medications taken for each encounter
medications_per_encounter <- combined_data %>%
  group_by(encounter_id) %>%
  summarise(total_medications = sum(!is.na(medication_code)), .groups = "drop")

View(medications_per_encounter)

# Calculate the number of procedures by hospital
procedures_per_hospital <- combined_data %>% 
  group_by(hospital_id, hospital_name) %>% 
  summarise(total_procedures = n(), .groups = "drop") %>% 
  arrange(desc(total_procedures))

View(procedures_per_hospital)

## Explore patient distributions by factors
# Count patients by age_group
patients_per_age_group <- combined_data %>%
  group_by(age_group) %>%
  summarise(total_patients = n_distinct(patient_id), .groups = "drop") %>% View()

# Histogram for patient age distribution using 10 bins
hist(combined_data$age, breaks = 10, main = "Age Distribution of Patients", xlab = "Age")

# Count patients by gender
patients_per_gender <- combined_data %>%
  group_by(gender) %>%
  summarise(total_patients = n_distinct(patient_id), .groups = "drop") %>% View()

# Count patients by diagnosis description
patients_per_diagnosis <- combined_data %>%
  group_by(diagnosis_code, diagnosis_description) %>%
  summarise(total_patients = n_distinct(patient_id), .groups = "drop") %>%
  arrange(desc(total_patients))

View(patients_per_diagnosis)

# Frequency of diagnoses
diagnosis_frequency <- combined_data %>%
  group_by(diagnosis_code, diagnosis_description) %>%
  summarise(total_diagnoses = n(), .groups = "drop") %>%
  arrange(desc(total_diagnoses))

View(diagnosis_frequency)

# Frequency of medications
medication_frequency <- combined_data %>%
  group_by(medication_code, medication_name) %>%
  summarise(total_prescriptions = n(), .groups = "drop") %>%
  arrange(desc(total_prescriptions))

View(medication_frequency)

# Extract year and count procedures per year
procedures_over_time <- combined_data %>%
  mutate(procedure_year = format(as.Date(procedure_start), "%Y")) %>%
  group_by(procedure_year) %>%
  summarise(total_procedures = n(), .groups = "drop") %>%
  arrange(procedure_year)

View(procedures_over_time)

# Filter for recent trends in medical procedures
recent_procedures <- combined_data %>%
  mutate(procedure_year = as.numeric(format(as.Date(procedure_start), "%Y"))) %>%
  filter(procedure_year >= 2000) %>%
  group_by(procedure_year) %>%
  summarise(total_procedures = n(), .groups = "drop")

# Create a line plot for recent trends in medical procedures
ggplot(recent_procedures, aes(x = procedure_year, y = total_procedures)) +
  geom_line(size = 1.2, color = "blue") +
  geom_point(size = 3, color = "red") +
  labs(
    title = "Recent Trends in Medical Procedures",
    x = "Year (2000 and later)",
    y = "Total Procedures"
  ) +
  theme_minimal()

# Diagnosis distribution by age group
diagnosis_summary <- combined_data %>%
  group_by(age_group, diagnosis_description) %>%
  summarise(diagnosis_count = n(), .groups = "drop") %>%
  arrange(desc(diagnosis_count))

# Bar chart for diagnosis distribution by age group
ggplot(diagnosis_summary, aes(x = age_group, y = diagnosis_count, fill = age_group)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Diagnosis Distribution by Age Group",
    x = "Age Group",
    y = "Diagnosis Count"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Numerical summary of key columns
numerical_summary <- combined_data %>%
  summarise(
    mean_age = round(mean(age, na.rm = TRUE), 1),
    median_age = round(median(age, na.rm = TRUE), 1),
    sd_age = round(sd(age, na.rm = TRUE), 1),
    mean_length_of_stay = round(mean(length_of_stay, na.rm = TRUE), 2),
    median_length_of_stay = round(median(length_of_stay, na.rm = TRUE), 2),
    sd_length_of_stay = round(sd(length_of_stay, na.rm = TRUE), 2)
  )

View(numerical_summary)

# Boxplot for length of stay with log scale
ggplot(combined_data, aes(x = "", y = log10(length_of_stay + 1))) +
  geom_boxplot(fill = "skyblue", color = "black") +
  labs(
    title = "Boxplot of Length of Stay (Log Scale)",
    y = "Log Length of Stay (Days)",
    x = ""
  ) +
  theme_minimal()

# 1. Diagnoses by Age Group and Gender

# Filter top 10 most common diagnoses, excluding empty fields
top_diagnoses <- combined_data %>%
  filter(!is.na(diagnosis_description)) %>%  # Exclude empty diagnosis descriptions
  group_by(diagnosis_description) %>%
  summarise(total_count = n(), .groups = "drop") %>%
  arrange(desc(total_count)) %>%
  top_n(10)

# Filter dataset for only top diagnoses and exclude empty fields
filtered_data <- combined_data %>%
  filter(
    diagnosis_description %in% top_diagnoses$diagnosis_description,
    !is.na(gender),  # Exclude rows with missing gender
    !is.na(age_group)  # Exclude rows with missing age group
  ) 

# a) Diagnoses Distribution by Gender
ggplot(filtered_data, aes(x = diagnosis_description, fill = gender)) +
  geom_bar(position = "dodge") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top Diagnoses Distribution by Gender",
    x = "Diagnosis",
    y = "Count",
    fill = "Gender"
  )

# b) Diagnoses Distribution by Age Group
ggplot(filtered_data, aes(x = diagnosis_description, fill = age_group)) +
  geom_bar(position = "dodge") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Top Diagnoses Distribution by Age Group",
    x = "Diagnosis",
    y = "Count",
    fill = "Age Group"
  )

# Temporal trends in hospital visits

# Extract year from encounter_start and summarise visits by year
visits_over_time <- combined_data %>%
  mutate(encounter_year = as.numeric(format(as.Date(encounter_start), "%Y"))) %>%
  group_by(encounter_year) %>%
  summarise(total_visits = n(), .groups = "drop") %>%
  filter(!is.na(encounter_year))  # Exclude rows with missing years

# Line chart for hospital visits over time
# Observation: Minimal before 2000; steady increase post 2020; peak at 2020; 
ggplot(visits_over_time, aes(x = encounter_year, y = total_visits)) +
  geom_line(size = 1.2, color = "blue") +
  geom_point(size = 3, color = "red") +
  theme_minimal() +
  labs(
    title = "Temporal Trends in Hospital Visits",
    x = "Year",
    y = "Total Visits"
  )

# Extract year from medication_start and summarise medications by year
medications_over_time <- combined_data %>%
  mutate(medication_year = as.numeric(format(as.Date(medication_start), "%Y"))) %>%
  group_by(medication_year) %>%
  summarise(total_medications = n(), .groups = "drop") %>%
  filter(!is.na(medication_year))  # Exclude rows with missing years

# Line chart for medication use over time
# Observation: Minimal before 2000; steady increase post 2020; peak at 2020; 
ggplot(medications_over_time, aes(x = medication_year, y = total_medications)) +
  geom_line(size = 1.2, color = "blue") +
  geom_point(size = 3, color = "red") +
  theme_minimal() +
  labs(
    title = "Temporal Trends in Medication Use",
    x = "Year",
    y = "Total Medications"
  )

# Identifying the most common diagnoses for patients

# Aggregate diagnoses counts, excluding missing fields
common_diagnoses <- combined_data %>%
  filter(!is.na(diagnosis_description)) %>% # Exclude missing diagnoses
  group_by(diagnosis_description) %>%
  summarise(total_diagnoses = n(), .groups = "drop") %>%
  arrange(desc(total_diagnoses)) %>%
  slice_head(n = 10) # Top 10 diagnoses

# Bar chart for top diagnoses
ggplot(common_diagnoses, aes(x = reorder(diagnosis_description, total_diagnoses), y = total_diagnoses)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  coord_flip() + # Flip axes for better readability
  labs(
    title = "Top 10 Most Common Diagnoses",
    x = "Diagnosis Description",
    y = "Total Diagnoses"
  ) +
  theme_minimal()

# Identifying the most common procedures for patients

# Aggregate procedures counts, excluding missing fields
common_procedures <- combined_data %>%
  filter(!is.na(procedure_description)) %>% # Exclude missing procedures
  group_by(procedure_description) %>%
  summarise(total_procedures = n(), .groups = "drop") %>%
  arrange(desc(total_procedures)) %>%
  slice_head(n = 10) # Top 10 procedures

# Bar chart for top procedures
ggplot(common_procedures, aes(x = reorder(procedure_description, total_procedures), y = total_procedures)) +
  geom_bar(stat = "identity", fill = "orange") +
  coord_flip() + # Flip axes for better readability
  labs(
    title = "Top 10 Most Common Procedures",
    x = "Procedure Description",
    y = "Total Procedures"
  ) +
  theme_minimal()

