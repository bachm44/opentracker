FROM debian:buster
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get -y install --no-install-recommends cvs make gcc zlib1g-dev
COPY . .
RUN make -C libowfat && make install -C libowfat
RUN make && make install

CMD ["/opt/diet/bin"]