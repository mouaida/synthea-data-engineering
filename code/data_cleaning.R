library(readr)
library(dplyr)


# Load the CSV data files into environment
conditions <- read_csv("conditions.csv")
encounters <- read_csv("encounters.csv")
medications <- read_csv("medications.csv")
organizations <- read_csv("organizations.csv")
patients <- read_csv("patients.csv")
procedures <- read_csv("procedures.csv")

# Check datasets imported correctly
glimpse(procedures)

