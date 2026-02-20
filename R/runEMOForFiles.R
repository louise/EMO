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


#' Run EMO for given set of files
#'
#' @param files emotion data files for which variables will be derived.
#' @param indir Path of input directory containing input files.
#' @param outdir Path of output directory where derived data will be stored.
#' @param imputeX Logical. If TRUE then the XXXX approach to dealing with missing data is used.
#' @param lowthreshold Numeric.
#' @param highthreshold Numeric.
#' @param save Logical. If TRUE then derived emotion sequence(s) are stored.
#' @export
runEMOForFiles <- function(files, indir, outdir = NULL, imputeX = FALSE, lowthreshold = NULL, highthreshold = NULL, save = FALSE, saveevents = FALSE) {
  print("ddRunning EMO...")
  print(paste0("EMO package version: ", packageVersion("EMO")))


  # run settings
  rs <- validateOptions(indir, outdir, imputeX = imputeX, lowthreshold = lowthreshold, highthreshold = highthreshold, save = save, saveevents = saveevents)

  # Save run settings for reporting in publications
  saveRunSettings(rs)

  namePrefix <- derivedFilePrefix(rs)


  # refresh impute logging file
  #if (rs@imputeX == TRUE) {
    sink(paste0(outdir, "/logging-impute.txt"))
    sink()
  #}


  first <- TRUE

  # process emotion file (data for one participant)
  # and add row with derived variables to summaryVariables data frame
  for (f in files) {
    print("---------")
    print(paste("File name:", f))

    # get userID
    userID <<- getUserIDFromFileName(f)
    userIDdf <- c(userID)
    userIDdf <- rbind(userIDdf)
    colnames(userIDdf) <- c("ID")

    print(paste("ID:", userIDdf))

  #   #####
  #   ##### load data

    raw <- loadData(f, userID, rs)

    # impute missing periods - assume all emotions have same missingness
    if (any(is.na(raw$emotions[,"Neutral"]))) {
      if (rs@imputeX == FALSE) {
        print("imputing missing timepoints ...")

        sink(paste0(outdir, "/logging-impute.txt"), append = TRUE)
        print(paste0("*********** IMPUTING ", userID, " ***********"))
          
        raw$emotions[which(is.na(raw$emotions[,"Neutral"])),"imputed"] <- T

        # linear interpolation
        emoCols = raw$emotionColumns
        raw$emotions[,emoCols] <- lapply(raw$emotions[,emoCols], function(X) approxfun(seq_along(X), X, rule=1)(seq_along(X)))
            
        sink()

      } else {
          stop('other imputation method not implemented yet')
      }
    }

    # remove start and end missingness that could not be imputed - assume all emotions have same missingness
    if (any(is.na(raw$emotions[,"Neutral"]))) {
      naRow <- which(is.na(raw$emotions[,"Neutral"]))
      raw$emotions <- raw$emotions[-naRow, ]
    }

    #  save validDays to a CSV files
    saveCleanData(raw, userID, rs)

  #   ######
  #   ###### PLOTTING

  #   plotCGM(validDays, outdir, userID, rs)


  #   ######
  #   ###### GENERATE VARIABLES

     print(paste("Generating variables for file:", f, ", with user ID:", userID))
     summThis <- deriveCharacteristics(raw, userIDdf, rs)


  #   # add correlation and invalid deviations
  #   summThis <- cbind.data.frame(summThis, deviationsInvalid)

    # add to summaryVar data frame, or create if first person
    if (first == TRUE) {
      summaryVariables <- summThis
      first <- FALSE
    } else {
      # we use merge rather than rbind because users have different columns depending on how many valid days they have
      summaryVariables <- merge(summaryVariables, summThis, all = TRUE)
    }

  #   print("---------")
  }


  # if there are no files then we have no derived characteristics to save
   if (exists("summaryVariables") == TRUE) {
     print("Saving results to file ...")

     write.table(summaryVariables, file = paste(outdir, "/", "summaries-", namePrefix, ".csv", sep = ""), sep = ",", quote = FALSE, row.names = FALSE)
  
   } else {
     print("No results were generated")
   }

  # warnings
  wx <- warnings()
  if (!is.null(wx)) {
    print("Warnings:")
    print(wx)
  }

  print("EMO has finished.")
}
