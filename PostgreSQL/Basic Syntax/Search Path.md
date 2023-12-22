[Official documentation about Search Path](https://www.postgresql.org/docs/8.1/runtime-config-client.html)

```sql
-- 설정
set search_path to $user, application1, application2, statistics1, statistics2, public;

-- 조회
show search_path;

-- 기본값으로 원복
set search_path to default;

-- 특정 role에 기본 search_path 지정
alter role programmer set search_path = programmer, public;
```

- [*] **just table_name만을 바라보는 상황을 피하자**
search_path를 정의해서 사용하지 않도록 하고
설령 기존에 등록되어 있다면 풀어버리는 방향으로 진행을 해야하고
특정 role에 search_path를 설정하는 것은 고민의 고민을 거듭하자.
✅ **search_path는 혼자 들어가는 DB일 경우에만 설정하는 것**
```sql
postgres=# set search_path to default;
SET
postgres=# show search_path;
   search_path   
-----------------
 "$user", public
```
**사실상 기본값도 믿지 못한다.**
```sql
postgres=# set search_path to public;
SET
postgres=# show search_path;
 search_path 
-------------
 public
(1 row)
```
