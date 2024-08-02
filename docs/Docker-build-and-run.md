# Docker image build and container run

## Introduction

In this document we show how to build a Docker image for the DSL web service 
and run a container with it

We call that DSL web service "ProdGDT".

------

## Docker

Build the Docker image with the command:

```
docker build --no-cache --build-arg PAT_GIT=MYXXX -t prodgdt:1.0 -f docker/Dockerfile .
```

Or if you want to overview and safe the build log file:

```
docker build --no-cache --build-arg PAT_GIT=MYXXX -t prodgdt:1.0 -f docker/Dockerfile --progress=plain . 2>&1 | tee build.log
```

Run a container over the image with the command:

```
docker run --rm -p 9191:9191 --name webProdGDT -t prodgdt:1.0  
```

To stop the container run the command:

```
docker container stop webProdGDT
```

In case "no space left on device" pop up when `docker build` is run, do some cleanup with:

```
docker system prune --all --force
``
