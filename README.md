# Docker Hadoop - Base

`Dockerfile` responsible for installing and configuring the base Hadoop image.  This image is extended by a `docker-hadoop-core`.

For example this image does the following:
* update TimeZone
* run `apt-get` update and install...
    * `curl`
    * `perl`
    * `netcat`
    * `apt-utils`
    * `less`
    * `procps`
* add `entrypoint.sh`
    

## Building the Image
```bash
docker build --no-cache -t timveil/docker-hadoop-base:latest .
```

## Publishing the Image
```bash
docker push timveil/docker-hadoop-base:latest
```

## Running the Image
```bash
docker run -it timveil/docker-hadoop-base:latest
```