# Package Installer for DockerRoot

## Usage

```
pkg <build|install> <package-name>
```

### pkg build <package-name>

Build a package and create `docker-root-pkg-<package-name>.tar.gz` file in the current directory.

### pkg install <package-name>

Install `docker-root-pkg-<package-name>.tar.gz` into the root filesystem.

```bash
[docker@docker-root-pkg ~]$ wget https://raw.githubusercontent.com/ailispaw/docker-root-pkg/master/pkg
[docker@docker-root-pkg ~]$ chmod +x pkg
[docker@docker-root-pkg ~]$ ./pkg
Usage: pkg <build|install> <package-name>
[docker@docker-root-pkg ~]$ ./pkg build tar
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
[docker@docker-root-pkg ~]$ ls -l *.tar.gz
-rw-r--r--    1 docker   docker     1073385 Nov 29 11:34 docker-root-pkg-tar.tar.gz
[docker@docker-root-pkg ~]$ ./pkg install tar
```
