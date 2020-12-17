echo "starting dbus"

#dbus-uuidgen > /var/lib/dbus/machine-id
mkdir -p /var/run/dbus
dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

echo "starting wpanctl api server"

/wpanctl-api/wpanctl-api.server &

echo "starting wpantund"

/usr/local/sbin/wpantund -o Config:NCP:SocketPath /dev/ttyUSB0 -o Daemon:SyslogMask "all"
