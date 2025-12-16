VERSION 0.8

FROM node:24.12.0
WORKDIR /app

node-modules-prod:
    COPY package.json package-lock.json .
    RUN npm install --omit dev
    SAVE ARTIFACT node_modules

node-modules-dev:
    FROM +node-modules-prod
    RUN npm install
    SAVE ARTIFACT node_modules

index.js:
    FROM haxe:4.3.7
    WORKDIR /src
    RUN haxelib install hxnodejs
    COPY --dir libs/hxnodelibs libs/
    RUN haxelib dev hxnodelibs libs/hxnodelibs
    COPY --dir src .
    COPY build.hxml .
    RUN haxe build.hxml -D no-deprecation-warnings
    SAVE ARTIFACT index.js AS LOCAL index.js

build.haxe.org:
    COPY package.json .
    COPY +node-modules-prod/node_modules node_modules
    COPY +index.js/index.js .
    ENV HXBUILDS_AWS_ACCESS_KEY_ID
    ENV HXBUILDS_AWS_SECRET_ACCESS_KEY
    EXPOSE 3000
    CMD ["node", "index.js"]
    ARG EARTHLY_GIT_HASH
    ARG IMAGE=ghcr.io/haxefoundation/build.haxe.org:$EARTHLY_GIT_HASH
    SAVE IMAGE --push $IMAGE

run:
    LOCALLY
    WITH DOCKER --load build.haxe.org:latest=+build.haxe.org
        RUN docker run -p 3000:3000 -e HXBUILDS_AWS_ACCESS_KEY_ID -e HXBUILDS_AWS_SECRET_ACCESS_KEY build.haxe.org
    END
