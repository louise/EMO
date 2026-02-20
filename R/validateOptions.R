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


# process arguments supplied to GLU by the user
validateOptions <- function(indir, outdir = NULL, imputeX = imputeX, lowthreshold = NULL, highthreshold = NULL, save = FALSE, saveevents = FALSE) {

  if (is.null(indir)) {
    stop("Input data directory argument must be supplied", call. = FALSE)
  } else if (!file.exists(indir)) {
    stop(paste("Input data directory indirectory=", indir, " does not exist", sep = ""), call. = FALSE)
  }

  if (is.null(outdir)) {
    outdir <- indir
  }

  # create output directory if it doesn't exist
  if (!file.exists(outdir)) {
    print(paste0("Creating output directory: ", outdir))
    dir.create(outdir)
  }

  if (saveevents == TRUE) {
    eventsDir <- file.path(outdir, "/events/")
    dir.create(eventsDir)
  }

  # both thresholds need to be set or neither
  if ((is.null(lowthreshold) & !is.null(highthreshold)) | (is.null(highthreshold) & !is.null(lowthreshold))) {
    stop("Both hypo and hyper thresholds need to be set (or neither)", call. = FALSE)
  } else if (is.null(lowthreshold) & is.null(highthreshold)) {
    # set to min and max values to ignore this
    lowthreshold <- 0
    highthreshold <- 1
  }

  runSettings <- methods::new("runSettings", indir = indir, outdir = outdir, imputeX = imputeX, lowthreshold = lowthreshold, highthreshold = highthreshold, save = save, saveevents = saveevents)
  return(runSettings)
}
