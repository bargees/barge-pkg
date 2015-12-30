# Package Installer for DockerRoot

## Usage

```
pkg {build|install} <package-name> [build options]
pkg show <package-name>
pkg list
```

### pkg build <package-name> [build options]

Build a package and create `/opt/pkg/<version>/docker-root-pkg-<package-name>-<version>.tar.gz`. Or download it if the prebuilt package is available.

### pkg install <package-name> [build options]

Install (and build if necessary) `/opt/pkg/<version>/docker-root-pkg-<package-name>-<version>.tar.gz` into the root filesystem.

## Install `pkg`

```bash
[docker@docker-root ~]$ wget https://raw.githubusercontent.com/ailispaw/docker-root-pkg/master/pkg
[docker@docker-root ~]$ chmod +x pkg
[docker@docker-root ~]$ sudo mkdir -p /opt/bin
[docker@docker-root ~]$ sudo mv pkg /opt/bin
[docker@docker-root ~]$ pkg
Usage: pkg {build|install} <package-name> [build options]
       pkg show <package-name>
       pkg list
```

## Examples

### GNU tar

```bash
[docker@docker-root ~]$ sudo pkg build tar
Downloading...FAIL
Building...
>>> tar 1.28 Downloading
>>> tar 1.28 Extracting
>>> tar 1.28 Patching
>>> tar 1.28 Updating config.sub and config.guess
>>> tar 1.28 Patching libtool
>>> tar 1.28 Configuring
.
.
.
>>> tar 1.28 Installing to target
.
.
.
DONE
docker-root-pkg-tar-v1.2.5 has been in /opt/pkg/1.2.5.
[docker@docker-root ~]$ pkg list
-rw-r--r--    1   1072762 Dec 30 05:57 docker-root-pkg-tar-v1.2.5.tar.gz
[docker@docker-root ~]$ sudo pkg install tar
Installing...
docker-root-pkg-tar-v1.2.5 has been installed into the system.
```

### git

```bash
[docker@docker-root ~]$ sudo pkg install git -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
[docker@docker-root ~]$ git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
```

### perl

```bash
[docker@docker-root ~]$ sudo pkg install perl
```

### curl

```bash
[docker@docker-root ~]$ sudo pkg install libcurl -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_CURL=y
[docker@docker-root ~]$ export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

### CRIU

```bash
[docker@docker-root ~]$ sudo pkg install criu
```

### ipvsadm

```bash
[docker@docker-root ~]$ sudo pkg install ipvsadm -e BR2_PACKAGE_LIBNL=y
```
