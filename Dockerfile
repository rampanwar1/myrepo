FROM node:12

WORKDIR /app

COPY . /app

EXPOSE 5000

CMD npm start

