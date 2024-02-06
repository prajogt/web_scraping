# Workspace setup
library(xml2)
library(tidyverse)

# Download and store from website
canadian_prime_ministers <- read_html("https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Canada")
write_html(canadian_prime_ministers, "src/data/raw_data.html")



