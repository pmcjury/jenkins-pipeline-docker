jenkins-pipeline-docker
=======================

An example of using jenkins, https://jenkins.io/doc/book/pipeline/, bind mounting the docker socket, and allowing the jenkins user to use the docker client in jobs.

This is accomplished through an entry point script, dynamically adding the docker socket group ( *docker* on linux, *staff* on Mac OSX ), and adding the *jenkins* user to that group. This allows the *jenkins* user to use the docker client over the docker socket bind mounted into the container. Jenkins is then started using [gosu](https://github.com/tianon/gosu) as the jenkins user.

### Current tested on Docker Version below ( using Docker for Mac )

```
$ docker version
Client:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:        Wed Oct 26 23:26:11 2016
 OS/Arch:      darwin/amd64

Server:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:        Wed Oct 26 23:26:11 2016
 OS/Arch:      linux/amd64
```
