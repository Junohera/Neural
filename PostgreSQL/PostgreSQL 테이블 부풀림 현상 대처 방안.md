![[1610671bdfd8eb46e152c8671fd19e2d_MD5.jpg]]

## PostgreSQL 테이블 부풀림 현상 대처 방안

## 테이블이 자꾸 커져요

PostgreSQL 질문 답변 게시판에서 꾸준히 올라오는 질문 가운데 하나다.

테이블에 보관된 자료의 실제 크기는 그 테이블을 pg\_dump로 덤프해 보면 1MB 밖에 안되는데, psql 에서 \\dt+ 명령으로 테이블 크기를 살펴보면, 100MB나 된다.  이 일을 어쩔꺼나. 이런 식으로 하소연(?)을 한다.

결론. PostgreSQL에서 해당 테이블 대상으로 UPDATE, DELETE 명령을 이용해서 자료 조작이 일어난다면, 그 테이블 크기는 실 자료 크기보다 커질 수 밖에 없다. 물론 사용자의 자료 조작 뿐만 아니라, 트리거나, 함수를 통해서 일어나는 자료 변경, 삭제도 마찬가지다.

이 테이블 부풀림 현상은 다양한 모습으로 이상 동작을 한다.  가장 대표적인 것이 테이블 전체 탐색을 하면서 과도한 자료 블럭 읽기로 SELECT 쿼리 실행 속도가 현저하게 떨어지는 현상이다.  좀 더 깊게 살펴보면, 데이터베이스의 나이가 줄어들지 않아, 트랜잭션 ID 겹침 방지 autovacuum worker가 계속 freeze 작업만 하고 있는 현상도 나타난다. 이 현상을 방치하고 있으면 결국 트랜잭션ID 재활용을 하지 못해 데이터베이스가 중지 되는 사태까지 발생하기도 한다.

## 테이블이 커질 수 밖에 없는 이유

PostgreSQL 다중 버전 동시성 제어(MVCC) 기법 때문이다. UPDATE나 DELETE 작업이 일어날 경우 기존 자료(old version)와 새 자료(new version, UPDATE 작업으로 생긴 자료)를 해당 테이블에 모두 두기 때문이다.   

극단적인 예로 해당 테이블을 autovacuum 데몬이 관리하지 않도록 설정하고, insert & rollback 을 무한 반복한다면, 해당 테이블은 디스크 공간이 허용하는 한, 트랜잭션 겹침 방지를 위한 vacuum 작업이 생기지 않는한 영원히 그 테이블은 커지게 된다. 설령 그 테이블 안에 모든 자료가 rollback 되어 한 건도 없다 하더라도.

앞에서 다룬 이야기는 정말 극단적인 상황이고, 단순히 일반적인 상황을 고려해도 마찬가지다.  autovacuum 데몬이 해당 테이블을 관리한고 있다고 하더라도(기본값), 해당 테이블 전체 UPDATE 작업을 하나의 명령으로 실행한 경우라면, 정확히 두 배의 공간이 필요하게 된다.

```
postgres@postgres=# create table test (a int, b int);
CREATE TABLE
postgres@postgres=# alter table test set (autovacuum_enabled = false); -- autovacuum 비활성화
ALTER TABLE
postgres@postgres=# insert into test 
select generate_series, generate_series from generate_series(1, 100000);
INSERT 0 100000
postgres@postgres=# \dt+ test
              릴레이션(relation) 목록
 스키마 | 이름 |  종류  |  소유주  |  크기   | 설명 
--------+------+--------+----------+---------+------
 public | test | 테이블 | postgres | 3568 kB | 
(1개 행)

postgres@postgres=# update test set b = b + 1 ;
UPDATE 100000
postgres@postgres=# \dt+ test
              릴레이션(relation) 목록
 스키마 | 이름 |  종류  |  소유주  |  크기   | 설명 
--------+------+--------+----------+---------+------
 public | test | 테이블 | postgres | 7104 kB | 
(1개 행)

postgres@postgres=# update test set b = b + 1 ;
UPDATE 100000
postgres@postgres=# \dt+ test
             릴레이션(relation) 목록
 스키마 | 이름 |  종류  |  소유주  | 크기  | 설명 
--------+------+--------+----------+-------+------
 public | test | 테이블 | postgres | 10 MB | 
(1개 행)

```

