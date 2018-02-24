#!/bin/sh

PIDFILE=t/servroot/nginx.pid

start() {
  if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE"); then
    echo 'Service already running' >&2
    return 1
  fi

  echo 'Starting service…' >&2
  cp nginx_sample.conf t/servroot/
  nginx -p `pwd`/t/servroot -c nginx_sample.conf
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  nginx -p `pwd`/t/servroot -c nginx.conf -s stop
  echo 'Service stopped' >&2
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
esac
