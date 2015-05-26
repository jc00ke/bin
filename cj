#!/bin/bash

curl -s $1 | python -mjson.tool
