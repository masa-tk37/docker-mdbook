#####
FROM rust:bullseye AS builder

ENV CARGO_TARGET x86_64-unknown-linux-musl

RUN apt-get update && \
    apt-get install --no-install-recommends -y musl-tools
RUN rustup target add ${CARGO_TARGET}

RUN cargo install mdbook --target ${CARGO_TARGET}; \
    cargo install mdbook-plantuml --target ${CARGO_TARGET} --no-default-features; \
    cargo install mdbook-toc --target ${CARGO_TARGET}

#####
FROM alpine:3

ENV LANG ja_JP.UTF-8

RUN apk update \
    && apk add --no-cache font-ipaex plantuml graphviz \
    && rm -fr /var/cache/apk/*

COPY --from=builder /usr/local/cargo/bin/mdbook /usr/local/bin/mdbook
COPY --from=builder /usr/local/cargo/bin/mdbook-plantuml /usr/local/bin/mdbook-plantuml
COPY --from=builder /usr/local/cargo/bin/mdbook-toc /usr/local/bin/mdbook-toc

EXPOSE 3000
EXPOSE 3001

WORKDIR /doc

ENTRYPOINT [ "/usr/local/bin/mdbook" ]
CMD [ "--help" ]
