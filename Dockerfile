FROM ubuntu

RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get -y -q --no-install-recommends install git \
         dbus \
         gcc g++ libdbus-1-dev libboost-dev \
         libtool automake make autoconf autoconf-archive ca-certificates \
    && dpkg-reconfigure dbus \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /wpantund
COPY ./wpantund .
RUN ./bootstrap.sh && ./configure --sysconfdir=/etc
RUN make -j4 && make install

# install go..
COPY --from=golang:1.15 /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"
RUN go version

WORKDIR /wpanctl-api
COPY ./wpanctl-api .
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o ./wpanctl-api.server

WORKDIR /
COPY ./init_and_start.sh .

#CMD /usr/local/sbin/wpantund -o Config:NCP:SocketPath /dev/ttyUSB0 -o Daemon:SyslogMask "all"
CMD ./init_and_start.sh