이렇게 update 작업을 할 때마다 사용 공간은 전체 자료 공간 만큼 늘어나게 된다. 이 문제는 delete 인 경우도 마찬가지다. 자료를 지운다고 해서 테이블 크기가 줄어드는 것은 아니다!  

## vacuum 명령어

PostgreSQL에서는 이 문제를 vacuum 명령으로 처리한다.  vacuum 명령은 크게 다음과 같은 일을 한다.

-   dead tuple 들을 free space로 바꾸는 작업  
    dead tuple이란 delete 작업으로 commit 된 자료나 update 작업으로 commit 된 old version 자료, 즉 어떤 세션에서 보이지 않는 이미 지워진 자료를 말한다. 이 dead tuple은 vacuum 작업으로 free space를 바뀌기 전까지는 그 자리에 새 자료가 저장될 수 없다.   
    윗 예제로 설명하면, 첫 update 작업에서 10만개의 dead tuple이 생기고, 그것이 vacuum 작업으로 free space로 바뀌지 않았기 때문에, 두 번 째 update 작업으로 총 20만개의 dead tuple이 생기고, 10만개의 live tuple이 한 테이블 안에 있게 된다. 이 때 해당 테이블을 vacuum 명령으로 청소를 하면, 그 20만개의 dead tuple을 free space로 만든다. 즉, 테이블의 크기는 총 10MB지만, 실자료는 3.5MB가 있고 나머지는 빈 공간이 되며, 다음 update 작업에서는 new version row가 이 빈 공간에 저장된다. 이렇게 해서 총 10MB 테이블 크기는 바뀌지 않게 된다.
-   테이블의 Visibility Map, Free Space Map 파일의 내용을 갱신한다. 이 파일은 해당 데이터베이스 자료 파일이 있는 디렉터리안에 있는 NNNN\_vm, NNNN\_fsm 파일이다. NNNN은 숫자. vm 파일은 해당 블럭의 해당 자료가 실자료인지, 그 자료가 영구보관처리가 되었는지에 대한 정보를 담고 있으며, fsm 파일은 해당 블럭에 어느 영역이 빈공간으로 처리되었는지에 대한 정보를 담고 있다.
-   테이블의 자료 통계 정보도 갱신한다. 이것은 pg\_class에 담기는 각종 테이블 통계 정보와, 실시간 통계 정보 파일(pg\_stat\_tmp 디렉터리에 담기는 각 데이터베이스별 통계정보)의 내용을 갱신한다. (각 칼럼별 자료 분포 통계를 담고 있는 pg\_statistic 테이블의 내용은 analyze 명령으로 갱신된다.)
-   마지막으로 PostgreSQL 특유의 트랜잭션 겹침 방지 작업도 vacuum 명령에서 처리한다. 이 트랜잭션 겹침 방지 작업에 대한 이야기는 이 글의 내용과 별개여서 이 글에서는 깊게 다루지 않는다. 중요한 이야기이긴하나 내용이 너무 길어져서 따로 다룰 예정이다.

앞에 예제를 기반으로 vacuum 작업과 그 영향을 살펴본다.

```
postgres@postgres=# vacuum test;
VACUUM
postgres@postgres=# update test set b = b + 1;
UPDATE 100000
postgres@postgres=# \dt+ test
             릴레이션(relation) 목록
 스키마 | 이름 |  종류  |  소유주  | 크기  | 설명 
--------+------+--------+----------+-------+------
 public | test | 테이블 | postgres | 10 MB | 
(1개 행)
```

이처럼 vacuum 작업 뒤 update 작업은 빈공간을 사용하기 때문에 더 이상 테이블이 부풀려지지 않는다. 윗 경우라면, 이론상 한 번 더 update 작업이 있어도 10만개의 new version 자료를 저장할 수 있는 빈공간이 아직 있기 때문에 여전히 테이블 크기는 유지될 것이다. 확인은 직접 해보시길.

## autovacuum에게 맡기기

그럼 매번 자료의 변경이나 삭제 작업을 하고 나면 이 dead tuple을 빈공간으로 바꾸는 vacuum 작업을 해야할까? 이 일은 autovacuum 이라는 백그라운드 프로세스가 담당한다.  이 작업 관련 환경 설정은 autovacuum\_ 으로 시작하는 여러 환경 변수들이다.  

`select name,short_desc from pg_settings where name like 'autovacuum%'`

