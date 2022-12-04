# need ubuntu-alpine.
FROM ubuntu:focal

RUN mkdir /app

WORKDIR /app

COPY install.sh install.sh

ENV TZ=America/Denver
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN chmod a+x install.sh
RUN ./install.sh

COPY config ~/.aws/
COPY credentials ~/.aws/

COPY app.py app.py

COPY A2.jpg A2.jpg
COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

CMD ["gunicorn", "-w 4", "app:app"]