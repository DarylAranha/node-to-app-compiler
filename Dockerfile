FROM alpine:3.15

RUN apk add --no-cache nodejs npm

ADD compiler.sh compiler.sh

WORKDIR /app

ENTRYPOINT [ "sh", "/compiler.sh" ]