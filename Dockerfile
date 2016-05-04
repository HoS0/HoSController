
FROM node:4.4-wheezy

RUN apt-get update -y
RUN apt-get upgrade -y
	
RUN apt-get install curl


RUN apt-get install --yes build-essential

ADD . /APP

WORKDIR /APP

RUN npm install
