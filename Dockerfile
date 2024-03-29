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
RUN R -e "install.packages('jsonlite', dependencies=T)"
RUN R -e "install.packages('tidyr', dependencies=T)"
RUN R -e "install.packages('fastDummies', dependencies=T)"
RUN R -e "install.packages('dplyr', dependencies=T)"
RUN R -e "install.packages('caret', dependencies=T)"
RUN R -e "install.packages('nnet', dependencies=T)"

#RUN mkdir -p ~/modellingLogistic
#WORKDIR /modellingLogistic/

#COPY train /modellingLogistic/train
#COPY preprocessor.R /modellingLogistic/preprocessor.R
#COPY testing.R /modellingLogistic/testing.R
#COPY test /modellingLogistic/test
COPY ./ModellingLogistic /opt/ModellingLogistic
WORKDIR /opt/ModellingLogistic

ENV PATH="/opt/ModellingLogistic:${PATH}"

RUN chmod +x train &&\
    chmod +x predict &&\
    chmod +x serve


#CMD R -e "source('train.R')" && R -e "source('plumberscript.R')"
