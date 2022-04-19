# syntax=docker/dockerfile:1
FROM debian:buster as build
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get -y install --no-install-recommends cvs make gcc zlib1g-dev
COPY . .
RUN make -C libowfat && make install -C libowfat
RUN make && make install

FROM debian:buster-slim as final
COPY --from=build /opt/diet/bin /app/
WORKDIR /app
ENTRYPOINT ["/app/bin"]
