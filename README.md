# EMO: A tool for analysing emotion time-series data

This is a fork and adaption of GLU, which is described in the paper:
L.A.C. Millard et al. GLU: A tool for analysing continuously measured glucose in epidemiology, International Journal of Epidemiology, Volume 49, Issue 3, 2020, Pages 744–757.


## 1. Overview

EMO takes emotion data derived from videos as input, and derives a set of characteristics describing these data:

1. Median absolute deviation (MAD)
2. Area under the curve (AUC)
3. TBCProportion of time spent in low, normal and high values
4. TBCStandardised glycaemic variability percentage (sGVP)
5. TBCEvent statistics:
    1. Time to peak
    2. 1-hour event AUC
    3. 2-hour event AUC


## 2. License

This project is licensed under The MIT License.

## 3. Installing EMO

The package can be installed within R directly from GitHub. 
To do this you will need `devtools`:

```
install.packages('devtools')
```

After installing `devtools` you will be able to install GLU:

```
library(devtools)
install_github("louise/EMO")
```

To update EMO to the latest version, rerun the `install_github` command.


## 4. Running EMO within R

There are two main functions in EMO: `runEMOForFiles` and `runEMOForDirectory`, that process either a specific set of files, or all files in a particular directory.
Both these functions take an `indir` compulsory argument that specifies the directory containing the CGM data files.
The `runEMOForFiles` has an additional `files` compulsory argument, for providing the names of files that should be processed.
The compulsory and optional arguments are as follows.

#### Compulsory arguments

Arg | Description
-------|--------
indir   | Directory where processed CGM data files (i.e. output from step 1) are stored.
files   |  List of file names to be processed by GLU, where these files reside in the indir directory (required only for the `runGLUForFiles` function).


#### Optional arguments

Arg | Description
-------|--------
outdir  | Directory where derived CGM characteristics data files should be stored. Default is `indir`.
save    |       Set to `TRUE` to save derived (resampled) CGM data.
saveevents	| Save summary variables of each individual event, rather than just the averages for each day and across days.
TBCimputeX  |       TODO
TBClowthreshold   | Threshold between low and mid levels
TBChighthreshold  | Threshold between mid and high levels


For example, to run EMO for all files in a directory we can you a command like this one:

```
library('EMO')
runEMOForDirectory(indir='/path/to/in/dir/', outdir='/path/to/out/dir')
```

If you would like to run EMO for all files in a directory then use the `runEMOForDirectory`. The arguments are the same as above but without the `files` arguments.



## 5. Data format

If using GLU with CGM data from other devices, you can convert your data to a CSV (comma seperated values) file with the following columns, and then specify the device as 'other' using the `device` argument.

Required columns:

Column | Description
-------|--------
Video Time | A data/time column in any format (this is overridden with 0.02 second gaps as the data from the device is not precise enough)
Emotion columns     | One or more emotion columns with any column header. All columns except Video Time are assumed to be emotions. 


Optional columns:

Column | Description
-------|--------
event         | Optional column, which if not blank indicates an event timestamp TODO



## 6. Description of EMO QC

1. Dealing with Video Time column

Data in this column are replaced with values indicating the number of seconds from the start of the recording, assuming a gap of 0.02 seconds between rows.


2. Dealing with missing data

If imputeX=False:
We strip out the missing data at the start and at the end. All missing values after the first non missing timepoint and before the last non missing timepoint are imputed using linear interpolation.


## 7. Description of EMO derived variables


1. Median absolute deviation (MAD)

The median of the absolute difference of each value from the median value.


2. AUC, per minute for each valid day, and mean across all valid days
 - The AUC of the emotion values
 - Trapezoid method (linear interpolation between the discrete measurements) as described [here](https://www.boomer.org/c/php/pk0204a.php).


3. TBC Proportion of time spent in low, normal and high SG ranges, per valid day and mean across all valid days

To calculate these proportions we linearly interpolate between adjacent values to calculate the proportion of time within each range.

The following pseudocode (for pregnancy thresholds) demonstrates the process we use.


4. Standardised glycaemic variability percentage (sGVP), per included day and mean across all included days


Intuitively, sGVP is based on the length of the line of the time-series. 
GVP is the length of the line relative to the length of a completely flat time-series. 
A trace with no variability has GVP=0, and the more variability (both in amplitude and undulations) from a flat trace, the higher the GVP value.
The sGVP measure is the GVP calculated using a standardised time-series, to reflect the degree a trace undulates.
Standardisation is performed as:

``` 
(SG - median(SG))/MAD
```


6. TBC Event time to peak

The number of seconds from the event to the next emotion peak.

In the simple case the peak is the nearest subsequent time t, after the event where emotion(t-1) < emotion(t) > emotion(t+1).

In the case where the peak is on a plateau, then (i.e. there are multiple timepoints on the peak with the same peak value) 
then we define the peak time point as the nearest time point to the event on this plateau.


7. TBC Post-event AUC

An event is either TBC, TBC or TBC.

Post-event AUC can be either 1-hour or 2-hour. 

The `n`-hr post-event AUC is the mean of the emotion values during the 15 minute period occuring `n` hrs after the event.




## 8. Running EMO on the command line

EMO can also be directly from the command line, using the run.R script.

For example:
```bash
Rscript run.R --indir="/path/to/in/dir/" --outdir="/path/to/out/dir/"
```

To process a specific data file, specify the filename argument:
```bash
Rscript run.R --indir="/path/to/in/dir/"  --outdir="/path/to/out/dir/" --filename="infile.csv"
```

See all the arguments available by calling `run.R` with no arguments:

```bash
Rscript run.R
```
