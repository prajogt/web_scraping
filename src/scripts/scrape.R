# Workspace setup
library(xml2)
library(tidyverse)
library(janitor)
library(rvest)

pm_data <- read_html("src/data/raw_data.html")

# Locate the wikitable elements
parse_data_selector_gadget <-
  pm_data |> 
  html_elements(".wikitable") |>
  html_table()

# Select only the second wikitable
# which contains our desired information
parse_data_selector_gadget <-
  parse_data_selector_gadget[[2]]


# Get the relevant data
parsed_data <-
  parse_data_selector_gadget |>
  clean_names() |>
  rename(raw_text = name_birth_death) |>
  # All the data we need is in this col
  select(raw_text) |> 
  # Select each PM only once
  distinct() |>
  # Remove junk row
  filter(!grepl(".mw-parser-output", raw_text))

# Clean data
clean_data <-
  parsed_data |>
  separate(
    raw_text, 
    into = c("name", "not_name"), 
    sep = "\\(", 
    extra = "merge"
  ) |>
  mutate(date = str_extract(not_name, "[[:digit:]]{4}–[[:digit:]]{4}"),
         dob = str_extract(not_name, "b. [[:digit:]]{4}")) |>
  mutate(dob = str_extract(dob, "[[:digit:]]{4}")) |>
  select(name, date, dob)

# Separate into DOB and DOD
clean_data <- 
  clean_data |>
  separate(date, into = c("birth", "death"), sep = "–") |>
  mutate(
    birth = if_else(!is.na(birth), birth, dob)
  ) |>
  mutate(across(c(birth, death), as.integer)) |>
  mutate(age_at_death = death - birth) |>
  select(name, birth, death, age_at_death)

# Store scraped data
write_csv(clean_data, "src/data/clean_canadian_pms.csv")
  
