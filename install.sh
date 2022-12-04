#!/bin/bash

#update the OS
apt-get update
apt-get upgrade -y
apt install sudo tasksel -y

#aws cli pre req glibc, groff, and less
sudo apt install glibc-source -y
sudo apt-get install groff -y
sudo apt-get install less -y

# install python 3.10
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.9 -y

# install pip 
sudo apt install python3-pip -y  && apt install curl -y && apt install unzip -y

# install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install