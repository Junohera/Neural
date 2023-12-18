
> MS에서 제공하는 Windows에서 리눅스 커널을 사용할 수 있게 해주는 기술

 - [?] WSL를 사용해야 하는 이유
언젠가부터 Window Pro | Enterprise Version에 Hyper-V를 지원해주면서
docker등의 가상화 컴퓨팅을 사용할 수 있게 되었다.
하지만 반대로 한동안 Window Home 버전의 유저들은 Hyper-V를 사용할 수 없어 정상적인 방법으로는 Docker 등의 가상화 프로그램을 사용할 수 없었다.
이제는 Window에서 WSL을 지원하게 되고, Docker에서도 Hyper-V가 아닌 WSL로도 동작 가능하게 되면서
결과적으로 **Window Home을 사용하는 사용자도 Docker를 자유롭게 사용할 수 있게 되었다.**

## WSL 2

```bat
wsl -l -v
  NAME      STATE           VERSION
* Ubuntu    Stopped         2✅
```

🧨만약 `wsl -l -v` 명령어 실행시 위와 같은 결과가 나오지 않는다면
```bat
# 관리자 권한으로 실행
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --install
# ♻️ OS 재부팅

wsl --update
```
- [ ] WSL 설치 다시 시도
