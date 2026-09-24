FROM node:14.21.3-slim AS node_env

FROM ruby:2.6.3

COPY --from=node_env /usr/local /usr/local

RUN rm -f /usr/local/bin/yarn /usr/local/bin/yarnpkg && \
    npm install -g yarn@1.22.22

WORKDIR /usr/src/app

COPY . .

RUN bundle update mimemagic
RUN bundle install --full-index

RUN node -v && npm -v && yarn -v
RUN yarn install --check-files
