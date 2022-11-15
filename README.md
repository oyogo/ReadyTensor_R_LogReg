# Automating Logistic Regression   

* The idea is to have a logistic regression run in a container and save the model back to the attached folder.   
* When running the container a volume needs to be attached which contains the csv files and the data schema.    

To try this locally on your pc see the steps below: 

1. Your data folder   
Note: ensure you name it : *ml_vol*      
should have your files with the following pattern     
```
*_train.csv
*_test.csv
*_schema.json 

```

2.  download the image from my dockerhub 

```
docker pull oyogo/logistic

```

3. spin the docker container   

note: 
 * oyogo/logistic is the docker image name as pulled from dockerhub   
 * ensure port 3838 is not in use     
 * this path _/home/modellingLogistic/ml_vol_ should be as it for that's how its predefined inside the container.   
 
```
docker run -it --rm -p 3838:3838 -v "/path/to/your/ml_vol":"/home/modellingLogistic/ml_vol"  oyogo/logistic

```

Once you've run that, the container runs the model and saves it inside the data folder with the name : *model.rds*   
one more thing :  
we now have a prediction script which uses the test data to predict and save the output as predictions.csv inside the data folder.   

Note: I'll have separate folders for the input and output 

Next I want to create an API for prediction/inference then see how to link the two (container and API), perhaps they could all run in a container.   

