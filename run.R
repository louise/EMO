

# load the EMO package
library('EMO')

options(warn=2)


# parse arguments - directory is required, if filename is not specified then all files in directory are processed
opt = parseArgs()


# run EMO using command line arguments
runEMO(opt)


