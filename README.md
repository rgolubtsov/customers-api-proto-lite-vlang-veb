# Customers API Lite microservice prototype :small_orange_diamond: <img src="https://vlang.io/img/v-logo.png" style="border:0;width:32px" alt="V" /> (V port)

**A daemon written in V (vlang/veb), designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[V](https://vlang.io "The V Programming Language")** port of the earlier developed **Customers API Lite microservice prototype**, written in Java using **[Spring Boot](https://spring.io/projects/spring-boot "Stand-alone Spring apps builder and runner")** framework, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-spring-boot)** as is, without any modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

:cd:

---

## Table of Contents

* **[Building](#building)**
* **[Running](#running)**

## Building

The microservice might be built and run successfully under **Arch Linux** (proven). &mdash; First install the necessary dependencies (`base-devel`, `tcc`, `docker`):

```
$ sudo pacman -Syu base-devel tcc docker
...
```

The V distribution should be installed from the AUR (Arch User Repository) since it is not yet added to the official Arch Linux repositories. For that to be done, simply download a snapshot of the V AUR-package, unpack it and do build/install it system-wide:

```
$ mkdir -p aur/build && cd aur/build/
$ curl -LOk https://aur.archlinux.org/cgit/aur.git/snapshot/vlang.tar.gz
...
$
$ tar -xvf vlang.tar.gz
...
$
$ cd vlang/ && makepkg -sirc
...
```

Then V can be invoked from anywhere just like system default C compiler:

```
$ v --version
V 0.4.9 3953445
```

**Build** the microservice using the **V frontend**:

```
$ v -o api-lited .
```

## Running

**Run** the microservice using its executable directly, built previously by the V frontend:

```
$ ./api-lited; echo $?
...
```

:dvd:
