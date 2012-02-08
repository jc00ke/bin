#/usr/bin/sh

curl -s $1 | python -mjson.tool
