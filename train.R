library(dplyr) # for data munging 
library(rjson) # for handling json data 
library(data.table) # faster in munging data

# use pattern to read data : this is to make the model generic 
fname_train <- dir(path = "./ml_vol/inputs/data/training/", pattern = "\\_train.csv$")
fname_schema <- dir(path = "./ml_vol/inputs/data_config/", pattern = "\\_schema.json$")


genericdata <- fread(paste0("./ml_vol/inputs/data/training/",fname_train))

# get the response variable from the schema
dataschema <- fromJSON(file = paste0("./ml_vol/inputs/data_config/",fname_schema))

# get the response variable and store it as a character to a variable
varr <- dataschema$inputDatasets$binaryClassificationBaseMainInput$targetField

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(genericdata) <- gsub("%","x",names(genericdata))

# drop the id field 
## get the field name and store it as a variable
idfieldname <- dataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- as.symbol(idfieldname)
## drop it from the data
genericdata <- genericdata %>% dplyr::select(-all_of(idfieldname))

# function to train the model  and save it back into the mounted volume
lets_train <- function(dat,rvar){
 
  ndat <- dplyr::select(dat, -all_of(rvar))
  indvars <- names(ndat)

  theModel <- glm(reformulate(termlabels = indvars, response = rvar),family=binomial(link='logit'), data = dat)
  output.model <- summary(theModel)
  
  saveRDS(theModel, "./ml_vol/model/artifacts/model.rds")

}

# calling the model 
glmModel <- lets_train(dat=genericdata, rvar = varr)  

