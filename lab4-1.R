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
    
    stage = 'stage/mht_lab2.xdf',
    redo = 'stage/mht_lab2_2.xdf'
)

mht <- fname %>% map(RxXdfData)

rxSummary(~ tip_percent, mht$input)

# SECTION 1

## Q1 & Q2 -----------------------------------------------------------------

model <- list(
    one = "tip_percent ~ trip_duration + pickup_dow:pickup_hour",
    two = "tip_percent ~ payment_type_desc + trip_duration + pickup_dow:pickup_hour"
    ) %>%
    map(as.formula) %>%
    map(rxLinMod, data = mht$input, dropFirst = TRUE, covCoef = TRUE)

map(model, "adj.r.squared")

# SECTION 2


pred <- rxPredict(model$one, mht$input, outData = mht$stage,
                  writeModelVars = TRUE,
                  predVarNames = "tip_pred_1")



pred <- rxPredict(model$two, pred, outData = mht$stage,
                  writeModelVars = TRUE,
                  predVarNames = "tip_pred_2")


head(pred)
# Q3 ----------------------------------------------------------------------
histo <- rxHistogram(~ tip_percent, pred,
                     rowSelection = (tip_percent < 50) & (tip_percent >0))


# Q4 ----------------------------------------------------------------------

histo <- rxHistogram(~ tip_pred_1, pred,
                     rowSelection = (tip_percent < 50) & (tip_percent >0)
                     # ,numBreaks = 20
)

histo <- rxHistogram(~ tip_pred_2, pred,
                     rowSelection = (tip_percent < 50) & (tip_percent >0)
                     # ,numBreaks = 20
)
