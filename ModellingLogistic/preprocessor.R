
#####*****Preprocessing script*****######
#####* This is where we process the data, say imputing NA's with mean plus any other transformation that can be done. 
#####* This function will be sourced in the training script before fitting the model. 

library(data.table) # Opted for this, 1. Because its really fast 2. dplyr conflicted with plumber
library(rjson) # for handling json data

preprocessing <- function(){ 
  
  # use pattern to read data : this is to make the model generic 
  fname_train <- dir(path = "./ml_vol/inputs/data/training/binaryClassificationBaseMainInput/", pattern = "\\_train.csv$")
  fname_schema <- dir(path = "./ml_vol/inputs/data_config/", pattern = "\\_schema.json$")
  
  # import the training data 
  genericdata <- fread(paste0("./ml_vol/inputs/data/training/binaryClassificationBaseMainInput/",fname_train))
  names(genericdata) <- gsub("%","x",names(genericdata))
  # read in the schema so that we extract the response variable
  dataschema <- fromJSON(file = paste0("./ml_vol/inputs/data_config/",fname_schema))
  
  # get the response variable and store it as a string to a variable
  varr <- dataschema$inputDatasets$binaryClassificationBaseMainInput$targetField
  # introducing na value to check if the pipeline is working fine. 
  genericdata <- genericdata[id==529,word_freq_make:="NA"] 

# drop the id field 
## get the field name and store it as a variable
idfieldname <- dataschema$inputDatasets$binaryClassificationBaseMainInput$idField

## drop it from the data
genericdata <- subset(genericdata,select = -c(eval(as.name(paste0(idfieldname)))))

# get the predictor fields from the dataschemaa. 
predictor_fields <- data.frame(dataschema$inputDatasets$binaryClassificationBaseMainInput$predictorFields)

# convert the dataframe to data.table for munging :- don't want to use dplyr
predictor_fields <- setDT(predictor_fields)

# melt the data.table into long format so as to filter numeric columns. 
predictor_fields <- melt(predictor_fields,measure.vars=patterns(fieldNames="fieldName",dataTypes="dataType"))
predictor_fields$fieldNames <- gsub("%", "x", predictor_fields$fieldNames)
# filter the numeric columns 
num_vars <- predictor_fields[dataTypes=="NUMERIC",.(fieldNames)]
#num_vars$fieldNames <- gsub("%", "x", num_vars$fieldNames)

# categorical variables
cat_vars <- predictor_fields[dataTypes=="CATEGORICAL",.(fieldNames)]

v <- num_vars$fieldNames
# loop through the numeric columns and replace na values with mean of the same column in which the na appears.
for (coll in v){

 genericdata <-  genericdata[, (coll) := lapply(coll, function(x) {
    x <- get(x)
    x[is.na(x)] <- mean(x, na.rm = TRUE)
    x
  })]

}

# ## replace missing values in categorical fields with mode 
#   # List the distinct / unique values
#   distinct_values <- unique(cat_vars)
#   # Count the occurrence of each distinct value
#   distinct_tabulate <- tabulate(match(cat_vars, distinct_values))
#   for (cat_coll in cat_vars){
#   genericdata <-  genericdata[, (cat_coll) := lapply(cat_coll, function(x) {
#     x <- get(x)
#     # Replace missing value with the value with the highest occurrence (mode)
#     x[is.na(x)] <- distinct_values[which.max(distinct_tabulate)]
#     
#   })]
# }

return(list(genericdata,varr,predictor_fields))
}

#head(preprocessing(genericdata = genericdata, dataschema = dataschema)[[1]])
