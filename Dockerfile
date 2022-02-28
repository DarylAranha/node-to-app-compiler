FROM alpine:latest

RUN apk add --no-cache nodejs npm

WORKDIR /app

COPY . .

ENTRYPOINT [ "./compile.sh" ]