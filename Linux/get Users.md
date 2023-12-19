```shell
cat /etc/passwd
cut -f1 -d: /etc/passwd
cat /etc/passwd | awk -F: '{print $1}'
```