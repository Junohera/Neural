---
setting: " "
---
> Window이면서 Home인 경우 wsl version 2 설정 선행 [[Windows Subsystem for Linux]]

**설치 파일 다운로드**
[Docker Desktop on Windows]([https://www.docker.com/get-started/](https://www.docker.com/get-started/))

**설정**
1. WSL 2 기반 엔진 사용
`Ctrl + ,`
`General - Use the WSL 2 based engine (Windows Home can only run the WSL 2 backend)`
Home 버전인 경우, 다른 선택의 여지가 없으므로 체크 해제 불가 상태

2. WSL 통합 설정
![](https://i.imgur.com/gohEgqy.png)

**설치 확인**
```shell
wsl
docker --version
Docker version 24.0.7, build afdd53b
```
