

# File Descriptor

| descriptor | define          |
| ---------- | --------------- |
| 0          | standard input  |
| 1          | standard output |
| 2          | standard error  |

`2>&1`의 의미

2는 standard error
&1은 standard output

from `standard error` to `standard output`

```shell
(crontab -l 2> /dev/null; echo "* * * * * sh /home/sample.sh > /dev/null 2> &1") | crontab -
```

