echo "starting dbus"

#start if not yet started! this should do the trick ;)
/etc/init.d/dbus start

echo "starting wpanctl api server"

/wpanctl-api/wpanctl-api.server &

echo "starting wpantund"

# Syslog mask adjustment. This property is a set of
# boolean masks for manipulating the bitmask used by `syslog()`.
# The string can contain the following words that represent
# the associated bit. The presence of the word in the string
# indicates that that bit should be set. Prefixing the word with
# a `-` (dash/minus) indicates that that bit should be cleared.
# The following keywords are supported:
#
# * `all` (All log levels)
# * `emerg`
# * `alert`
# * `crit`
# * `err`
# * `warn`
# * `notice`
# * `info`
# * `debug`
#
# So, for example, to get all log messages except debugging
# messages, you would use `all -debug`.
#
# Optional. The default value for non-debug builds is
# `all -info -debug`.
#

/usr/local/sbin/wpantund -o Config:NCP:SocketPath /dev/ttyUSB0 -o Daemon:SyslogMask "notice"
