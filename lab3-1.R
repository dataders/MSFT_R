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

rxSummary(~ payment_type_desc + trip_distance + trip_duration, mht$input)


# Q1 ----------------------------------------------------------------------

rxCrossTabs(~ payment_type_desc:Ratecode_type_desc, mht$input)

# Q2 ----------------------------------------------------------------------

rxCrossTabs(~ trip_distance:trip_duration, mht$input, transforms = expression(list(
    trip_duration = as.factor(ifelse((trip_duration/60) > 10, "long", "short")),
    trip_distance = as.factor(ifelse(trip_distance > 5, "long", "short"))
    )),
    rowSelection = payment_type_desc == "card"
)