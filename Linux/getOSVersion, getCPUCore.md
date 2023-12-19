**os version**
`cat /etc/os-release | grep PRETTY_NAME | awk -F"=" '{print $NF}'`
**cpu core**
`grep -c processor /proc/cpuinfo`

