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


#' Process arguments supplied to GLU by the user.
#' @return List of options specified by the user.
#' @export
parseArgs <- function() {
  option_list <- list(
    optparse::make_option(c("-f", "--filename"), type = "character", default = NULL, help = "Optional filename to process specific file", metavar = "character"),
    optparse::make_option(c("-i", "--indir"), type = "character", default = NULL, help = "Directory where CGM raw data files are stored", metavar = "character"),
    optparse::make_option(c("-o", "--outdir"), type = "character", default = NULL, help = "Directory where derived data should be stored", metavar = "character"),
    optparse::make_option(c("-l", "--lowthreshold"), type = "character", default = NULL, help = "Threshold between low and mid levels", metavar = "number"),
    optparse::make_option(c("-u", "--highthreshold"), type = "character", default = NULL, help = "Threshold between mid and high levels", metavar = "number"),
    optparse::make_option(c("-a", "--impute_x"), action = "store_true", default = FALSE, help = "Perform XTODOX imputation [default= %default]"),
    optparse::make_option(c("-s", "--save"), action = "store_true", default = FALSE, help = "Save derived time-series [default= %default]"),
    optparse::make_option(c("-x", "--saveevents"), action = "store_true", default = FALSE, help = "Save derived variables for each event [default= %default]")
  )

  opt_parser <- optparse::OptionParser(option_list = option_list)
  opt <- optparse::parse_args(opt_parser)

  if (is.null(opt$indir)) {
    optparse::print_help(opt_parser)
  }

  return(opt)
}
