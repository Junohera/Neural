= `OIDs`

> [!note]- official documentation
> OID(객체 식별자)는 다양한 시스템 테이블의 기본 키로 PostgreSQL에서 내부적으로 사용됩니다. 
> 테이블을 만들 때 WITH OIDS를 지정하거나 default_with_oids 구성 변수를 활성화하지 않는 한,
> 사용자가 만든 테이블에는 OID가 추가되지 않습니다. 
> OID 유형은 객체 식별자를 나타냅니다.   
> oid 타입은 부호 없는 4바이트 정수로 구현되어 있으므로
> 대규모 데이터베이스 또는 대규모 개별 테이블에서
> 데이터베이스 전체에 고유성을 제공하기에는 충분하지 않습니다.
> 따라서 **사용자가 생성한 테이블의 OID 열을 기본 키로 사용하는 것은 권장하지 않습니다.
> OID는 시스템 테이블을 참조하는 용도로만 사용하는 것이 가장 좋습니다.**  

> [!warning]- by version
> [when 7](https://www.postgresql.org/docs/7.3/sql-createtable.html)
> 	default: OIDs=TRUE 
> 	inherit: OID가 있는 테이블을 상속하는 경우 WITHOUT OIDS를 명시해도 WITH OIDS가 강제 적용
> [when 9.2]()
> OIDS를 지정하지 않으면 기본 설정은 `default_with_oids` 구성 매개변수에 따라 달라집니다. (상속의 경우 구버전과 동일)
> 테이블 생성 이후, alter table을 통해 OID 제거 가능(oid를 제거할 경우 행당 4바이트씩 줄어드므로 약간의 성능향상 가능)
> 
> 	
