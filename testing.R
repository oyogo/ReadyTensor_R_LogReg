#library(dplyr) 
library(rjson)
library(data.table)

fname_test <- dir(path = "./ml_vol/inputs/data/testing/", pattern = "\\_test.csv$")
fname_schema <- dir(path = "./ml_vol/inputs/data_config/", pattern = "\\_schema.json$")
testdata <- fread(paste0("./ml_vol/inputs/data/testing/",fname_test))

tdataschema <- fromJSON(file = paste0("./ml_vol/inputs/data_config/",fname_schema))

# some of the column names do not follow r-naming convention : they have special characters which must be changed
names(testdata) <- gsub("%","x",names(testdata))

# select the ID column into a variable and drop it from the test data. 
# the variable created will be bound to the predicted probabilities 

idfieldname <- tdataschema$inputDatasets$binaryClassificationBaseMainInput$idField
idfieldname <- as.symbol(idfieldname)
# idField <- testdata %>% dplyr::select(all_of(idfieldname))
# testdata <- testdata %>% dplyr::select(-all_of(idfieldname))

idField <- testdata[,c(eval(idfieldname))]
testdata <- testdata[,idfieldname:=NULL]


# load the trained model 
reg_logistic <- readRDS("./ml_vol/model/artifacts/model.rds")

#* @get /predict
function()
{
  df <- testdata
  predicted <-  predict(reg_logistic, newdata=df, type="response")
  predicted <- predicted %>% data.table()
  names(predicted) <- "probabilities"
  
  

  #predicted$probabilities[data$num1 == 1] <- 99
  predicted <- predicted[, predictions:=0][probabilities<0.5, predictions:=1]
  # predicted <- predicted %>% dplyr::mutate(predictions = case_when(
  #   probabilities < 0.5 ~ 0,
  #   probabilities >= 0.5 ~ 1
  # ))
  # add the ID colum to the predictions
  glm_pred = cbind(idField, predicted)
  write.csv(glm_pred,"./ml_vol/outputs/testing_outputs/test_predictions.csv")

}

#testing(df=testdata)


