FROM debian:buster
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get -y install --no-install-recommends cvs make gcc zlib1g-dev
COPY . .
ENTRYPOINT ["/bin/sh", "-c" , "make -C libowfat && make install -C libowfat && make"]