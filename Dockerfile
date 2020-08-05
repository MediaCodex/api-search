FROM node:erbium-alpine
WORKDIR /usr/src/app

# install dependencies
COPY package*.json ./
RUN npm ci --only=production

# copy source
COPY ./src ./src

# set up env
ENV NODE_ENV=production

# launch
EXPOSE 3000
CMD ["npm", "start"]