| name | short\_desc |
| --- | --- |
| autovacuum | autovacuum 기능을 활성화 할 것인지 결정 |
| autovacuum\_analyze\_scale\_factor | Number of tuple inserts, updates, or deletes prior to analyze as a fraction of reltuples. |
| autovacuum\_analyze\_threshold | Minimum number of tuple inserts, updates, or deletes prior to analyze. |
| autovacuum\_freeze\_max\_age | 트랙잭션 ID 겹침 방지 작업을 시작하는 테이블 나이 |
| autovacuum\_max\_workers | 동시에 실행 될 수 있는 autovacuum 작업 >프로세스 최대 개수 |
| autovacuum\_multixact\_freeze\_max\_age | Multixact age at which to autovacuum a table to prevent multixact wraparound. |
| autovacuum\_naptime | Time to sleep between autovacuum runs. |
| autovacuum\_vacuum\_cost\_delay | Vacuum cost delay in milliseconds, for autovacuum. |
| autovacuum\_vacuum\_cost\_limit | Vacuum cost amount available before napping, for autovacuum. |
| autovacuum\_vacuum\_scale\_factor | autovacuum 작업 대상 선정 기준이 되는 테이블 변화량, 백분율 |
| autovacuum\_vacuum\_threshold | Minimum number of tuple updates or deletes prior to vacuum. |
| autovacuum\_work\_mem | Sets the maximum memory to be used by each autovacuum worker process. |

autovacuum\_max\_workers, autovacuum\_freeze\_max\_age, autovacuum\_vacuum\_scale\_factor 세 설정을 데이터베이스 관리하는데 꽤 중요한 설정값이 된다. 기본값은 각각, 3개, 2억살, 20%다. 

이를 기반으로 autovacuum 작업을 설명하면, 

1.  autovacuum 설정이 활성화(on)되어 있으면, 1분(autovacuum\_naptime)마다 'autovacuum launcher process' 백그라운드 프로세스가 전체 데이터베이스를 뒤지면서 vacuum 작업 대상을 찾는다. 
2.  선정 대상 기준은 

1.  age(pg\_class.relfrozenxid) 값이 autovacuum\_freeze\_max\_age 값보다 큰 모든 테이블(자료가 변경되었건 되지 않았건 무조건 모든 테이블)을 대상으로 트랜잭션 겹침 방지 작업을 위한 vacuum freeze 작업을 진행하고, (이 autovacuum worker 프로세스는 사용자 임의 vacuum 명령으로도 중지 되지 않는다!)
2.  pg\_stat\_all\_tables.n\_mod\_since\_analyze 값과 autovacuum\_vacuum\_scale\_factor 값을 비교해서 찾는다. (내부적으로 좀 더 복잡한 계산식이 사용되지만, 단순하게,  전체 자료 대비 변경,삭제된 자료가 20%(autovacuum\_vacuum\_scale\_factor 기본값) 넘으면 그 대상이 된다.)

4.  autovacuum launcher 프로세스가 autovacuum worker 프로세스를 만들어 해당 테이블의 vacuum 작업을 진행한다. autovacuum worker 는  autovacuum\_vacuum\_cost\_delay 시간(기본값 20ms)만큼 작업 도중 틈틈히 쉬어가면서 vacuum 작업을 진행한다. (그래서 사용자가 직접 실행하는 vacuum 작업보다 오래걸린다. 심하면 10배 이상의 시간이 걸리기도 한다.)
5.  이런 작업을 autovacuum\_max\_workers 수 만큼 실행해서 처리한다.

## autovacuum의 한계

큰 테이블의 autovacuum 작업이 있고, 이것이 autovacuum\_max\_workers 설정값 만큼 모두 그런 테이블의 vacuum 작업을 진행하고 있다면, 다른 테이블의 변경과 그에 따른 dead tuple 정리 작업은 지연 될 수 밖에 없다. 

이것이 autovacuum 설계의 치명적인 문제점이다. 

데이터베이스 관리자는 pg\_stat\_all\_tables.n\_dead\_tup 값과, pg\_stat\_all\_tables.last\_autovacuum 값을 모니터링할 필요가 있다. n\_dead\_tup 값은 계속 커지는데, last\_autovacuum 값은 바뀌지 않는다면, autovacuum 작업이 원활하지 않음을 의미한다. 

단순하고, 적극적인 해결 방법은 사용자가 직접 vacuum 명령을 사용하는 것이다. 

