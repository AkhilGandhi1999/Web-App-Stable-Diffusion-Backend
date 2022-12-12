FROM ubuntu:18.04

#Update repo and upgrade 
RUN apt-get update && apt-get upgrade -y

#Install sudo
RUN apt install sudo tasksel -y

#Install python
RUN sudo apt-get install python3.8 -y

#Install utilities
RUN sudo apt-get update
RUN sudo apt install python3-pip -y
RUN sudo apt install curl -y 
RUN sudo apt install unzip -y 
RUN sudo apt install wget -y

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

ENV TZ=America/Denver
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN mkdir /flask_server

WORKDIR /flask_server

RUN sudo apt-get update && apt-get install git-all -y

RUN git clone https://github.com/AkGandhi99/stable-diffusion.git

WORKDIR stable-diffusion/

RUN conda env create -f environment.yaml

#Install aws cli prereq
RUN sudo apt install glibc-source -y && \
	sudo apt-get install groff -y && \
	sudo apt-get install less -y

RUN curl https://f004.backblazeb2.com/file/aai-blog-files/sd-v1-4.ckpt > sd-v1-4.ckpt

WORKDIR /flask_server

RUN mkdir send_images/

COPY app.py app.py

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]

WORKDIR /

#Install AWS cli 
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install

#Configure AWS cli
COPY config ~/.aws/
COPY credentials ~/.aws/

WORKDIR /flask_server

CMD ["python3", "app.py"]