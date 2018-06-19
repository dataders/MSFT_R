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

fname <- list(
    input = 'data/mht_lab2.xdf',
    stage = 'stage/mht_lab2.xdf'
)

mht <- fname %>% map(RxXdfData)

rxSummary(~ tip_percent, mht$input)


# Q1 & Q2 -----------------------------------------------------------------

model <- list(
    one = "tip_percent ~ trip_duration + pickup_dow:pickup_hour",
    two = "tip_percent ~ payment_type_desc + trip_duration + pickup_dow:pickup_hour"
    ) %>%
    map(as.formula) %>%
    map(rxLinMod, data = mht$input)

map(model, "adj.r.squared")

