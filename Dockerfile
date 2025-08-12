# syntax=docker/dockerfile:1

FROM node:lts-slim
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
