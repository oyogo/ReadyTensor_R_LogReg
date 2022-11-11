# Automating Logistic Regression
* The idea is to have a logistic regression run in a container and save the model back to the attached folder.   
* When running the container a volume needs to be attached which contains the csv files and the data schema.    

Note: for now the model is fixed to the spam data but I'll have it work with any data.  

Next I want to create an API for prediction/inference then see how to link the two (container and API) perhaps they could all run in a container.   

