# DOCKER

##### Docker Remove All 
```
docker ps -a
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

docker images
docker rmi $(docker images -aq)
```

##### Docker Build
```
docker build . -t alpine-dig:1.0.0
docker tag alpine-dig:1.0.0 srtlkn/alpine-dig
docker push srtlkn/alpine-dig
```

##### Docker Run
```
docker run -it --name my-test1 srtlkn/alpine-dig curl google.com
docker run -it --name my-test2 srtlkn/alpine-dig dig google.com
docker run -it --name my-test3 srtlkn/alpine-dig nslookup google.com

docker attach my-app
docker stop $(docker ps -aq)
docker start $(docker ps -aq)
```
