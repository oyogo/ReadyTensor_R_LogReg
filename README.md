# Automating Logistic Regression
* The idea is to have a logistic regression run in a container and save the model back to the attached folder.   
* When running the container a volume needs to be attached which contains the csv files and the data schema.    

To try this locally on your pc see the steps below: 

1. Your data folder   
Note: ensure you name it : *data*      
should have your files with the following pattern     
```
*_train.csv
*_test.csv
*_schema.json 

```
2. spin the docker container   

note: 
 * logistic is the docker image name    
 * ensure port 3838 is not in use   
 * this path _/home/modellingLogistic/data_ should be as it for that's how its predefined inside the container.   
 
```
docker run -it --rm -p 3838:3838 -v "/path/to/your/data":"/home/modellingLogistic/data"  logistic

```

Next I want to create an API for prediction/inference then see how to link the two (container and API) perhaps they could all run in a container.   

