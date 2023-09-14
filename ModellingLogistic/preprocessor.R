
#####*****Preprocessing script*****######
#####* This is where we process the data, say imputing NA's with mean plus any other transformation that can be done. 
#####* This function will be sourced in the training script before fitting the model. 

library(data.table) # Opted for this, 1. Because its really fast 2. dplyr conflicted with plumber
library(rjson) # for handling json data
library(fastDummies)
library(dplyr)

preprocessing <- function(fname_train,fname_schema,genericdata,dataschema){ 
  

  #names(genericdata) <- gsub("%","x",names(genericdata))

  # get the response variable and store it as a string to a variable
  #varr <- dataschema$inputDatasets$binaryClassificationBaseMainInput$targetField
  varr <- dataschema$target$name
  # introducing na value to check if the pipeline is working fine. 
  #genericdata <- genericdata[id==529,word_freq_make:="NA"] 

# drop the id field 
## get the field name and store it as a variable
#idfieldname <- dataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- dataschema$id$name


## drop it from the data
#genericdata <- subset(genericdata,select = -c(eval(as.name(paste0(idfieldname)))))

# get the predictor fields from the dataschemaa. 
#predictor_fields <- data.frame(dataschema$inputDatasets$binaryClassificationBaseMainInput$predictorFields)
predictor_fields <- data.frame(dataschema$features)
# convert the dataframe to data.table for munging :- don't want to use dplyr
predictor_fields <- setDT(predictor_fields)

# melt the data.table into long format so as to filter numeric columns. 
#predictor_fields <- melt(predictor_fields,measure.vars=patterns(fieldNames="fieldName",dataTypes="dataType"))
predictor_fields <- melt(predictor_fields,measure.vars=patterns(fieldNames="name",dataTypes="dataType"))
#predictor_fields$fieldNames <- gsub("%", "x", predictor_fields$fieldNames)
# filter the numeric columns 
num_vars <- predictor_fields[dataTypes %like% "NUMERIC",.(fieldNames)]
#num_vars$fieldNames <- gsub("%", "x", num_vars$fieldNames)

# categorical variables
cat_vars <- predictor_fields[dataTypes %like% "CATEGORICAL",.(fieldNames)]
features <- dataschema$features

numeric_features <- features$name[features$dataType == "NUMERIC"]
categorical_features <- features$name[features$dataType == "CATEGORICAL"]

catcols <- as.vector(cat_vars$fieldNames)

v <- as.vector(num_vars$fieldNames)
MODEL_ARTIFACTS_PATH <- "./../model_inputs_outputs/model/artifacts/"
OHE_ENCODER_FILE <- file.path(MODEL_ARTIFACTS_PATH, 'ohe.rds')

genericdata <- as.data.frame(genericdata)

# One Hot Encoding
if(length(categorical_features) > 0){
  top_3_map <- list()
  for(col in categorical_features) {
    # Get the top 3 categories for the column
    top_3_categories <- names(sort(table(genericdata[[col]]), decreasing = TRUE)[1:3])
    
    # Save the top 3 categories for this column
    top_3_map[[col]] <- top_3_categories
    # Replace categories outside the top 3 with "Other"
    genericdata[[col]][!(genericdata[[col]] %in% top_3_categories)] <- "Other"
  }
  
  genericdata <- dummy_cols(genericdata, select_columns = categorical_features, remove_selected_columns = TRUE)
  encoded_columns <- setdiff(colnames(genericdata), colnames(genericdata))
  saveRDS(encoded_columns, OHE_ENCODER_FILE)
  #saveRDS(top_3_map, TOP_3_CATEGORIES_MAP)
  genericdata <- genericdata
}


return(list(genericdata,varr,predictor_fields))
 
}

#head(preprocessing(genericdata = genericdata, dataschema = dataschema)[[1]])
