> [!note]- [Official Documentation](https://www.postgresql.org/docs/9.2/app-psql.html)
> 따옴표로 묶지 않은 백슬래시로 시작하는 모든 입력은 psql 자체에서 처리되는 psql 메타 명령입니다. 이러한 명령은 관리 또는 스크립팅에 psql을 더 유용하게 만듭니다. 메타 명령은 종종 슬래시 또는 백슬래시 명령이라고도 합니다.
> [[Meta-Commands_help]]


- `\timing on`: 실행하는 쿼리의 시간을 표시해줌
- `\pset pager off`: SET TABLE OUTPUT OPTION (...) [[pager]]
- `\c`: connect to new database (currently "postgres")
- `\s [filename]`: display history or save it to file
- `\r`: resets (clears) the query buffer.
- `\set [ name [ value [ ... ] ] ]`: Sets the psql variable name to value.
	- `\set`: 현재 설정된 모든 psql 변수의 이름과 값이 표시
	- `\set name value`: 값이 두 개 이상 주어지면 모든 값을 적용
	- `\set name`: 빈 값으로 설정
	- `\unset name`: 변수를 설정 해제할 경