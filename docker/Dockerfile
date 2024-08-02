FROM rakudo-star:alpine

ARG PAT_GIT
ENV HOST="0.0.0.0"
ENV PORT="9191"

USER root

# Install necessary dependencies for Raku dependencies
RUN apk update &&\
    apk add build-base &&\
    apk add --update openssl openssl-dev curl git &&\
    rm -rf /var/cache/apk/*

# Copy all Raku files to the container
COPY bin/* /home/raku/bin/
COPY *.json /home/raku/

COPY docker/bootstrap.sh /home/raku/
COPY resources/zsh-nuke-and-install.sh /home/raku/
COPY bin/dsl-web-translation-service /home/raku/dsl-web-translation-service

WORKDIR /home/raku

# Install all Raku library dependencies
RUN sh /home/raku/zsh-nuke-and-install.sh

RUN chown raku:raku -R /home/raku &&\
    chmod -R 500 /home/raku/* &&\
    chmod -R 500 /home/raku/bin/*

USER raku

EXPOSE $PORT

ENTRYPOINT ["/bin/sh"]
CMD ["bootstrap.sh"]