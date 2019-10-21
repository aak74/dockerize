FROM node:8-alpine as stage
RUN npm install -g vuepress
COPY ./src /doc
RUN vuepress build /doc

FROM nginx:1.14

LABEL maintainer="Andrew Kopylov <aa74ko@gmail.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl netcat

COPY ./container/rootfs /
COPY --from=stage /doc/.vuepress/dist /app

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost/status/ || exit 1
