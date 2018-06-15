
# Notes -------------------------------------------------------------------

# You need this to decode some info
# http://www.nyc.gov/html/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf

# Setup -------------------------------------------------------------------

options(max.print = 1000, scipen = 999, width = 90)
library(RevoScaleR)
rxOptions(reportProgress = 1) # reduces the amount of output RevoScaleR produces
library(tidyverse)
options(dplyr.print_max = 2000)
options(dplyr.width = Inf) # shows all columns of a tbl_df object

# library(rgeos) # spatial package
# library(sp) # spatial package
# library(maptools) # spatial package
# library(ggmap)
# library(ggplot2)
# library(gridExtra) # for putting plots side by side
# library(ggrepel) # avoid text overlap in plots
# library(seriation) # package for reordering a distance matrix


# Read --------------------------------------------------------------------

xdf_str <- list(
    input = 'data/nyc_lab1.xdf',
    stage = 'stage/nyc_lab1.xdf'
)

nyc_xdf <- xdf_str %>% map(RxXdfData)

rxsum_xdf <- rxSummary( ~ fare_amount, nyc_xdf$input) # provide statistical summaries for fare amount
rxsum_xdf

rxGetInfo(nyc_xdf$input, getVarInfo = TRUE, numRows = 5)

# Based on the information in the data dictionary, run a transformation that converts RatecodeID and payment_type into factor columns (if it's not one already) with the proper labels. 
# Name the new variables Ratecode_type_desc and payment_type_desc.
# For Ratecode_type_desc, use all the levels as described in the data dictionary. Those who aren't belong to any of the labels, should be categorised as missing values.
#For payment_type_desc, lump anything that isn't card or cash into missing values.

rxSummary(~ RatecodeID + payment_type, nyc_xdf$input)

# Transformation Function -------------------------------------------------

factorize <- function(data) {
    
    data$Ratecode_type_desc <- factor(
        data$RatecodeID,
        levels = c(1:6,99),
        labels = c("Standard Rate", "JFK", "Newark",
                   "Group Ride",
                   "Nassau or Westchester",
                   "Negotiated Fare", NA)
    )
    data$payment_type_desc <- factor(
        data$payment_type,
        levels = 1:6,
        labels = c("Credit card", "Cash",
                   "No Charge", "Dispute",
                   "Unknown", "Voided Trip"),
        exclude = c("No Charge", "Dispute",
        "Unknown", "Voided Trip")
    )
    data
}


# Testing -----------------------------------------------------------------

# create small testing df 
df_test <- rxDataStep(nyc_xdf$input, numRows = 1000)

# does function work with df?
test1 <- factorize2(df_test)
# and inside of rxDataStep?
test2 <- rxDataStep(df_test, 
                   transformFunc = factorize2)
# and on the whole data set?/
rxDataStep(nyc_xdf$input, nyc_xdf$stage, overwrite = TRUE, 
           transformFunc = factorize2)


rxSummary(~ Ratecode_type_desc + payment_type_desc, nyc_xdf$stage)

rxSummary(~ payment_type + payment_type_desc, nyc_xdf$stage)

rxSummary(~ RatecodeID + Ratecode_type_desc, nyc_xdf$stage)
