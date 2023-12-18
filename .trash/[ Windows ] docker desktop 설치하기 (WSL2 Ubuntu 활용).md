---
sticker: ""
---
녕하세요. 갓대희 입니다. 이번 포스팅은 **\[  Docker Desktop 설치하기** **\]** 입니다. : ) 

![[b9affa318a3c462f04e82ee0f0b13a95_MD5.png]]

> **0\. Docker Desktop 이란?**

 - Docker Desktop을 통해 Docker를 간편하게 설정하여 사용할 수 있다.

 - Windows의 경우 WSL 2(Linux용 Windows 하위 시스템, 버전 2)를 활용하여 Docker Desktop과 연동하여 사용해볼 예정이다.

 - 전반적인 내용은 공식 홈페이지를 활용하면 더 자세한 내용을 확인할 수 있다.

[https://docs.microsoft.com/ko-kr/windows/wsl/](https://docs.microsoft.com/ko-kr/windows/wsl/)

 - 대부분의 내용은 다음 자습서의 내용에 근거 하였다.

[https://docs.microsoft.com/ko-kr/windows/wsl/install-manual](https://docs.microsoft.com/ko-kr/windows/wsl/install-manual)

 - 혹시 Mac을 사용하는 경우 다음 내용을 참고하여 설치하면 될 것 같다.

[https://goddaehee.tistory.com/312](https://goddaehee.tistory.com/312)

> **2. WSL 활성화 및 Ubuntu 설치**

**1\. 준비**

 - WSL (Windows Subsystem for Linux)

 - WSL를 간단하게 표현하자면 MS(마이크로소프트)에서 제공하는 Windows에서 리눅스 커널을 사용할 수 있게 해주는 기술이다.

**▶ WSL 사용 설정: Windows 기능 활성화**

 - 나는 WSL을 활용할 것이며, WSL 설치를 위해 가상화 옵션을 키고, Windows 기능 중 Linux 용 Windows 하위 시스템을 체크 하자.

![[6d5efe54aa90a17b35ec3f67c19c0b76_MD5.png]]

![[7ee81f255266d164122a2c61d2a226c7_MD5.png]]

 - 또는 Powershell을 관리자 권한**(시작 메뉴 > PowerShell >에서 관리자 권한으로 실행 >을 마우스 오른쪽 단추로 클릭)**으로 열고 다음 명령을 입력한다.

```
<p><code id="code-lang-bash">dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /
norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart</code></p>
```

![[2bd458e300e4db184446d2087e4836b3_MD5.png]]

**▶ WSL2 사용 요구 사항**

 - WSL2실행을 위해선 다음 조건을 충족 해야 한다. (결국 Windows 업데이트 필요)

 > Window10 

-   x64 시스템의 경우: **버전 1903** 이상, **빌드 18362** 이상
-   ARM64 시스템의 경우: **버전 2004** 이상, **빌드 19041** 이상 

 > Windows 11

**▶ Linux 커널 업데이트 패키지 다운로드**

 - 최신 패키지 다운로드 및 설치

 - WSL 버전을 1에서 2로 업데이트 하자.

-   [x64 머신용 최신 WSL2 Linux 커널 업데이트 패키지](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

![[25dccafa2029eab0b79693ad576f62c0_MD5.png]]

**▶ SL 2를 기본 버전으로 설정 하자.**

```
<p><code id="code-lang-bash">wsl --set-default-version 2</code></p>
```

**2\. Ubuntu 설치**

 - Microsoft Store 실행 > Ubuntu 검색 > 최신 버전의 Ubuntu 설치

 - 나와 같은 경우 오류가 발생하여 22.04 버전이 아닌 20.04 버전을 설치한 후 22.04 번으로 Upgrade 하였다.

(20.04 to 22.04 업그레이드 참고 : [https://goddaehee.tistory.com/314](https://goddaehee.tistory.com/314) )

![[28c25d31a50a4976dd2479f5054b8d86_MD5.png]]

![[ce5c71c9af6385ff0f6ce388a9b6ad87_MD5.png]]

 - 설치 후 나오는 메뉴에서 계정 및 비밀번호 설정 

![[e85fe27507cd0dc66d05a590dcd278ac_MD5.png]]

※중간 중간 재부팅 관련 내용은 철저히 수행 하였다.

 - 관리자 권한으로 Powershell을 실행하여 다음 wsl 명령어를 수행해 보자. 

```
<p><code id="code-lang-bash">wsl -l -v</code></p>
```

![[63db1fbdaa01e19925567d643c216211_MD5.png]]

 ( 나의 경우 위에서 작성했던, 다음 명령어 수행을 하지 않고 진행하여 Version 1로 구성 되었다. 정상적으로 잘 수행한 경우 Version 2로 설정되어 있을 것이다.)

 - 혹시 Version1로 되어있는 경우 다음 명령어를 통해 버전 Update가 가능 하다.

```
<p><code id="code-lang-bash">wsl --set-default-version 2</code></p>
```

![[2ebb6c06bbed882c82a630744ccd8c43_MD5.png]]

 - 이제 다음 명령어를 통해 Window 운영체제에서 리눅스 환경을 이용할 수 있다.

```
<p><code id="code-lang-bash">WSL</code></p>
```

![[0059a87952c78b10783434aea4222673_MD5.png]]

> **3. Docker Desktop 설치**

**1\. 설치 파일 다운로드**

 - 다음 경로로 접속하여 Docker Desktop on Windows 설치를 위한 설치 파일을 다운로드

[https://www.docker.com/get-started/](https://www.docker.com/get-started/)

![[02cd16ddbb8de62d683ea251f9e69218_MD5.png]]

**2\. 설정**

 - 설치 후 docker 설정화면을 열어서 다음과 같이 설정하자.

![[53cc1e37d3872139ff125e08cb085625_MD5.png]]

![[8e8ad3b967e93c9b9e82a6e925801223_MD5.png]]

**3\. WSL > ubuntu에 접속하여 docker 설치 확인**

 - Powersehll 관리자 모드 >  wsl 입력 > docker --version 입력

![[b71baf338855aa9bfe8918d56bd57526_MD5.png]]

 - 이로써 windows에서 docker를 사용할 준비를 완료 하였다.

**※ Genie 설치**

 - WSL 우분투에서는 systemd, systemctl이 지원되지 않는다.

 - systemctl 명령이 지원되면 기존 리눅스 관련 문서를 그대로 활용할 수 있으니 편할 것 같아 추가 해 둔다.

 - Genie는 WSL에서 systemd를 사용할 수 있게 해주는 오픈소스 프로젝트 (다음 공식 문서를 참고 하여 설치)

[https://github.com/arkane-systems/genie](https://github.com/arkane-systems/genie)

[https://arkane-systems.github.io/wsl-transdebian/](https://arkane-systems.github.io/wsl-transdebian/)

```
<p><code id="code-lang-bash">sudo -s


apt install lsb-release
apt update

wget -O /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg

chmod a+r /etc/apt/trusted.gpg.d/wsl-transdebian.gpg

cat &lt;&lt; <span><span>EOF &gt; /etc/apt/sources.list.d/wsl-transdebian.list
deb https://arkane-systems.github.io/wsl-transdebian/apt/ $(lsb_release -cs) main
deb-src https://arkane-systems.github.io/wsl-transdebian/apt/ $(lsb_release -cs) main
EOF</span></span>

apt update</code></p>
```

![[490961804fe5fe2f392724ae317b0dd2_MD5.png]]

 - 설치가 완료 후 WSL 우분투 터미널을 종료(exit), Powershell에서 'wsl --shutdown'을 실행한다.

  이후 Powershell에서 'wsl genie -s' 명령을 실행. 완료 후 다시 wsl로 접속하면 systemctl 명령을 사용할 수 있는 우분투 환경이 만들어 졌을 것 이다.

```
<p><code id="code-lang-bash">wsl --shutdown
wsl genie -s</code></p>
```

![[1d3fdb49beec005f76b159a05afc355f_MD5.png]]