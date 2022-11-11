library(dplyr) # for data munging 
library(rjson)
library(data.table)
library(readr)

## This needs automation: should read files using pattern matching 

# data import
# thepath <- "./data/"
# 
# v.filename <- list.files(path=thepath, pattern = "*_train.csv")
# 
# genericdata <- fread(v.filename)

genericdata <- fread("./data/spam_train.csv")

# get the response variable from the schema
dataschema <- fromJSON(file = "./data/spam_schema.json")

# get the response variable and store it as a character 
varr <- dataschema$inputDatasets$binaryClassificationBaseMainInput$targetField

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(genericdata) <- gsub("%","x",names(genericdata))

# drop the id column 
genericdata <- genericdata %>% dplyr::select(-id)

# function to run the model  
auto_model <- function(dat,rvar){
 
  ndat <- dplyr::select(dat, -all_of(rvar))
  indvars <- names(ndat)

  theModel <- glm(reformulate(termlabels = indvars, response = rvar),family=binomial(link='logit'), data = dat)
  output.model <- summary(theModel)
  
  saveRDS(theModel, "./data/model.rds")

}

# calling the model 
glmModel <- auto_model(dat=genericdata, rvar = varr)  


