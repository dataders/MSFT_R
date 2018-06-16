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



# Q1 ----------------------------------------------------------------------
# rxHistogram( ~ trip_distance, nyc_xdf,
    # startVal = 0, endVal = 25, histType = "Percent", numBreaks = 20)

rxHistogram(~ tip_percent, mht$input,
            numBreaks = 20)


# Q2 & Q3 -----------------------------------------------------------------

rxHistogram(~ tip_percent|payment_type_desc, mht$input,
            numBreaks = 20)


# Q4 ----------------------------------------------------------------------

rxHistogram(~ tip_percent|payment_type_desc, mht$input,
            numBreaks = 20, transforms = expression(list(
                tip_percent = cut(tip_percent,
                                  breaks=c(-Inf, 5, 10, 15, 20, 25, Inf),
                                  labels=c("Up to 5","5-10","10-15", "15-20",
                                           "20-25", "25+")
                                  )
                ))
            )

# Q5 ----------------------------------------------------------------------

rxHistogram(~ tip_percent|Ratecode_type_desc, mht$input,
            numBreaks = 20,
            histType = "Percent",
            rowSelection = payment_type_desc == "card",
            transforms = expression(list(
                tip_percent = cut(tip_percent,
                                  breaks=c(-Inf, 5, 10, 15, 20, 25, Inf),
                                  labels=c("Up to 5","5-10","10-15", "15-20",
                                           "20-25", "25+")
                )
            ))
)

