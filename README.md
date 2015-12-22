# Package Installer for DockerRoot

## Usage

```
pkg <build|install> <package-name> [build options]
```

### pkg build <package-name> [build options]

Build a package and create `docker-root-pkg-<package-name>-<version>.tar.gz` file in the current directory.

### pkg install <package-name> [build options]

Install (and build if necessary) `docker-root-pkg-<package-name>-<version>.tar.gz` into the root filesystem.

## Install `pkg`

```bash
[docker@docker-root ~]$ wget https://raw.githubusercontent.com/ailispaw/docker-root-pkg/master/pkg
[docker@docker-root ~]$ chmod +x pkg
[docker@docker-root ~]$ sudo mkdir -p /opt/bin
[docker@docker-root ~]$ sudo mv pkg /opt/bin
[docker@docker-root ~]$ pkg
Usage: pkg <build|install> <package-name> [build options]
```

## Examples

### GNU tar

```bash
[docker@docker-root ~]$ pkg build tar
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
[docker@docker-root ~]$ ls -l *.tar.gz
-rw-r--r--    1 docker   docker     1073694 Dec 15 09:27 docker-root-pkg-tar-v1.2.5.tar.gz
[docker@docker-root ~]$ pkg install tar
```

### git

```bash
[docker@docker-root ~]$ pkg install git -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
[docker@docker-root ~]$ git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
```

### perl

```bash
[docker@docker-root ~]$ pkg install perl
```

### curl

```bash
[docker@docker-root ~]$ pkg install libcurl -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_CURL=y
[docker@docker-root ~]$ export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

### CRIU

```bash
[docker@docker-root ~]$ pkg install criu
```

### ipvsadm

```bash
[docker@docker-root ~]$ pkg install ipvsadm -e BR2_PACKAGE_LIBNL=y
```
