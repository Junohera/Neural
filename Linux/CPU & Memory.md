
## OS SUMMARY
```shell
OS_VERSION=`cat /etc/*-release | grep ^PRETTY_NAME | awk -F= '{print $2}' | sed -e 's/^"//' -e 's/"$//'`
CPU_CORE=`grep -c processor /proc/cpuinfo`
CPU_USED_RATIO=`echo 100 - $(top -bn1 | grep ^"%Cpu(s)" | awk -F, '{print $4}' | awk -F" id" '{print $1}') | bc -l | xargs printf '%.1f%%\n'`
MEM_USED_RATIO=`echo $(free | grep ^Mem | awk '{print $3}') / $(free | grep ^Mem | awk '{print $2}') \* 100 | bc -l | xargs printf '%.1f%%\n'`

clear;printf "OS_VERSION\t: %s\nCPU_CORE\t: %s\nCPU_USED_RATIO\t: %s\nMEM_USED_RATIO\t: %s\n" \
"$OS_VERSION" \
"$CPU_CORE" \
"$CPU_USED_RATIO" \
"$MEM_USED_RATIO" ;
```
# CPU
```shell
# core(s) per socket PHYSICAL
lscpu | grep -i socket
grep "cpu cores" /proc/cpuinfo | tail -1
# core LOGICAL
grep -c processor /proc/cpuinfo
# core
cat /proc/cpuinfo | grep processor | wc -l
# usage
echo 100 - $(top -bn1 | grep ^"%Cpu(s)" | awk -F, '{print $4}' | awk -F" id" '{print $1}') | bc -l | xargs printf '%.1f%%\n'
# idle
top -bn1 | grep ^"%Cpu(s)" | awk -F, '{print $4}' | awk -F" id" '{print $1}'
```
# MEMORY
```shell
# total
free | grep ^Mem | awk '{print $2}'
# used
free | grep ^Mem | awk '{print $3}'
# used ratio
# ___used_memory=$(free | grep ^Mem | awk '{print $3}')
# ___total_memory=$(free | grep ^Mem | awk '{print $2}')
# echo $___used_memory / $___total_memory \* 100 | bc -l | xargs printf '%.2f%%\n'
echo $(free | grep ^Mem | awk '{print $3}') / $(free | grep ^Mem | awk '{print $2}') \* 100 | bc -l | xargs printf '%.1f%%\n'
```

# report 
```shell
# TEMPLATE
CPU: ${___CPU___}, MEM: ${___MEM___}

# BIND
___CPU___=$(echo 100 - $(top -bn1 | grep ^"%Cpu(s)" | awk -F, '{print $4}' | awk -F" id" '{print $1}') | bc -l | xargs printf "%.1f%%\n");
___MEM___=$(echo $(free | grep ^Mem | awk '{print $3}') / $(free | grep ^Mem | awk '{print $2}') \* 100 | bc -l | xargs printf '%.1f%%\n');
echo "CPU: ${___CPU___}, MEM: ${___MEM___}"

# REPORT
CPU: 92.7%, MEM: 16.7%
```

## STRESS TEST
```shell
top -bn1 | grep ^"%Cpu(s)"
# %Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st

sudo apt-get install stress

stress -c 1 # 1 CORE
top -bn1 | grep ^"%Cpu(s)"
# %Cpu(s):  8.2 us,  0.5 sy,  0.0 ni, 90.7 id,  0.0 wa,  0.0 hi,  0.5 si,  0.0 st

stress -c 12 # 12 CORE
top -bn1 | grep ^"%Cpu(s)"
# %Cpu(s):100.0 us,  0.0 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
```