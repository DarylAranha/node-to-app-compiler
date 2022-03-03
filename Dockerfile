FROM alpine:3.15

RUN apk add --no-cache nodejs npm

ADD compile.sh /app/compile.sh

ENTRYPOINT [ "./compile.sh" ]