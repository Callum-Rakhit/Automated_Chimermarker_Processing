# TODO(Callum)
#   - Print the whole LMH/Sample type/date as string

# Suppress warnings for clean cmd line output
options(warn = -1)

# Get args from the command line
args = commandArgs(trailingOnly = T)

# Function to strip away empty cases
CompleteFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

# Function to check if packages are installed, if not, get them
GetPackages <- function(required.packages) {
  packages.not.installed <- 
    required.packages[!(required.packages %in% installed.packages()[, "Package"])]
  if(length(packages.not.installed)){
    install.packages(packages.not.installed)}
  suppressMessages(lapply(required.packages, require, character.only = TRUE))
}

# Install/load required packages (invisibly)
invisible(GetPackages(c("readxl", "stringr")))

# Warn user is they haven't specified the inout and output locations
if (length(args) < 2) {
  stop(paste("Need to supply an input file and an output location, i.e. ",
             "Rscript chimerParser.R input_file.xls ./some/location/output.csv",
             sep = ""),
       call.=FALSE)
}

# Read in and rename the data
suppressMessages(data <- read_xlsx(args[1], col_names = F)) # Don't want any output on the cmd line
names(data) = c("A", "B", "C", "D", "E", "F") # Give each column an arbitrary name

# Create a dataset with no NAs in the first column
data_no_NAs <- CompleteFun(data, 1)

# Find the strings in the file
bm_pattern <- "[:digit:][:digit:][:digit:][:digit:][:digit:][:digit:]-[A-Z][A-Z]_.............."
cd3_pattern <- "[:digit:][:digit:][:digit:][:digit:][:digit:][:digit:]-[A-Z][A-Z][:digit:]_.............."
cd15_pattern <- "[:digit:][:digit:][:digit:][:digit:][:digit:][:digit:]-[A-Z][A-Z][:digit:][:digit:]_.............."

# Pattern for BM (bone marrow)
bm_string <- str_extract_all(data, bm_pattern, simplify = T)
bm_string <- bm_string[1,]

# Pattern for CD3
cd3_string <- str_extract_all(data, cd3_pattern, simplify = T)
cd3_string <- cd3_string[1,]

# Pattern for CD15
cd15_string <- str_extract_all(data, cd15_pattern, simplify = T)
cd15_string <- cd15_string[1,]

# Creates an output df to append with LMH, sample type, date, chimerism (%) & loci
output_data <- data.frame(matrix(
  vector(), 0, 5, dimnames = list(c(), c(
    "LMH_Number", "Date", "Sample_Type", "Average_Chimerism", "Informative_Loci"))),
  stringsAsFactors=F)

# Function to parse the file
bigParser <- function(string_type) {
  for (i in 1:length(string_type)){
    # Extract the LMH/type/date name
    temp_var <- string_type[i]
    
    # Split it up and extract LMH/type/gate
    temp_var_split <- str_split(temp_var, "-", simplify = T)
    temp_var_split <- temp_var_split[1,]
    temp_var_LMH <- temp_var_split[1]
    temp_var_type <- str_split(temp_var_split[2], "_", simplify = T)[1]
    temp_var_date <- paste(str_split(temp_var_split[2], "_", simplify = T)[3],
                           temp_var_split[3], temp_var_split[4], sep = "_")
    
    # Split the no NA df using the LMH/type/date name
    data_no_NAs$tab_id <- cumsum(grepl(temp_var, data_no_NAs$A))
    df_split <- split(data_no_NAs[, -ncol(data_no_NAs)], data_no_NAs$tab_id)
    df_split <- as.data.frame(df_split[2])
    
    # From the split df, get chimerism percent and loci number
    temp_chimerism <- df_split[2][20,]
    temp_loci <- df_split[2][24,]
    temp_output_string <- c(temp_var_LMH, temp_var_date, temp_var_type,
                            temp_chimerism, temp_loci)
    output_data[nrow(output_data) + 1,] <<- temp_output_string
  }
}

# Run parser function across all patterns
main <- function() {
  bigParser(bm_string)
  bigParser(cd15_string)
  bigParser(cd3_string)
  write.csv(x = output_data, file = args[2])
}

# If interactive R script, run main() function
if (!interactive()) {
  main()
}
