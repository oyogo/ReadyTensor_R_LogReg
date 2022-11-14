library(dplyr) # for data munging 
library(rjson) # for handling json data 
library(data.table) # faster in munging data
#library(readr)

# use pattern to read data : this is to make the model generic 
fname_train <- dir(path = "./data/", pattern = "\\_train.csv$")
fname_schema <- dir(path = "./data/", pattern = "\\_schema.json$")

#genericdata <- fread("./data/spam_train.csv")
genericdata <- fread(paste0("./data/",fname_train))

# get the response variable from the schema
#dataschema <- fromJSON(file = "./data/spam_schema.json")
dataschema <- fromJSON(file = paste0("./data/",fname_schema))

# get the response variable and store it as a character 
varr <- dataschema$inputDatasets$binaryClassificationBaseMainInput$targetField

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(genericdata) <- gsub("%","x",names(genericdata))

# drop the id field 
# get the field name 
idfieldname <- dataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- as.symbol(idfieldname)
genericdata <- genericdata %>% dplyr::select(-all_of(idfieldname))

# function to run the model  
lets_train <- function(dat,rvar){
 
  ndat <- dplyr::select(dat, -all_of(rvar))
  indvars <- names(ndat)

  theModel <- glm(reformulate(termlabels = indvars, response = rvar),family=binomial(link='logit'), data = dat)
  output.model <- summary(theModel)
  
  saveRDS(theModel, "./data/model.rds")

}

# calling the model 
glmModel <- lets_train(dat=genericdata, rvar = varr)  

