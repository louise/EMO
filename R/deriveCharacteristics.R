# The MIT License (MIT)
# Copyright (c) 2026 Louise AC Millard, MRC Integrative Epidemiology Unit, University of Bristol
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


# Derives variables that describe characteristics of the SG sequence.
# Returns a data frame containing these characteristics values.
deriveCharacteristics <- function(raw, userIDdf, rs) {
    
  print("MAD")
  # Median absolute deviation for each day
  emotionData <- raw$emotions
  madValues <- data.frame(as.list(sapply(emotionData[,raw$emotionColumns], mad, constant=1, na.rm=T)))
  names(madValues) <- paste0(names(madValues), "_mad")

  # num peaks - this was just to check if the number of undulations decreases as mad increases
  # nps = numPeaksByDay(validDays)

  print("AUC")
  aucValues <- data.frame(as.list(sapply(emotionData[,raw$emotionColumns], auc)))
  names(aucValues) <- paste0(names(aucValues), "_auc")

  # print("Time proportions")
  # # Proportion of time spent in low, medium and high glucose ranges, on each complete day
  # proportions <- timeProportionsByDay(validDays, rs@hypothreshold, rs@hyperthreshold)

  print("sGVP")
  labilityValues <- data.frame(as.list(sapply(emotionData[,raw$emotionColumns], SGVP, stdx=T)))
  names(labilityValues) <- paste0(names(labilityValues), "_lability")

  # ## add number of valid days to derived statistics
  # othervars <- c(length(validDays))
  # othervars <- rbind(othervars)
  # colnames(othervars) <- c("numValidDays")


  # print("Events")
  # meal time statistics
  # eventValues <- eventStatisticsByDay(validDays, rs, userIDdf)
  eventValues <- NULL

  # missingness
  print("missing summary")
  numRows <- nrow(emotionData)
  numRowsImputed <- length(which(emotionData$imputed==T))
  
  # get the distribution of the length of the missing runs (blocks)
  r <- rle(emotionData$imputed)
  true_runs <- r$lengths[r$values]
  imputedBlockDistribution <- data.frame(as.list(quantile(true_runs, probs = c(0, 0.25, 0.5, 0.75, 1))))
  names(imputedBlockDistribution) <- c('miss_block_length_Q0','miss_block_length_Q25','miss_block_length_Q50','miss_block_length_Q75','miss_block_length_Q100')
  
  missingnessDF <- data.frame(totalRows=numRows, numImputed=numRowsImputed)
  missingnessDF <- cbind(missingnessDF, imputedBlockDistribution)
  
  # whole result row for this participant
  summThis <- cbind(userIDdf, madValues, aucValues, labilityValues, missingnessDF)
  
  if (!is.null(eventValues)) {
    summThis <- cbind.data.frame(summThis, eventValues)
  }

  return(summThis)
}
