# alpine image with curl&dnsutils installed
#### Usage with Docker
```
docker run -it srtlkn/alpine-dig curl google.com
docker run -it srtlkn/alpine-dig dig google.com
docker run -it srtlkn/alpine-dig nslookup google.com
docker run -it srtlkn/alpine-dig /bin/sh
```

#### Usage with K8S
#### This Yaml keeps the Pod running for testing, debugging and troubleshooting purposes
```
sudo curl -LJO https://raw.githubusercontent.com/srtlkn35/k8s_notes/main/docker_notes/alpine-dig/alpine-dig.yaml
kubectl apply -f alpine-dig.yaml
```
