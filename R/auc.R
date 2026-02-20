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


# Calculate AUC using trapezoid method.
# Returns AUC value for sequence raw.
auc <- function(raw) {

  if (any(is.na(raw))) {
    stop("there are NAs but there shouldn't be")
  }

  # total time period of SG data in raw
  timeLengthPeriod <- 0

  # for each timepoint, add auc between this timepoint and the previous timepoint
  aucValue <- 0

  if (length(raw) > 1) {
    for (idx in 2:length(raw)) {
      timeDiffSecs <- 0.02 #as.numeric(difftime(data$time[idx], data$time[idx - 1], units = "mins"))

      #if (timeDiffMins == 1) {
        trapezoid <- (raw[idx] + raw[idx - 1]) * timeDiffSecs * 0.5
        aucValue <- aucValue + trapezoid

        timeLengthPeriod <- timeLengthPeriod + timeDiffSecs
      #}
    }
  }

  # convert to auc per minute
  aucValue <- aucValue / timeLengthPeriod

  return(aucValue)
}
