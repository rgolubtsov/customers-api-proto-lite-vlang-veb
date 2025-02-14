# Customers API Lite microservice prototype :small_orange_diamond: <img src="https://vlang.io/img/v-logo.png" style="border:0;width:32px" alt="V" />

**A daemon written in V (vlang/veb), designed and intended to be run as a microservice,
<br />implementing a special Customers API prototype with a smart yet simplified data scheme**

**Rationale:** This project is a *direct* **[V](https://vlang.io "The V Programming Language")** port of the earlier developed **Customers API Lite microservice prototype**, written in Java using **[Spring Boot](https://spring.io/projects/spring-boot "Stand-alone Spring apps builder and runner")** framework, and tailored to be run as a microservice in a Docker container. The following description of the underlying architecture and logics has been taken **[from here](https://github.com/rgolubtsov/customers-api-proto-lite-spring-boot)** almost as is, without any principal modifications or adjustment.

This repo is dedicated to develop a microservice that implements a prototype of REST API service for ordinary Customers operations like adding/retrieving a Customer to/from the database, also doing the same ops with Contacts (phone or email) which belong to a Customer account.

The data scheme chosen is very simplified and consisted of only three SQL database tables, but that's quite sufficient because the service operates on only two entities: a **Customer** and a **Contact** (phone or email). And a set of these operations is limited to the following ones:

* Create a new customer (put customer data to the database).
* Create a new contact for a given customer (put a contact regarding a given customer to the database).
* Retrieve from the database and list all customer profiles.
* Retrieve profile details for a given customer from the database.
* Retrieve from the database and list all contacts associated with a given customer.
* Retrieve from the database and list all contacts of a given type associated with a given customer.

As it is clearly seen, there are no *mutating*, usually expected operations like *update* or *delete* an entity and that's made intentionally.

The microservice incorporates the **[SQLite](https://sqlite.org "A small, fast, self-contained, high-reliability, full-featured, SQL database engine")** database as its persistent store. It is located in the `data/db/` directory as an XZ-compressed database file with minimal initial data &mdash; actually having two Customers and by six Contacts for each Customer. The database file is automatically decompressed during build process of the microservice and ready to use as is even when containerized with Docker.

Generally speaking, this project might be explored as a PoC (proof of concept) on how to amalgamate V REST API service backed by SQLite database, running standalone as a conventional daemon in host or VM environment, or in a containerized form as usually widely adopted nowadays.

Surely, one may consider this project to be suitable for a wide variety of applied areas and may use this prototype as: (1) a template for building similar microservices, (2) for evolving it to make something more universal, or (3) to simply explore it and take out some snippets and techniques from it for *educational purposes*, etc.

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
