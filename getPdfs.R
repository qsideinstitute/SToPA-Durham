# Load libraries
library(gitcreds)
library(tidyverse)
library(RSelenium)
library(pbmcapply)

# Set up a download path
# Must be consistent with whatever is in browserProfile
downloadPath <- "data/"
browserProfile <- getFirefoxProfile("browserProfile/")

# Start Selenium
rD <- rsDriver(browser="firefox", port=4545L, verbose=F, extraCapabilities = browserProfile)
remDr <- rD[["client"]]

# Set search page URL
searchURL <- "https://durhampdnc.policetocitizen.com/EventSearch"

# Go to search page
remDr$navigate(searchURL)

# If necessary, click ACCEPT
# Then click on "By Report Information"
Sys.sleep(2)
suppressMessages(acceptButton <- tryCatch(last(remDr$findElements(using = "xpath", value = '//*[@id="disclaimerDialog"]/md-dialog-actions/button[2]/span')),error = function(e){NULL}))
if (!is.null(acceptButton)) {
  acceptButton$clickElement()
}
Sys.sleep(2)
suppressMessages(reportinfoButton <- tryCatch(last(remDr$findElements(using = "xpath", value = '//*[@id="byReportInformation-card"]/md-card-title/md-card-title-text/span[1]')),error = function(e){NULL}))
if (!is.null(reportinfoButton)) {
  reportinfoButton$clickElement()
}

# Get date input fields
Sys.sleep(1)
datePickers <- remDr$findElements(using = "class", value = "md-datepicker-input")
startPicker <- datePickers[[1]]
endPicker <- datePickers[[2]]

# Set desired dates
# For now I have made them fixed, but y'all should really
# write a function that takes start/end dates as inputs
# So you can go over all desired months
startdate <- "01/01/2019"
enddate <- "01/31/2019"

# Fill in start and end dates on web form
# Find search button
# Click search button
startPicker$clearElement()
startPicker$sendKeysToElement(list(startdate))
endPicker$clearElement()
endPicker$sendKeysToElement(list(enddate))
remDr$click(buttonId = "search-button")
searchButton <- remDr$findElement(using = "id", value = "search-button")
Sys.sleep(1)
searchButton$clickElement()

# Find "Load More" button and continue to click until no more can be loaded
Sys.sleep(5)
loadFlag <- TRUE
while (loadFlag == TRUE) {
  suppressMessages(loadmoreButton <- tryCatch(last(remDr$findElements(using = "xpath", value = '//*[@id="event-search-results"]/event-search-results/div/div[2]/div[3]/button/span')),error = function(e){NULL}))
  if (!is.null(loadmoreButton)) {
    loadmoreButton$clickElement()
    Sys.sleep(0.1)
  } else {
    loadFlag <- FALSE
  }
}

# Get button for each result
results <- remDr$findElements(using = "css selector", value = "div.p2c-eventSearch-result > md-card:nth-child(1) > md-card-content:nth-child(1) > div:nth-child(3) > div:nth-child(1) > div:nth-child(1) > i:nth-child(1)")

# Get files
for (i in 1:length(results)) {
  if (i %% 10 == 0) print(i)
  results[[i]]$clickElement()
  Sys.sleep(1.5)
}

# Rename files
# Set up filenames
idx <- 1:length(results)
filenos <- str_pad(idx, width = 7, pad = "0")
filenamestart <- str_replace_all(as.Date(startdate,"%m/%d/%Y"),"-","")
filenames <- paste0(downloadPath,filenamestart,"-",filenos,".pdf")
idx <- rev(idx)
origFiles <- paste0(downloadPath,"pdf(",idx,")")
rename <- function(i){
  tryCatch(out <- file.rename(origFiles[i],filenames[i]))
}
pbmclapply(idx, rename)


out <- file.rename(paste0(downloadPath,"pdf"),filenames[i])


# Shut down Selenium
rD[["server"]]$stop()