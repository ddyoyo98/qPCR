# install.packages("readxl")
library(readxl)
# readxl package used for reading in xls version of data

# Read in and organize metadata 
# setup_info <- read.delim("setup_info.txt", header = TRUE, sep = ",")
# sample_info <- read.delim("sample_info.txt", header = TRUE, sep = ",")
setup_info <- read.delim("setup_info.txt", header = TRUE, sep = ",")
sample_info <- read.delim("sample_info.txt", header = TRUE, sep = ",")
rownames(sample_info) <- sample_info$Sample

housekeeping <- setup_info[3,2]
controls <- setup_info[4,2]

# Setup names for files and directories 
filename <- setup_info[1,2]
filetype <- setup_info[2,2]
file <- paste(filename, filetype, sep = ".")

cwd <- getwd()
dirname <- paste(unlist(strsplit(filename, split = " ")), collapse = "_")
dir.create(file.path(cwd, dirname))

# Read in raw data from txt or xls file
# 10/27/2021 EDIT: Apparently the machine also outputs .xlsx files; add "OR" statement later...
if (filetype == "txt") {
  data <- readLines(file)
  start <- grep("Results", data) + 1
  end <- length(data) - 6
  data <- data[start:end]
  write(data, file = "temp.txt")
  data <- read.delim("temp.txt", header = )
  file.remove("temp.txt")
} else if (filetype == "xls") {
  data <- read_excel(file, sheet = "Results")
  data <- data[which(!is.na(data$...3)),]
  colnames(data) <- data[1,]
  data <- data[2:nrow(data),]
  data <- as.data.frame(data)
} else {
  print("Filetype must be .txt or .xls")
  stop()
}

# Organize raw data and keep only relevant parts, ie. Sample names, Target names, and CT values
# grep used for sample and target names because .txt and .xls files have a space and period, respectively, between [x] and name
# grep generalizes and says, whatever column name has the word "Sample" and "Target" in it, keep those
sample_names <- colnames(data)[grep("Sample", colnames(data))]
target_names <- colnames(data)[grep("Target", colnames(data))]
keep <- c(sample_names, target_names, "CT")
data <- data[,keep]

# Create vectors for non-control samples, non-housekeeping genes, and all genes
samples <- levels(factor(data[,1]))
samples <- samples[which(!samples %in% controls)]

targets <- levels(factor(data[,2]))
targets <- targets[which(targets != housekeeping)]

genes <- append(housekeeping, targets)

# Summarize the data on one csv file
# Initial summary will organize raw data into columns with duplicates next to each other, their average, and the difference between the duplicates
# Difference is to see if there was bad quality duplicates (difference magnitude over 1 isn't great)
summ <- data.frame(samples)
rownames(summ) <- samples

for (x in 1:length(genes)) {
  temp_df <- data.frame(matrix(, nrow = length(samples), ncol = 5))
  colnames(temp_df) <- c("Target Name", "CT_1", "CT_2", "Average", "difference")
  rownames(temp_df) <- samples
  gene <- genes[x]
  
  for (y in 1:length(samples)) {
    sample <- samples[y]
    val1 <- data[data[,sample_names] == sample & data[,target_names] == gene,][1,"CT"]
    val2 <- data[data[,sample_names] == sample & data[,target_names] == gene,][2,"CT"]
    temp_df[sample, "Target Name"] <- gene
    temp_df[sample, "CT_1"] <- val1
    temp_df[sample, "CT_2"] <- val2
    temp_df[sample, "Average"] <- mean(c(as.numeric(val1), as.numeric(val2)))
    temp_df[sample, "difference"] <- as.numeric(val1) - as.numeric(val2)
  }
  summ <- cbind(summ, temp_df)
}

# Save initial summary as a csv in dedicated folder
summ <- subset(summ, select = -samples)
rownames(summ) <- paste("sample", rownames(summ), sep = " ")
file <- "initial_summary.csv"
path <- paste(dirname, file, sep = "/")
write.csv(summ, file = path)

# Prepare for initial analysis that also gives delCT with gene of interest (goi) and housekeeping gene
hk_data <- data[which(data[,2] == housekeeping),]


treatments <- levels(factor(sample_info$Designation))
treatments <- treatments[treatments != setup_info[5,2]]