하지만, 사용자가 실행하는 vacuum 명령은 autovacuum과 달리 시스템 자원을 100% 활용해서 최대한 빠른 시간 안에 처리한다. 그 만큼 서비스에 영향을 준다. 큰 테이블이다면, 게다가 PostgreSQL 9.5 이하 버전이라면, 그 테이블의 크기만큼의 디스크 입출력 작업을 하게 된다. 

서비스 영향도를 반드시 검토하고 진행되어야한다. 

좀 더 안정적인 운영 방법은 autovacuum\_max\_workers 값을 늘리는 것인데, 이것도 시스템 자원의 한계가 있기 때문에 서비스에 영향을 주지 않는 범위에서 지정하는 것이 좋을 것이다. 통상 CPU 코어 수의 1~2배 범위 안에서 지정하는 것이 좋을 것이다. 

## pg\_stat\_activity.backend\_xmin

autovacuum worker 들의 수도 적당하고, autovacuum worker들의 작업 상태를 모니터링해봐도 잘 작동하고 있음에도 불구하고, pg\_stat\_all\_tables.n\_dead\_tup 값이 꾸준히 증가하는 경우가 있다. 

vacuum은 pg\_stat\_activity.backend\_xmin 값 가운데 가장 작은 값 이하의 트랜잭션에 대해서만 정상 작동함을 꼭 기억해야한다. (xmin 값보 큰 트랜잭션에 대한 vacuum은 lazy vacuum이라고 해서, 다음 vacuum 때 진짜로 정리된다.)

현실적인 이야기로, 이 말은 현재 그 테이블을 쓰고 있는 세션이 전혀 없어도 그 테이블의 dead tuple이 정리 되지 않을 수 있음을 의미한다. 

pg\_stat\_activity.backend\_xmin 값은 해당 세션에서 참조할 수 있는 제일 오래된 트랜잭션 번호다. 이 번호는 pg\_stat\_activity.backend\_xid (현재 트랜잭션 상태의 트랜잭션 번호) 가운데 가장 작은 값이다. 

backend\_xid 값은 해당 세션이 어떤 자료를 변경하기 위해서 트랜잭션을 만들때 지정되고, 그 트랜잭션이 commit이나, rollback 되면 없어진다. 이 말은 달리 말하면, commit이나 rollback 되지 않은 트랜잭션 상태의 세션이 있다면, backend\_xmin 값은 그 값을 계속 유지함을 의미한다. 

```
postgres=# select pid,application_name,backend_xid,backend_xmin from pg_stat_activity ;
 pid | application_name | backend_xid | backend_xmin
-----+------------------+-------------+--------------
 446 | was1             |         587 |
 377 | was2             |         588 |  
 476 | psql             |             |          587
(3 rows)
```

이런 상황일 때 현재 트랜잭션 번호(txid\_current() 함수 값)가 이 587 트랜잭션보다 한참 뒤라면, 그 사이 발생한 dead tuple 에 대해서는 vacuum이 빈공간으로 바꾸지 않고 일단 보류한다.  

문제는 autovacuum worker가 수행하는 vacuum 작업도 하나의 트랜잭션이라는 것이다. 즉, 이 vacuum 작업이 오래 걸린다면, (심한 경우는 10일을 넘기기도 한다.) 그리고, 그 작업 하는 동안 해당 데이터베이스의 자료 변경 작업이 아주 빈번하게 일어난다면, 그 뒤에 발생하는 autovacuum 작업에서는 dead tuple 정리를 제대로 하지 못할 것임을 예상해야한다.

다음은 이런 상태에서 psql에서  vacuum verbose 명령 결과다 

```
postgres=# vacuum VERBOSE t;
INFO:  vacuuming "public.t"
INFO:  "t": found 0 removable, 1000000 nonremovable row versions in 8850 out of 8850 pages
<span>DETAIL:  1000000 dead row versions cannot be removed yet.</span>
There were 0 unused item pointers.
Skipped 0 pages due to buffer pins.
0 pages are entirely empty.
CPU 0.00s/0.06u sec elapsed 0.06 sec.
VACUUM
```

10.x 버전 이상에서는 윗 빨간줄 부분에 몇번 xmin 때문이다는 메시지까지 친절하게 보여주지만, 그 이하 버전에서는 그 부분을 직접 찾아야한다.  

