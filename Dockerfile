FROM ubuntu:18.04

#Update repo and upgrade 
RUN apt-get update && apt-get upgrade -y

#Install sudo
RUN apt install sudo tasksel -y

#Set Timezone var
ENV TZ=America/Denver
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#Install python
RUN sudo apt-get install python3.8 -y

#Install utilities
RUN apt-get update
RUN apt install python3-pip -y  
RUN apt install curl -y 
RUN apt install unzip -y 
RUN apt install wget -y

#Install aws cli prereq
RUN sudo apt install glibc-source -y && \
	sudo apt-get install groff -y && \
	sudo apt-get install less -y
	
#Install AWS cli 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install

#Configure AWS cli
COPY config ~/.aws/
COPY credentials ~/.aws/

#Install git
RUN apt-get update -y
RUN apt-get update && apt-get install git-all -y

#Install Miniconda 
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && echo "Running $(conda --version)" && \
    conda init bash && \
    . /root/.bashrc && \
    conda update conda

COPY app.py app.py

COPY A2.jpg A2.jpg

COPY requirements.txt requirements.txt

RUN sudo apt install python3.8-distutils

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN sudo python3.8 get-pip.py

RUN pip install -r requirements.txt

RUN git clone https://github.com/AkGandhi99/stable-diffusion.git

WORKDIR /stable-diffusion

RUN conda env update -n base --file environment.yaml

RUN curl https://f004.backblazeb2.com/file/aai-blog-files/sd-v1-4.ckpt > sd-v1-4.ckpt

WORKDIR /
CMD ["python3", "app.py"]

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]