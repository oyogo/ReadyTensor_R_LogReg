
#####*****Preprocessing script*****######
#####* This is where we process the data, say imputing NA's with mean plus any other transformation that can be done. 
#####* This function will be sourced in the training script before fitting the model. 

library(data.table) # Opted for this, 1. Because its really fast 2. dplyr conflicted with plumber
library(rjson) # for handling json data

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

catcols <- as.vector(cat_vars$fieldNames)
v <- num_vars$fieldNames

# # loop through the numeric columns and replace na values with mean of the same column in which the na appears.
for (coll in v){

 genericdata <-  genericdata[, (coll) := lapply(coll, function(x) {
    x <- get(x)
    x[is.na(x)] <- mean(x, na.rm = TRUE)
    x
  })]

}

my_mode <- function (x, na.rm) {
  xtab <- table(x)
  xmode <- names(which(xtab == max(xtab)))
  if (length(xmode) > 1) xmode <- ">1 mode"
  return(xmode)
}

for (cat_coll in catcols) {
  genericdata <- as.data.frame(genericdata)
  genericdata[is.na(genericdata[,cat_coll]),cat_coll] <- my_mode(genericdata[,cat_coll], na.rm = TRUE)

}

#names(genericdata) <- make.names(names(genericdata))
names(genericdata) <- gsub("\\s","_",names(genericdata))

#for (cat_coll in catcols){
  #hy <- genericdata[,(catcols),with=FALSE]
#genericdata[,(catcols),with=FALSE] <- impute_mode(genericdata[,(catcols),with=FALSE], type = "columnwise")
#func <- impute_mode()
#genericdata <- as.data.frame(genericdata)
#genericdata <- genericdata[ , (catcols) := lapply(.SD, impute_mode)]  
#genericdata[eval(catcols)] <- lapply(genericdata[eval(catcols)], impute_mode)

#}


# # Replace missing value with the value with the highest occurrence (mode)
# distinct_values <- unique(setDT(genericdata)[,(catcols)])
# # Count the occurrence of each distinct value
# distinct_tabulate <- tabulate(match(catcols, distinct_values))
# 
# 
#   for (cat_coll in catcols){
# 
#   genericdata <-  genericdata[, (cat_coll) := lapply(cat_coll, function(x) {
#     x <- get(x)
# 
#     val <- unique(vec_miss[!is.na(vec_miss)])                   # Values in vec_miss
#     my_mode <- val[which.max(tabulate(match(vec_miss, val)))]
# 
#     x[x == "NA"] <- distinct_values[which.max(distinct_tabulate)]
#     #x[x==""] <- distinct_values[which.max(distinct_tabulate)]
# 
#   })]
# }

return(list(genericdata,varr,predictor_fields))
 
}

#head(preprocessing(genericdata = genericdata, dataschema = dataschema)[[1]])
