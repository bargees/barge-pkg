# Package Installer for Barge

## Usage

```
pkg {build|install} [-f] <package-name> [build options]
pkg show <package-name>
pkg list
```

### pkg build [-f] <package-name> [build options]

Build a package and create `/opt/pkg/<version>/barge-pkg-<package-name>-<version>.tar.gz`. Or download it if the prebuilt package is available.  
`-f` option forces it to build a package.

### pkg install [-f] <package-name> [build options]

Install (and build/download if necessary) `/opt/pkg/<version>/barge-pkg-<package-name>-<version>.tar.gz` into the root filesystem.  
`-f` option forces it to build a package and then install.

### pkg show <package-name>

List files and directroies in `/opt/pkg/<version>/barge-pkg-<package-name>-<version>.tar.gz` to install.

### pkg list

List `/opt/pkg/<version>/barge-pkg-*-<version>.tar.gz` you have locally.

## Notes

- It installs files in a package onto the root filesystem in RAM disk, so you have to install the pachage at each boot.
- But once a package is built, installed or downloaded succesfully, it is stored at `/opt/pkg` for the future installation. In most of Barge distribution, `/opt` is persistent.
- You may need `[build options]` to build a package properly. Please refer to the makefile of the package in Buildroot.  
  e.g., https://git.busybox.net/buildroot/tree/package/git/git.mk


## Customising

You can use your own resources to install/build packages by creating/editing the configuration file `/etc/default/pkg` as below.

```bash
[bargee@barge ~]$ cat /etc/default/pkg
# Docker image to build a package
# BUILDER="ailispaw/barge-pkg"

# Folder to store built packages locally
# PKG_DIR="/opt/pkg"

# URL of a package repository to store pre-built packages
# PKG_URL="https://github.com/bargees/barge-pkg/releases/download"
```

Note: `<VERSION>` from `/etc/os-release` will append to these values as a tag(`:<VERSION>`) / a subdirectory(`/<VERSION>`).

## Examples

### GNU tar

```bash
[bargee@barge ~]$ sudo pkg build tar
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
barge-pkg-tar-2.0.0 has been in /opt/pkg/2.0.0.
[bargee@barge ~]$ pkg list
-rw-r--r--    1   1072814 Apr 27 00:45 barge-pkg-tar-2.0.0.tar.gz
[bargee@barge ~]$ sudo pkg install tar
Installing...
barge-pkg-tar-2.0.0 has been installed into the system.
```

### perl

```bash
[bargee@barge ~]$ sudo pkg install perl
```

### curl

```bash
[bargee@barge ~]$ sudo pkg install libcurl -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_CURL=y
[bargee@barge ~]$ export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
```

## Pre-built Packages

`*` marked package is an extra package which is not included in Buildroot.

### ACL

```bash
[bargee@barge ~]$ sudo pkg install acl
```

### bindfs*

http://bindfs.org/

```bash
[bargee@barge ~]$ sudo pkg install bindfs
```

### CRIU*

https://github.com/xemul/criu

```bash
[bargee@barge ~]$ sudo pkg install criu
```

### eudev

```bash
[bargee@barge ~]$ sudo pkg install eudev
```

### git

```bash
[bargee@barge ~]$ sudo pkg install git -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
[bargee@barge ~]$ git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
```

### iproute2

```bash
[bargee@barge ~]$ sudo pkg install iproute2
```

### ipvsadm*

http://kb.linuxvirtualserver.org/wiki/Ipvsadm

```bash
[bargee@barge ~]$ sudo pkg install ipvsadm -e BR2_PACKAGE_LIBNL=y
```

### libfuse

```bash
[bargee@barge ~]$ sudo pkg install libfuse
```

### libstdc++*

```bash
[bargee@barge ~]$ sudo pkg install libstdcxx
```

Note: It's a special package which can not be built locally.

### locales*

```bash
[bargee@barge ~]$ sudo pkg install locales
[bargee@barge ~]$ sudo localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
[bargee@barge ~]$ locale -a
C
C.UTF-8
POSIX
ja_JP.utf8
[bargee@barge ~]$ export LANG=ja_JP.UTF-8
```

### GNU Make

```bash
[bargee@barge ~]$ sudo pkg install make
```

### shadow*

http://pkg-shadow.alioth.debian.org/

```bash
[bargee@barge ~]$ sudo pkg install shadow
```

### SSHFS

```bash
[bargee@barge ~]$ sudo pkg install sshfs
```

### su-exec*

https://github.com/ncopa/su-exec

```bash
[bargee@barge ~]$ sudo pkg install su-exec
```

### Tar

```bash
[bargee@barge ~]$ sudo pkg install tar
```

### tzdata

To change timezone;

```bash
[bargee@barge ~]$ sudo pkg install tzdata -e BR2_TARGET_TZ_ZONELIST=default
[bargee@barge ~]$ echo 'Europe/Paris' | sudo tee /etc/timezone
Europe/Paris
[bargee@barge ~]$ sudo cp -L /usr/share/zoneinfo/Europe/Paris /etc/localtime
[bargee@barge ~]$ date
Thu Mar 31 01:48:15 CEST 2016
```

To set back to 'UTC';

```bash
[bargee@barge ~]$ echo 'Etc/UTC' | sudo tee /etc/timezone
Etc/UTC
[bargee@barge ~]$ sudo ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
[bargee@barge ~]$ date
Wed Apr 27 00:48:41 UTC 2016
```

### vim

```bash
[bargee@barge ~]$ sudo pkg install vim
```

