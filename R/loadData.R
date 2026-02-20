# The MIT License (MIT)
# Copyright (c) 2018 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


# Loads one person's data from cleaned CGM data file.
# Input data has columns: bgReading, sgReading, meal, Exercise, Medication, time.
# Returns list object containing participant ID and 3 data frames: sg, bg and events.

loadData <- function(fileName, userID, rs) {
  dir <- rs@indir
  rawData <- read.table(paste(dir, "/", fileName, sep = ""), sep = ",", header = 1)

  ## REQUIRED COLUMNS
  ## check it has required fields
  
  colName <- "Video.Time"
  idx <- which(names(rawData) == colName)
  if (length(idx) == 0) {
    stop(paste("Column missing from input file:", colName), call. = FALSE)
  }

  # change time stamps to just be number of seconds from the start, with a 0.02 second gap
  rawData$Video.Time <- 0.02*(1:nrow(rawData))
  
  # events <- NULL
  # if (length(which(names(rawData) == "meal") > 0)) {
  #   eventsMeal <- rawData[which(!is.na(rawData$meal) & rawData$meal != ""), ]

  #   if (nrow(eventsMeal) > 0) {
  #     # make sure all events are rounded to the nearest minute
  #     eventsMeal$time <- trunc(eventsMeal$time, "secs")
  #     eventsMeal$event <- "MEAL"
  #     events <- eventsMeal
  #   }
  # }

  #events <- events[, c("time", "event")]

  # assume emotions are all columns exept Video.Time
  emotionsCols <- setdiff(names(rawData), "Video.Time")
  
  # convert emotion columns to numeric so that all the error codes become NA
  rawData[ , emotionsCols] <- lapply(rawData[ , emotionsCols], as.numeric)
  
  # make column to indication the row has been imputed
  rawData$imputed <- F

  # participantData <- list(id = userID, sg = sgReadings, bg = bgReadings, events = events)
  participantData <- list(id = userID, emotions = rawData, emotionColumns = emotionsCols)

  return(participantData)
}
