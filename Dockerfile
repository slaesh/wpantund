FROM ubuntu AS builder

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

FROM ubuntu AS production

RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get -y -q --no-install-recommends install \
         dbus \
    && dpkg-reconfigure dbus \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=builder /etc/dbus-1/system.d/wpantund.conf /etc/dbus-1/system.d/wpantund.conf
COPY --from=builder /etc/wpantund.conf /etc/wpantund.conf
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/libexec /usr/local/libexec
COPY --from=builder /usr/local/sbin/wpantund /usr/local/sbin/wpantund
COPY --from=builder /usr/local/share/man /usr/local/share/man

COPY --from=builder /wpanctl-api/wpanctl-api.server /wpanctl-api/wpanctl-api.server

COPY ./init_and_start.sh /
CMD /init_and_start.sh
