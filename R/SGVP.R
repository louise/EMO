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


# Calculate standardised glycemic variability percentage (sGVP) of SG readings in raw.
# Returns the sGVP value.
SGVP <- function(data, stdx) {
  
  if (stdx == TRUE) {
    # standardise sequence (x - median)/MAD
    # MAD function rescales so MAD=SD if normally distributed
    madVal <- mad(data, constant = 1, na.rm = TRUE)

    medianVal <- median(data)
    data <- (data - medianVal) / madVal
  }


  # for consecutive pair of measurements calculate the GVP for this part
  sgvp <- 0
  overallTimeDiffSecs <- 0

  for (idx in 2:length(data)) {
    # don't include variation between non-imputed and imputed regions, and left and right parts of imputed regions
    #if (data$impute[idx] == data$impute[idx - 1]) {
      timeDiffSecs <- 0.02 #as.numeric(difftime(data$time[idx], data$time[idx - 1], units = "mins"))

      #if (timeDiffMins == 1) {
        sgvpThis <- sqrt((data[idx - 1] - data[idx])^2 + timeDiffSecs^2)
        sgvp <- sgvp + sgvpThis

        overallTimeDiffSecs <- overallTimeDiffSecs + timeDiffSecs
      #}
    #}
  }
  sgvp <- sgvp / overallTimeDiffSecs

  # rescaling so it's a % of the minimum length of the line
  sgvp <- (sgvp - 1) * 100

  return(sgvp)
}
