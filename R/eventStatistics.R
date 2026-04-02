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


# Derive post-event AUC for the 3 second period directly after each event
# Returns the average of these statistics for each event type
eventStatistics <- function(raw) {

  # get event types for time series up to last possible index with 3 seconds after
  blockLength = 150
  blockStartLimit = nrow(raw$emotions)-blockLength
  eventTypes <- setdiff(unique(raw$emotions$event[1:blockStartLimit]), "none")

  if (length(eventTypes) == 0) {
    print("No events")
    return(NULL)
  }

  # get event-based measures for each event type
  eventValues <- sapply(eventTypes, eventStatisticsByType, raw=raw)

  # convert from a matrix to a single row of a data frame
  df_row <- as.data.frame(t(as.vector(eventValues)))
  colnames(df_row) <- as.vector(outer(rownames(eventValues), colnames(eventValues), paste, sep = "_"))
  
  return(df_row)

}

# get the mean AUC and MAD across all event occurences for a particular event type
eventStatisticsByType <- function(eventType, raw) {

  # get last possible index with 3 seconds after
  blockLength = 150
  blockStartLimit = nrow(raw$emotions)-blockLength

  # get the start index of each event of type eventType
  idxEv <- which(
    raw$emotions$event[1:blockStartLimit] == eventType &
    c(TRUE, head(raw$emotions$event[1:blockStartLimit], -1) != eventType)
  )

  for (i in 1:length(idxEv)) {
    idxThisEv <- idxEv[i]

    # 3 second post event AUC
    aucValues <- data.frame(as.list(sapply(raw$emotions[idxThisEv:(idxThisEv+150-1),raw$emotionColumns], auc)))
    madValues <- data.frame(as.list(sapply(raw$emotions[idxThisEv:(idxThisEv+150-1),raw$emotionColumns], mad, constant=1, na.rm=T)))
    
    # set names for auc and mad values
    names(aucValues) <- paste0(names(aucValues), "_event_auc")
    names(madValues) <- paste0(names(madValues), "_event_mad")
    
    if (i==1) {
      evVals = cbind(aucValues, madValues)
    }
    else {
      evVals <- rbind(evVals, cbind(aucValues, madValues))
    }

  }

  # get mean across all occurences of this event type
  evVals = colMeans(evVals, na.rm = TRUE)

  # add number of events
  evVals["events_n"] <- length(idxEv)

  return(evVals)

}
