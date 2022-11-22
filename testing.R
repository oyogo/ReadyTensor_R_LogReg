#!/usr/bin/env Rscript

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

# save the idField into a vector. We'll bind this to the prediction dataframe to ensure the predictions are returned in the same order of
# of the records in the original dataframe. 
idfieldname <- as.symbol(idfieldname)
idField <- testdata[,c(eval(idfieldname))]

# drop the ID column from the dataset, we don't need it for testing. 
testdata <- subset(testdata,select = -c(eval(as.name(paste0(idfieldname)))))

# load the trained model
reg_logistic <- readRDS("./ml_vol/model/artifacts/model.rds")

#* @get /predict
function()
{
  df <- testdata
  predicted <-  predict(reg_logistic, newdata=df, type="response")
  predicted <- data.table(predicted)
  names(predicted) <- "probabilities"
 
  # where the probabilities returned are <0.5 put 0 otherwise 1. 
  predicted <- predicted[, predictions:=0][probabilities<0.5, predictions:=1]

  # add the ID colum to the predictions
  glm_pred = cbind(idField, predicted)
  glm_pred <- dcast(glm_pred, idField ~ predictions, value.var = "predictions")
  colnames(glm_pred)[2:3]<-paste("class",colnames(glm_pred)[2:3],sep="_")
  write.csv(glm_pred,"./ml_vol/outputs/testing_outputs/test_predictions.csv")

}

