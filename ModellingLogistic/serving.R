#!/usr/bin/env Rscript
library(data.table)
library(rjson)
library(readr)
#json list(auto_unbox=TRUE)

#* @post /infer
#* @serializer json list(auto_unbox=TRUE)
function(req) {
  
    # df <- req$postBody
    # parsed_df <- rjson::fromJSON(df)
    # #dfr <-  as.data.frame(do.call(cbind, parsed_df))
    # dfr <- data.table::rbindlist(parsed_df$instances)
    # num_cols <- names(dfr)
    # dfr <- setDT(dfr)[,(num_cols):= lapply(.SD, as.numeric), .SDcols = num_cols]
    # 
    # model <- readr::read_rds("./../ml_inputs_outputs/model/artifacts/model.rds")
    # id <- readr::read_rds("./../ml_inputs_outputs/model/artifacts/id.rds")
    # 
    # #dfr <- subset(dfr, select=-id)
    # dfr <- subset(dfr, select = -c(eval(as.name(paste0(id)))))
    # 
    # predicted <- predict(model,newdata=dfr, type="response")
    # predicted <- data.table(predicted)
    # names(predicted) <- "probabilities"
    # # where the probabilities returned are <0.5 put 0 otherwise 1.
    # predicted <- setDT(predicted)[, predictions:=0][probabilities>0.5, predictions:=1]
    # glm_pred = cbind(eval(id), predicted)
    # glm_pred
    
    
    
    df <- req$postBody
    parsed_df <- rjson::fromJSON(df)
    dfr <- data.table::rbindlist(parsed_df$instances)
    model <- readr::read_rds("./../model_inputs_outputs/model/artifacts/model.rds")
   # resvar <- readr::read_rds("./../ml_vol/model/artifacts/response_variable.rds")
    #thefeatures <- readr::read_rds("./../ml_vol/model/artifacts/features.rds")
    id <- readr::read_rds("./../model_inputs_outputs/model/artifacts/id.rds")

    newdf <- subset(dfr, select = -c(eval(as.name(paste0(id)))))
    

    predicted <- predict(model,newdata=newdf, type="response")
    predicted <- data.table(predicted)
    names(predicted) <- "probabilities"
    predicted <- cbind(newdf,predicted)
    
    # where the probabilities returned are <0.5 put 0 otherwise 1.
    predicted <- setDT(predicted)[, predictions:=0][probabilities>0.5, predictions:=1]
    cols <- c(eval(id),"probabilities","predictions")
    predicted <- predicted[,..cols]
    predicted

   
}