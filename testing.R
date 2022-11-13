library(dplyr) 
#library(pROC)
library(data.table)
library(rjson)

fname_test <- dir(path = "./data/", pattern = "\\_test.csv$")
fname_schema <- dir(path = "./data/", pattern = "\\_schema.json$")
testdata <- fread(paste0("./data/",fname_test))

tdataschema <- fromJSON(file = paste0("./data/",fname_schema))

# get the response variable and store it as a character 
test_resvar <- tdataschema$inputDatasets$binaryClassificationBaseMainInput$targetField

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(testdata) <- gsub("%","x",names(testdata))

# drop the id field 
# get the field name 
idfieldname <- tdataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- as.symbol(idfieldname)
yvar <- as.symbol(test_resvar)
testdata <- testdata %>% dplyr::select(-all_of(idfieldname))
#testdata <- testdata %>% dplyr::select(-all_of(yvar))

reg_logistic <- readRDS("./data/model.rds")

testing <- function(df)
{
  respvar <- df %>% dplyr::select(all_of(yvar))
  predicted <-  predict(reg_logistic, df, type="response")
  predicted <- predicted %>% as.data.frame()
  names(predicted) <- "probabilities"
  predicted <- predicted %>% dplyr::mutate(predictions = case_when(
    probabilities < 0.5 ~ 0,
    probabilities >= 0.5 ~ 1
  ))
 
  fwrite(predicted,"./data/predictions.csv")
  #aucc <- auc(respvar, predicted)
  #return(aucc)
}

testing(df=testdata)