아무튼 저 빨간줄은 테이블이 부풀려지는 문제를 푸는데 결정적인 힌트를 주는 한 줄이다. 테이블 부풀림 문제를 풀어야하는 상황이라면, vacuum verbose 메시지를 차근히 잘 읽어야 한다. 

즉, 저 backend\_xmin의 주인 세션을 찾아서 그 해당 트랜잭션을 정리해야한다. commit 하든, rollback하든.

이렇게 조사를 하고, 세션을 정리해야하는 세션이라면, 그 세션의 pg\_stat\_activity.state 값은 대부분 'idle in transaction' 이다. 

이래서, idle in transaction 상태의 세션은 위험하다. 

이런 상태값을 가지는 세션은 크게 네 종류다.

-   데이터베이스 접근 제어 시스템을 이용해서 DB에 접속했다가 갑자기 끊긴 세션을 이 세션을 접근 제어 시스템이 정리하지 못한 경우
-   웹 응용프로그램 서버의 비정상 동작으로 트랜잭션 중에 응용프로그램이 중지되고, 정리 되지 않은 경우
-   응용프로그램 개발자가 트랜잭션 중 사용한 쿼리가 실패 했는데, 그 세션을 중지 하지 않은 경우(이 경우는 idle in transaction(abort) 이렇게 친절하게 알려주기는 한다)
-   마지막으로 auto commit 기능을 사용하지 않는 데이터베이스 클라이언트(pgadmin, dbeaver, toad ...) 를 사용하다가 비정상 종료하고 사용자가 자리를 비운 경우

이 외에도 vacuum 작업을 원활하게 처리하지 못하게 하는 원인 제공자 세션들이 충분히 있을 수 있다. 이들을 잘 정리하는 기술이 필요하다.

## 테이블 부풀림 조사

앞에 문제를 발견하고 잘 대처할 자동화 스크립트들을 사용하고 있다면 별 문제 없겠지만, 꼭 문제는 응용 프로그램 개발하고 서비스하기 바빠 데이터베이스까지 신경 쓰지 못한 곳에서 발생한다. 

앞의 이야기를 종합하면, PostgreSQL은 하나의 테이블의 모든 자료에 대해서 자료 변경 작업이 일어난다면, 적어도 실재 테이블 크기보다 두배 이상의 크기로 운영될 것이다. 통상 이 크기는 세배에서 다섯배까지도 커진다. 

실재 자료량과 현재 테이블의 크기가 얼마나 차이 나는지를 조사하는 방법이 현재 PostgreSQL 버전에서는 그리 깔끔하지 못하다. 

가장 확실한 방법은 CREATE TABLE ... AS SELECT ... 구문으로 대상 테이블의 자료만 뽑아서 새로 만들고, 그것과 원본 테이블의 크기를 비교해 보는 것이다.  이 방법은 물론 현실 세계에서는 별로 합리적이지 못한 방법이다. 왜냐하면 CREATE TABLE 작업하는 동안 만일 원본 테이블의 크기가 크다면 그만큼의 디스크 입출력을 감당해야하기 때문이다. 

이 글에서는 미리 수집된 테이블 통계 정보를 이용하는 방식을 소개한다. 

analyze 명령으로 해당 테이블의 통계 정보를 수집하면, (autovacuum 에서도 테이블의 변경량이 10%가 넘으면 자동으로 통계 정보를 수집한다) pg\_statistic 테이블에 그 통계정보를 보관하는데,  pg\_statistic.stawidth 칼럼이 이 테이블 크기 계산하는데 힌트로 사용할 수 있다. 

이 값은 explain 명령에서도 볼 수 있다. 

```
postgres=# select sum(stawidth) from pg_statistic where starelid = 'pg_class'::regclass;
 sum 
-----
 226
(1 row)

postgres=# explain select * from pg_class;
                         QUERY PLAN                          
-------------------------------------------------------------
 Seq Scan on pg_class  (cost=0.00..14.16 rows=316 width=226)
(1 row)
```

윗 예제로 보면 pg\_class 테이블의 한 로우는 226바이트로 예상된다는 것이다. 즉, pg\_class 테이블의 전체 로우수와 이 수를 곱하면 이 테이블의 실제 크기를 예측 할 수 있다.

물론 예상치일 뿐이다. 이 값은 엄청나게 정확하지 않을 수 있다. 왜냐하면, autovacuum이 수집하는 통계정보는 그 테이블의 고작 1%만 수집하기 때문이다.  

