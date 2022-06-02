# Load libraries
library(tidyverse)
library(tabulizer)

# Set data directory
datadir <- "data/"

# You're going to need to make sure you go to JUST the arrest .pdfs
# Get a list of them here
# For now, I will set some files manually
files <- dir(datadir)
samplearrests <- str_pad(c(24,26,27,28), width = 7, pad = "0")
mymonth <- "20190101"
arrestFiles <- paste0(datadir,mymonth,"-",samplearrests,".pdf")

# Set up scraping areas
# agencynamearea <- locate_areas(arrestFiles[1])
# namearea <- locate_areas(arrestFiles[1])

# Save areas
# save(agencynamearea, namearea, file = "arrestAreas.Rdata")

# At this point, load the area coordinates
load("arrestAreas.Rdata")

# As a test, loop over files to parse agency name and aresstee name
extractData <- function(arrestFile) {
  agencyname <- extract_text(arrestFile, area = agencynamearea)
  name <- extract_text(arrestFile, area = namearea)
  data.frame(agencyname = agencyname, name = name)
}
data <- lapply(arrestFiles, extractData) %>%
  bind_rows()