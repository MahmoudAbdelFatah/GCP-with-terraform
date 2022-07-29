FROM python:3.9-alpine

WORKDIR /app

COPY . ./app

RUN pip install -r requirements.txt

RUN export $(cat .env | xargs)

EXPOSE 8000

CMD [ "python3", "hello.py" ]