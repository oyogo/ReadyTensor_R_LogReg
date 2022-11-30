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

#RUN mkdir -p ~/modellingLogistic
#WORKDIR /modellingLogistic/

#COPY train /modellingLogistic/train
#COPY preprocessor.R /modellingLogistic/preprocessor.R
#COPY testing.R /modellingLogistic/testing.R
#COPY test /modellingLogistic/test
COPY ./../ModellingLogistic /opt/ModellingLogistic
WORKDIR /opt/ModellingLogistic



RUN chmod +x train &&\
    chmod +x test


#CMD R -e "source('train.R')" && R -e "source('plumberscript.R')"
