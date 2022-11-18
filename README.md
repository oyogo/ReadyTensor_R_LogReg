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
 * ensure port 8000 is not in use     
 * this path _/home/modellingLogistic/ml_vol_ should be as it for that's how its predefined inside the container.   
 
```
docker run -it --rm -p 8000:8000 -v "/path/to/your/ml_vol":"/home/modellingLogistic/ml_vol"  oyogo/logistic

```

Once you've run that, the container runs the model and saves it inside the data folder with the name : *model.rds*   
one more thing :  
we now have a prediction script which uses the test data to predict and save the output as predictions.csv inside the data folder.   

We now have a inference API using plumber. so what happens when you run the container is the training script is run, model gets saved in the artifacts folder, once that is successful the plumber script gets run and then the the API interface is made available on port 8000.  You should have the following output on the terminal when you run the container.  

```
> source('plumberscript.R')
Running plumber API at http://0.0.0.0:8000
Running swagger Docs at http://127.0.0.1:8000/__docs__/

```
Take the _http://127.0.0.1:8000/__docs__/_ and post it on your browser, you should be able to see the swagger ui. Click on predict, then try_out and then execute. 
You can now check the testing_output folder inside the outputs folder of ml_vol. You should be able to see a test_predictions.csv file inside it.  