# Initial analysis to show delCT values without using sample_info
initial_analysis <- data.frame(matrix(, nrow = length(samples), ncol = 1))
colnames(initial_analysis) <- paste(housekeeping, "CT_avg")
rownames(initial_analysis) <- samples

# Average the housekeeping gene CT values
for (i in 1:length(samples)) {
  temp <- hk_data[which(hk_data[,1] == samples[i]),]
  hk_avg <- mean(as.numeric(temp$CT))
  initial_analysis[samples[i], 1] <- hk_avg
}

# Average the goi CT values and then subtract sample's corresponding hk_avg from it to get delCT
for (goi in 1:length(targets)) {
  goi_data <- data[which(data[,2] == targets[goi]),]
  temp_analysis <- data.frame(matrix(, nrow = length(samples), ncol = 2))
  colnames(temp_analysis) <- c(paste(targets[goi], "CT_avg"), "delCT")
  rownames(temp_analysis) <- samples
  
  for (i in 1:length(samples)) {
    temp <- goi_data[which(goi_data[,1] == samples[i]),]
    goi_avg <- mean(as.numeric(temp$CT))
    
    temp_analysis[samples[i], paste(targets[goi], "CT_avg")] <- goi_avg
    temp_analysis[samples[i], "delCT"] <- goi_avg - initial_analysis[samples[i], 1]
  }
  
  initial_analysis <- cbind(initial_analysis, temp_analysis)
}

# Save initial analysis as a csv in dedicated folder
save_initial_analysis <- initial_analysis

# Add "sample" in front of sample names because if it's just a number (ex. 1-2-3), Excel/Google Sheets tries to coerce into a date
rownames(save_initial_analysis) <- paste("sample", rownames(initial_analysis), sep = " ")

save_as <- paste(dirname, "/initial_analysis.csv", sep = "")
write.csv(save_initial_analysis, file = save_as)


# If setup_info is filled out, will do analysis all the way to fold gene expression
if (setup_info[6,2] == "Y") {
  # Get data frame of just sample names and designations/treatments
  control_designation <- setup_info[5,2]
  control_samples <- rownames(sample_info)[which(sample_info$Designation == control_designation)]
  control_subdata <- initial_analysis[control_samples,]
  sample_treatments <- subset(sample_info, select = 2)
  
  # Analyze for each treatment and gene subset
  for (treatment in 1:length(treatments)) {
    # treatment_subdata has hk_avg, all goi_avg, and all delCT values for 
    treatment_samples <- rownames(sample_info[which(sample_info$Designation == treatments[treatment]),])
    treatment_subdata <- initial_analysis[which(rownames(initial_analysis) %in% treatment_samples),]
    
    all_genes_analysis <- rbind(control_subdata, treatment_subdata)
    summ_analysis <- subset(all_genes_analysis, select = 1)
    summ_analysis <- merge(sample_treatments, summ_analysis, by = 0)
    rownames(summ_analysis) <- summ_analysis[,grep("Row", colnames(summ_analysis))]
    summ_analysis <- subset(summ_analysis, select = 2:3)
    
    for (goi in 1:length(targets)) {
      gene_data_index <- grep(targets[goi], colnames(all_genes_analysis))
      gene_data_index <- c(gene_data_index, gene_data_index+1)
      goi_data <- subset(all_genes_analysis, select = gene_data_index)
      
      goi_control_subdata <- subset(control_subdata, select = gene_data_index)
      delCT_control <- mean(goi_control_subdata[, "delCT"])
      
      deldelCT <- goi_data[,"delCT"] - delCT_control
      goi_data <- cbind(goi_data, deldelCT)
      
      FGE <- 2^(-1*goi_data[,"deldelCT"])
      goi_data <- cbind(goi_data, FGE)
      
      summ_analysis <- merge(summ_analysis, goi_data, by = 0)
      rownames(summ_analysis) <- summ_analysis[,grep("Row", colnames(summ_analysis))]
      summ_analysis <- summ_analysis[,-grep("Row", colnames(summ_analysis))]
    }
    rownames(summ_analysis) <- paste("sample", rownames(summ_analysis), sep = " ")
    filename <- paste(treatments[treatment], "analysis.csv", sep = "_")
    write.csv(summ_analysis, file = paste(dirname, filename, sep = "/"))
  } 
}