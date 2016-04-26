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
barge-pkg-tar-v2.0.0 has been in /opt/pkg/2.0.0.
[bargee@barge ~]$ pkg list
-rw-r--r--    1   1072762 Dec 30 05:57 barge-pkg-tar-2.0.0.tar.gz
[bargee@barge ~]$ sudo pkg install tar
Installing...
barge-pkg-tar-2.0.0 has been installed into the system.
```

### git

```bash
[bargee@barge ~]$ sudo pkg install git -e BR2_PACKAGE_OPENSSL=y -e BR2_PACKAGE_LIBCURL=y
[bargee@barge ~]$ git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
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

### CRIU

```bash
[bargee@barge ~]$ sudo pkg install criu
```

### ipvsadm

```bash
[bargee@barge ~]$ sudo pkg install ipvsadm -e BR2_PACKAGE_LIBNL=y
```

### vim

```bash
[bargee@barge ~]$ sudo pkg install vim
```

### libfuse

```bash
[bargee@barge ~]$ sudo pkg install libfuse
```

### SSHFS

```bash
[bargee@barge ~]$ sudo pkg install sshfs
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

### bindfs

```bash
[bargee@barge ~]$ sudo pkg install bindfs
```
