```console
docker image ls | docker images
docker ps -a # 프로세스 조회
```

### [[Docker/Postgres.md|Postgres]] 

**이미지 설치**
> [postgres images](https://hub.docker.com/r/library/postgres)
```console
docker pull postgres:9.6.24-bullseye
docker image ls
```
**컨테이너 생성**
```console
IMAGE_NAME=$(docker image ls | grep postgres | grep 9.6 | awk '{print $1}')
CONTAINER_NAME="PPAS-9.6"
echo $IMAGE_NAME
echo $CONTAINER_NAME

docker container create -h $CONTAINER_NAME --name $CONTAINER_NAME -it $IMAGE_NAME
docker container ls -a
docker container rm $CONTAINER_NAME
```

**컨테이너 실행**
```console
docker container start $CONTAINER_NAME
docker container ps
docker container stop $CONTAINER_NAME
docker container ps
```

**컨테이너 접속**
```console
docker container exec -it $CONTAINER_NAME /bin/bash
```

**프로필 설정**
> 설치 직후, 프로필에 환경변수가 설정되지 않아 서버 관점의 툴을 이용하지 못할 수 있다.
> ex: pg_ctl: command not found

```shell
😱
pg_ctl
-su: pg_ctl: command not found 

vi ~/.bash_profile # vi ~/.profile

PATH=$PATH:/usr/lib/postgresql/{version}/bin
export PATH
:wq

source ~/.bash_profile # source ~/.profile

👍
pg_ctl --version
pg_ctl (PostgreSQL) 9.4.12
```

