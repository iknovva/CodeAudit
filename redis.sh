#!/bin/bash

set -e

echo "Starting the redis server"

nohup redis-server &
