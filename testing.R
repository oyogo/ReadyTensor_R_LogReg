library(dplyr) 
library(data.table)
library(rjson)

fname_test <- dir(path = "./data/", pattern = "\\_test.csv$")
fname_schema <- dir(path = "./data/", pattern = "\\_schema.json$")
testdata <- fread(paste0("./data/",fname_test))

tdataschema <- fromJSON(file = paste0("./data/",fname_schema))

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(testdata) <- gsub("%","x",names(testdata))

# select the ID column into a variable and drop it from the test data. 
# the variable created will be bound to the predicted probabilities 

idfieldname <- tdataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- as.symbol(idfieldname)
idField <- testdata %>% dplyr::select(all_of(idfieldname))
testdata <- testdata %>% dplyr::select(-all_of(idfieldname))


# load the trained model 
reg_logistic <- readRDS("./data/model.rds")

testing <- function(df)
{
 
  
  predicted <-  predict(reg_logistic, newdata=df, type="response")
  predicted <- predicted %>% as.data.frame()
  names(predicted) <- "probabilities"
  predicted <- predicted %>% dplyr::mutate(predictions = case_when(
    probabilities < 0.5 ~ 0,
    probabilities >= 0.5 ~ 1
  ))
  # add the ID colum to the predictions
  glm_pred = cbind(idField, predicted)
  fwrite(glm_pred,"./data/glm_predictions.csv")

}

testing(df=testdata)


