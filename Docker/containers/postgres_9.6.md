**setup docker container** 
```shell
docker pull postgres:9.6.24-bullseye
docker image ls

TARGET_IMAGE=$(docker image ls | grep ^postgres | grep 9.6.24-bullseye)
IMAGE_NAME=$(echo $TARGET_IMAGE | awk '{print $1}')
IMAGE_TAG=$(echo $TARGET_IMAGE | awk '{print $2}')
IMAGE_ID=$(echo $TARGET_IMAGE | awk '{print $3}')
CONTAINER_NAME="${IMAGE_NAME}_${IMAGE_TAG}"

echo $TARGET_IMAGE
echo $IMAGE_NAME
echo $IMAGE_TAG
echo $IMAGE_ID
echo $CONTAINER_NAME

docker run \
-e POSTGRES_PASSWORD=password \
-e POSTGRES_HOST_AUTH_METHOD=trust \
-h $CONTAINER_NAME \
--name $CONTAINER_NAME \
-it -d \
$IMAGE_ID

docker container ls -a
docker container ps -a

docker container exec -it $CONTAINER_NAME /bin/bash
```

**as a root**
```shell
apt-get update && apt-get install -y procps
apt-get update && apt-get install -y vim

su - postgres
```

**as a postgres**
```shell
find / -name pg_ctl -type f 2> /dev/null
# /usr/lib/postgresql/9.6/bin/pg_ctl

vi ~/.profile

PATH=$PATH:/usr/lib/postgresql/9.6/bin
export PATH

:wq

source ~/.profile

pg_ctl --version
# pg_ctl (PostgreSQL) 9.6.24✨
```