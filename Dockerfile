FROM rocker/r-ver:4.1.0
#FROM rstudio/plumber

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  libsodium-dev \
  libxml2-dev 


RUN R -e "install.packages('data.table', dependencies=T)"
RUN R -e "install.packages('rjson', dependencies=T)"
RUN R -e "install.packages('plumber', dependencies=T)"

RUN mkdir -p ~/modellingLogistic
WORKDIR /modellingLogistic

COPY train.R /modellingLogistic/train.R
COPY testing.R /modellingLogistic/testing.R
COPY plumberscript.R /modellingLogistic/plumberscript.R

# The two scripts (train.R and plumber.R) need to be run in succession. plumber.R should be run only after 
# training.R is successful. To achieve that we use && 
#CMD R -e "source('train.R')" #&&
EXPOSE 8000 

CMD R -e "source('train.R')" && R -e "source('plumberscript.R')"
#CMD R -e "source('plumberscript.R')"
#CMD R -e "plumber::plumb('/home/modellingLogistic/testing.R')$run(host = 0.0.0.0, port = 8000)"
#ENTRYPOINT ["R", "-e", "plumber::plumb('/home/modellingLogistic/testing.R')$run(host = 0.0.0.0, port = 8000)"]"