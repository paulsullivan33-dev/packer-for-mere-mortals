#!/bin/sh
# Example application launcher, staged into the image as a placeholder.
echo "example app starting"
exec /opt/app/server --config /opt/app/server.conf
