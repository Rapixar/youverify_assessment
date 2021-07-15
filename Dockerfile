
FROM registry.access.redhat.com/ubi8/nodejs-12 as builder

USER root

WORKDIR /opt/app-root

COPY package.json package-lock.json /opt/app-root/

RUN npm install

COPY . /opt/app-root

RUN npm run build

# Second Stage : Setup command to run your app using lightweight node image #node:12.13-alpine
FROM registry.access.redhat.com/ubi8/nodejs-12 as development

USER root

ARG NODE_ENV=prod

ENV NODE_ENV=${NODE_ENV}

COPY --from=builder /opt/app-root /opt/app-root

WORKDIR /opt/app-root

EXPOSE 3000

RUN npm test:e2e

CMD ["npm", "run", "start"]