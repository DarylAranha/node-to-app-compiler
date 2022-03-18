FROM alpine:3.15

RUN apk add --no-cache nodejs npm

RUN npm install --prefix /tmp/package-compiler browserify uglify-js

ADD compiler.sh compiler.sh

WORKDIR /app

ENTRYPOINT [ "sh", "/compiler.sh" ]