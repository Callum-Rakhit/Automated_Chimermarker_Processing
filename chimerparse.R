# No shebang line needed for Windows, just associate .R extension with a programme

# Suppress warnings for clean cmd line output
options(warn = -1)

# Get args from the command line
args = commandArgs(trailingOnly = T)

# Load necessary libraries (need to install these manually in Windows)
invisible(lapply(c("readxl", "stringr"), require, character.only = T))

# Warn user is they haven't specified the inout and output locations
if (length(args) < 2) {
  stop(paste("Need to supply an input file and an output location, i.e. ",
             "Rscript chimerParser.R input_file.xls ./some/location/output.csv",
             sep = ""),
       call.=F)
}

# Read in and rename the data
# suppressMessages(data <- read_xlsx(args[1], col_names = F)) # Don't want any output on the cmd line

args <- c("~/Downloads/20191230-Chimerism/", "~/Downloads/20191230-Chimerism/example.csv")

# Needs to have the word "worksheet" in it
suppressMessages(chimerism.masterworksheet <- Sys.glob(paths = paste(args[1], "*worksheet*", sep = "")))
suppressMessages(chimerism.masterworksheet <- read_xlsx(path = chimerism.masterworksheet, col_names = T))
colnames(chimerism.masterworksheet) <- c("Extraction_Type", "Extraction_Number", "HMDC_Referral_No", 
                                         "Lab_Box_Number", "Well_Position", "Well_Row", "c_surname")

# Needs to have a dash "-" in it 
chimerism.patients <- Sys.glob(paths = paste(args[1], "*-*", sep = ""))
suppressMessages(chimerism.patients <- lapply(chimerism.patients, function(i){read_xlsx(path = i, col_names = F)}))
chimerism.patients <- do.call(rbind, chimerism.patients)
colnames(chimerism.patients) <- c("Column_A", "Column_B", "Column_C", "Column_D", "Column_E", "Column_F") # Give each column an arbitrary name

output_data <- data.frame(matrix(
  vector(), 0, 3, dimnames = list(c(), c(
    "Extraction_Number", "Average_Chimerism", "Informative_Loci"))),
  stringsAsFactors=F)

invisible(
  lapply(chimerism.masterworksheet$Extraction_Number, function(x){
    if (length(which(grepl(x, chimerism.patients$Column_A))) != 0) { 
      temp_extractionIDrow <- which(grepl(x, chimerism.patients$Column_A))
      temp_chimerism <- chimerism.patients[2][temp_extractionIDrow + 22,]
      temp_loci <- chimerism.patients[2][temp_extractionIDrow + 26,]
      temp_output_string <- c(x, temp_chimerism, temp_loci)
      output_data[nrow(output_data) + 1,] <<- temp_output_string
      }
    })
)

chimerism.masterworksheet <- merge(x = chimerism.masterworksheet, y = output_data, by = "Extraction_Number")
colnames(chimerism.masterworksheet) <- c("Extraction::Extraction Number", "Extraction::Extraction Type", "Extraction::HMDC Referral No", 
                                         "Extraction::Lab Box Number", "Extraction::Well Position", "Extraction::Well Row", 
                                         "Extraction::c surname", "Extraction::Average Chimerism", "Extraction::Informative Loci")

write.csv(x = chimerism.masterworksheet, file = args[2])
