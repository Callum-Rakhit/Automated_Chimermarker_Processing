# No shebang line needed for Windows, just associate .R extension with a programme

# Get the required packages if not installed
GetPackages <- function(required.packages) {
  packages.not.installed <- 
    required.packages[!(required.packages %in% installed.packages()[, "Package"])]
  if(length(packages.not.installed)){
    install.packages(packages.not.installed, repos="http://cran.ma.imperial.ac.uk")}
  lapply(required.packages, require, character.only = T)
}

# Load packages
GetPackages(c("readxl", "stringr"))

# Get the file locations and output file name
args <- c("M:/CHIMERMARKER/Automated_Chimermarker_Processing/Place_your_files_in_here/", "M:/CHIMERMARKER/Automated_Chimermarker_Processing/Here_is_your_output.csv")

# Needs to have the word "worksheet" in it
chimerism.masterworksheet <- Sys.glob(paths = paste(args[1], "*CHIM*", sep = ""))
chimerism.masterworksheet <- read_xlsx(path = chimerism.masterworksheet, col_names = T)
colnames(chimerism.masterworksheet) <- c("Extraction_Type", "Extraction_Number", "HMDC_Referral_No", "Lab_Box_Number", "Well_Position", "Well_Row", "c_surname")

# Needs to have a dash "-" in it 
chimerism.patients <- Sys.glob(paths = paste(args[1], "*-*", sep = ""))
chimerism.patients <- lapply(chimerism.patients, function(i){read_xlsx(path = i, col_names = F)})
chimerism.patients <- do.call(rbind, chimerism.patients)

# Give each column an arbitrary name
colnames(chimerism.patients) <- c("Column_A", "Column_B", "Column_C", "Column_D", "Column_E", "Column_F") 

# Make a dataframe to paste the output into
output_data <- data.frame(matrix(vector(), 0, 7, dimnames = list(c(), c("Extraction_Number", "Average_Chimerism", "Informative_Loci", "Standard_Deviation", "Coefficient_of_Variation", "Warning_SD", "Warning_Co"))), stringsAsFactors = F)

options(scipen=999)

# List apply all extraction ids from the workbook to search through the patients
lapply(chimerism.masterworksheet$Extraction_Number, function(x){
if(length(which(grepl(x, chimerism.patients$Column_A))) != 0) {
temp_extractionIDrow <- unlist(which(grepl(x, chimerism.patients$Column_A)))
temp_chimerism <- unlist(chimerism.patients[2][temp_extractionIDrow + 22,])[1]
temp_chimerism <- as.numeric(temp_chimerism)*100
temp_co <- unlist(chimerism.patients[2][temp_extractionIDrow + 23,])[1]
temp_sd <- unlist(chimerism.patients[2][temp_extractionIDrow + 24,])[1]
temp_chimerism <- unlist(temp_chimerism)[1]
temp_loci <- unlist(chimerism.patients[2][temp_extractionIDrow + 26,])[1]
temp_warn_sd <- ifelse(temp_sd > 5, "WARNING SD over 5!", "")
temp_warn_sd <- unlist(temp_warn_sd)[1]
temp_warn_co <- ifelse(temp_sd > 10, "WARNING Coefficient of Variance over 10!", "")
temp_warn_co <- unlist(temp_warn_co)[1]
temp_output_string <- c(x, temp_chimerism, temp_loci, temp_sd, temp_co, temp_warn_sd, temp_warn_co)
output_data[nrow(output_data) + 1,] <<- temp_output_string
}})

# Merge the dataframes
chimerism.masterworksheet <- merge(x = chimerism.masterworksheet, y = output_data, by = "Extraction_Number")
colnames(chimerism.masterworksheet) <- c("Extraction::Extraction Number", "Extraction::Extraction Type", "Extraction::HMDC Referral No", "Extraction::Lab Box Number", "Extraction::Well Position", "Extraction::Well Row", "Extraction::c surname", "Extraction::Average Chimerism", "Extraction::Informative Loci", "Extraction::Standard Deviation", "Extraction::Coefficient of Variation", "Extraction::Warning SD", "Extraction::Warning CoV")

# write the csv file
write.csv(x = chimerism.masterworksheet, file = args[2], row.names = F)