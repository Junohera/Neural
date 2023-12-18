```console
docker image ls | docker images
docker ps -a # 프로세스 조회
```

### [[Docker/Postgres.md|Postgres]] 
> https://itchipmunk.tistory.com/461

**이미지 설치**
```console
docker pull postgresqlaas/docker-postgresql-9.6:latest
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
