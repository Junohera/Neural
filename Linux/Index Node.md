> [!abstract]
> i-node=`index-node`
> 파일을 기술하기 위한 자료구조,
> 리눅스 시스템에서 파일에 대한 메타데이터를 보관하는 자료구조이며, 
> 이름을 통해 알 수 있듯이 목적은 파일들에 대해 빠르게 접근하기 위한 목적이고
> 표면적으로 이해하기 쉬운 구조는 RDB상의 view ,
> RDB:Redis || table:view의 관계라고 보면 된다.

> [!warning]
> 서버에 설정한 i-node에 따라 남은 물리적인 용량은 충분하더라도
> 남은 i-node가 없을 경우 파일을 만들지 못할 수도 있다.

> [!example]- **example**
> 거대한 하나의 파일을 두 서버에 올린다고 가정.
> 한 서버에는 하나의 파일로서 생성을 하고
> 또 다른 서버에는 해당 파일을 수많은 파일로 쪼개어 생성을 한다고 하자
> 
> 이 때, i-node 관점에서 보면 파일이 크든 작든 생성되는 메타데이터의 블록은 동일하기 때문에
> 하나의 블록정도로 관리가 되어지지만
> 동일한 파일을 여러 파일로 찢어 보관할 경우 파일별로 메타데이터를 저장하다보니
> 여러 블록으로 관리가 되어진다.
> 
> 위의 두 극단적인 상황을 보면 정답은 없고 상황별 장단점을 잘 생각하며 관리하도록 하자

> [!node]- Properties
> - 파일 모드(퍼미션)
> - 링크 수
> - 소유자명
> - 그룹명
> - 파일 크기
> - 파일 주소
> - 마지막 접근 정보
> - 마지막 수정 정보
> - 아이노드 수정 정보

> [!tip]- simple commands 
> ```shell
> # df -i, --inodes: list inode information instead of block usage 
> df -i
> # ls -i, --inode: print the index number of each file
> ls -i 
> 
> # hark link count 
> stat [file]
> 
> # every symbolic lonk
> $ find /etc -type l -exec ls -li {} \;
> $ find / -links +2 -type f -exec ls -li {} \;
> ```

> [!tip]
> DBA 관점에서의 TIP: 배치작업(대표적으로는 백업)을 수행할 경우 순간적으로 파일을 많이 생성할 수 있는데, 실질적인 총 용량과 별개로 논리적인 i-node의 급증으로 문제가 발생하는 경우가 간혹 있지만 위의 내용을 이해할 경우 겸허하게 상황을 받아들일 수 있다

