#!/bin/sh

printf "Mount   Total Used  Avail Use "
echo "  "
df -h | grep /data | awk '{print $6, '\t', '\t', '\t', '\t', $2, '\t', $3, '\t', '\t', $4, '\t', $5}'
df -h | grep /archive | awk '{print $6, '\t', $2, '\t', '\t', $3, '\t', $4, '\t', '\t', $5}'
df -h | grep /pg_xlog | awk '{print $6, '\t', $2, '\t', '\t', $3, '\t', $4, '\t', '\t', $5}'