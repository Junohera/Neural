## 특징
- client : process = 1:1 (다중 프로세스 기반)
	- 다른 db엔진에 비해 shared memory를 많이 할당할 수 없다
- 비교적 충실한 트랜잭션 처리 - 이상적인 트랜잭션 처리는 없다!
- OS에 의존도가 큼(CPU 사용량이 궁금해? 그럼 os단에서 확인해!)
- 이식성이 완벽하지 않다.
> ASIS: same OS, same Bit
> TOBE: same OS, same CPU type, same Bit

## 설치 유형 확인
설치를 `수동`으로 했는지 `자동`(package)으로 했는지 확인이 필요하다.
- [?] 전혀 다른 libpq를 참조할 경우 버그 유발 가능성이 존재하고,
      작업시 위치를 알아야 하기 때문.
```shell
# linux 환경 확인
cat /etc/os-release
# process 확인
ps -ef | grep postgres
```

process 확인시 최상위 프로세스 id를 확인하고,
최상위 프로세스 id를 통해 설치된 경로를 파악해야한다.
만약 패키지로 설치했을 경우 다음 중 확인(rpm || debian || yum)


## LD_LIBRARY_PATH 존재 확인
- [?] 미리 설치된 다른 pgsql 관련파일이 있을 수 있고
      배포판에서 기본적으로 설치되는 postgresql-libs 패키지가 있는데, 충돌 가능성도 있다.
      더불어 사용자가 임의로 LD_LIBRARY_PATH 설정을 해서 전혀 다른 libpq 라이브러리를 참조할 수도 있음.

**확인 방법**
```shell
rpm -ql postgresql14
rpm -ql postgresql14-server
id postgres
ldd /usr/pgsql-14/bin/psql
```
만약 있을 경우
ldd 명령으로 libpq 라이브러리 참조를 꼭 살펴보아야 한다.

## 명령행 도구들
### 서버 관점
> 명령행 도구들 목록 보기: `rpm -ql postgresql14-server | grep bin`
1. initdb : 데이터베이스 초기화 도구, 서버를 구성할 때 처음 한 번은 꼭 사용해야한다.
2. pg_controldata: 데이터 클러스터 정보 보기, 백업 복구 때 중요한 정보를 제공한다.
3. **pg_ctl: 기본 서버 관리 도구**
4. pg_upgrade: 메이저 버전 업그레이드 도구
5. postgres: 서버 프로그램 (pg_ctl 명령으로 이 프로세스를 실행하고 중지한다)
### Client 관점
> 명령행 도구들 목록 보기: `rpm -ql postgresql14 | grep bin`
1. pg_basebackup: 온라인 백업 도구    
2. pg_dump, pg_restore: dump & restore 도구    
3. **psql: 대화형 데이터베이스 조작 도구**    
4. vacuumdb: 데이터베이스 청소 도구

### idle in transaction

auto commit이 아닐 경우에 commit이든 rollback을 실행하지 않을 경우, 다음과 같이 프로세스가 계속 남는다.
```shell
begin;  
\! ps | grep idle | grep -v grep  
130 postgres postgres: postgres postgres [local] idle  
163 postgres postgres: postgres postgres [local] idle in transaction💥
```
### after when failure query in transaction
```shell
postgres=# begin;  
BEGIN  
postgres=*# select 1/0;💥  
ERROR:  division by zero  
​  
​  
postgres=!# select 1;💥  
ERROR:  current transaction is aborted, commands ignored until end of transaction block  
postgres=!# select 1;💥  
ERROR:  current transaction is aborted, commands ignored until end of transaction block  
postgres=!# select 1;💥  
ERROR:  current transaction is aborted, commands ignored until end of transaction block 
...
```