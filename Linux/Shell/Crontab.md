**기존 crontab에 내용 추가**
```shell
(crontab -l 2> /dev/null;
echo;
echo "# $(date +%F): additional crontab";
echo "* * * * * sh /home/supervisor/TEST_CRONTAB1.sh";) | crontab -

(
	crontab -l 2> /dev/null;
	echo;
	echo "# $(date +%F): additional crontab";
	echo "* * * * * sh /home/supervisor/TEST_CRONTAB1.sh";
) | crontab -
```