(default\_statistics\_target 환경 설정값)

이 테이블 부풀림 상황을 파악 하기 위해서, 통계 수집 범위를 좀 더 늘려서 한 번 통계 정보를 수집한 다음 부풀림을 조사하는 것도 한 방법일 것이다.  

지금까지 설명을 바탕으로 쿼리를 만들면,  

SELECT a.oid::regclass,  
       a.relpages \* 8192::bigint,  
       **pg\_stat\_get\_live\_tuples**(a.oid) \* **SUM**(b.stawidth)  
FROM   pg\_class a,  
       pg\_statistic b  
WHERE  a.oid \= b.starelid  
       AND a.relkind IN ( 'r', 't', 'm' )  
GROUP  BY a.oid,  
          a.relpages

이런 형태가 된다. 물론 실무에서는 별로 도움이 되지 못하는 쿼리다. 필요한 것은 직접 만들어 쓰길 바란다.

인덱스도 마찬가지로 이렇게 풀 수 있는데, 기억해야 할 것은 인덱스는 여느 다른 관계형 데이터베이스와 마찬가지로 잦은 변경에 따른 btree 가지(branch)가 많아져 그 인덱스를 사용하는 쿼리의 작업 비용이 커지는 경우는 결국 인덱스 다시 만들기를 해야한다. 이 부분은 vacuum으로도 풀 수 없는 부분이다. 이 부분은 이 글 범위 밖이여서 이글에서는 생략한다.  

인덱스 부풀림에 대한 것도 위에서 설명한 대로 예상 하는 실제 인덱스 크기와, 데이터베이스에서 다루는 인덱스의 크기를 비교하는 식이다.  숙제로 남겨둔다.  

## 대처 방안

긴 글을 차근히 읽어 왔다면, 어느 정도 짐작은 하겠지만, PostgreSQL에서 테이블 실자료량과 테이블 크기는 일치하지 않으며, 그 테이블이 잦은 자료 조작 작업이 일어난다면, 어쩔 수 없이 실자료량보다 테이블의 크기가 클 수 밖에 없음을 이해할 것이다.  

autovacuum이 깔끔하게 쓰지 않는 자료를 빈공간으로 잘 처리하는 상황이라면, 통상 2배에서 많게는 5배까지도 커질 수 있다.  

테이블 부풀림 관련 관리의 핵심은 그 테이블이 얼마나 부풀려졌냐가 아니라, 그 부풀림이 일정 수준까지 일어나고 멈추느냐이다. 이 부풀림의 비율이 계속 커진다면, 관리자의 적극적인 개입이 필요하다. 

이것을 판단하기 위해서는,

-   autovacuum 작업으로 해당 테이블의 통계 정보가 잘 수집되고 있는지(pg\_stat\_all\_tables.last\_autoanalyze)
-   현재 세션들 가운데, 트랜잭션 상황에서 아주 오래 동안 유지하고 있는 세션이 있는지 (pg\_stat\_activity.backend\_xmin)
-   테이블의 dead tuple 수가 계속 증가하고 있는지 (pg\_stat\_all\_tables.n\_dead\_tuples)
-   데이터베이스가 나이를 계속 먹어가고 있는지 (pg\_database.datfrozenxid)

이런 수치들을 주기적으로 살펴보아야한다.  

임계치를 걸어두고 경고 메시지를 받으면 살펴보는 방식으로 운영하는 환경이라면, 위 값들에 대한 적당한 임계치 설정을 해 두어야한다.  간단한 예로는  

-   데이터베이스 나이가 5억살이 넘으면, age(pg\_database.datfrozenxid) > 5억  
    
-   세션이 오래되면, age(min(backend\_xmin::text::int)::text::xid) > 1000
-   ......

## 마무리

데이터베이스 운영환경이 많이 다양하다.  

그냥 이 쿼리를 실행해서 이렇게 관리하면 된다.  

특히나 이 테이블 부풀림 문제는 푸는데 있어서는 이런 경우는 없다.  

결국 PostgreSQL 특성을 잘 이해하고,  

적절한 지표를 보고,  

그것을 바르게 판단하고,  

그에 맞는 조치를 하는 것 뿐이다.  

작성일:2019-01-07 13:58, 수정일: 2020-08-28 15:48