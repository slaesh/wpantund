FROM ubuntu

RUN apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get -y -q --no-install-recommends install git \
         dbus \
         gcc g++ libdbus-1-dev libboost-dev \
         libtool automake make autoconf autoconf-archive \
    && dpkg-reconfigure dbus \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN ./bootstrap.sh && ./configure --sysconfdir=/etc
RUN make -j4 && make install

CMD /usr/local/sbin/wpantund -o Config:NCP:SocketPath /dev/ttyUSB0 -o Daemon:SyslogMask "all -debug"
