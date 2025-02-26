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
* **[Consuming](#consuming)**

## Building

The microservice might be built and run successfully under **Ubuntu Server (Ubuntu 24.04.2 LTS x86-64)** and **Arch Linux** (both proven). &mdash; First install the necessary dependencies (`build-essential`, `tcc`, `libsqlite3-dev`, `docker.io`):

* In Ubuntu Server:

```
$ sudo apt-get update && \
  sudo apt-get install build-essential tcc libsqlite3-dev docker.io -y
...
```

* In Arch Linux:

```
$ sudo pacman -Syu base-devel tcc sqlite docker
...
```

The V distribution should be installed separately:

* In Ubuntu Server:

```
$ curl -LOk https://github.com/vlang/v/releases/latest/download/v_linux.zip
...
$
$ unzip v_linux.zip
...
```

Then it needs to add V to the `PATH` environment variable to make it accessible system-wide &mdash; edit the `.profile` config so that it will contain reference to the `v/` directory, something like the following (and do relogin after that):

```
$ cat .profile
...
PATH="$HOME/bin:$HOME/.local/bin:$HOME/v:$PATH"
...
```

* In Arch Linux &mdash; from the AUR (Arch User Repository) since it is not yet added to the official Arch Linux repositories. For that to be done, simply download a snapshot of the V AUR-package, unpack it and do build/install it system-wide:

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
V 0.4.9 01bee65
```

> Since V is still in beta state and changing continuously, this project is currently developing using the version (and the last build commit) of V given above, from 18th of February, 2025.

---

The microservice is utilizing a third-party module `vseryakov.syslog` to be able to log messages to the Unix syslog facility, so it needs to install this module prior building the microservice:

```
$ v install vseryakov.syslog
Scanning `vseryakov.syslog`...
Installing `vseryakov.syslog`...
Installed `vseryakov.syslog` in ~/.vmodules/vseryakov/syslog .
```

**Build** the microservice using the **V frontend**:

```
$ if [ ! -d bin ]; then \
      mkdir bin; \
  fi && \
  v -o bin/api-lited . && \
  if [ -f data/db/customers-api-lite.db.xz ]; then \
      unxz data/db/customers-api-lite.db.xz; \
  fi
```

Or **build** the microservice using **GNU Make** (optional, but for convenience &mdash; it covers the same **V frontend** build workflow under the hood):

```
$ make clean
...
$ make all  # <== Building the daemon.
...
```

## Running

**Run** the microservice using its executable directly, built previously by the V frontend or GNU Make's `all` target:

```
$ ./bin/api-lited; echo $?
...
```

## Consuming

The microservice exposes **six REST API endpoints** to web clients. They are all intended to deal with customer entities and/or contact entities that belong to customer profiles. The following table displays their syntax:

No. | Endpoint name                                      | Request method and REST URI                                   | Request body
--: | -------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------
1   | Create customer                                    | **PUT** `/v1/customers`                                       | `{"name":"{customer_name}"}`
2   | Create contact                                     | **PUT** `/v1/customers/contacts`                              | `{"customer_id":"{customer_id}","contact":"{customer_contact}"}`
3   | List customers                                     | **GET** `/v1/customers`                                       | &ndash;
4   | Retrieve customer                                  | **GET** `/v1/customers/{customer_id}`                         | &ndash;
5   | List contacts for a given customer                 | **GET** `/v1/customers/{customer_id}/contacts`                | &ndash;
6   | List contacts of a given type for a given customer | **GET** `/v1/customers/{customer_id}/contacts/{contact_type}` | &ndash;

* The `{customer_name}` placeholder is a string &mdash; it usually means the full name given to a newly created customer.
* The `{customer_id}` placeholder is a decimal positive integer number, greater than `0`.
* The `{customer_contact}` placeholder is a string &mdash; it denotes a newly created customer contact (phone or email).
* The `{contact_type}` placeholder is a string and can take one of two possible values, case-insensitive: `phone` or `email`.

The following command-line snippets display the exact usage for these endpoints (the **cURL** utility is used as an example to access them)^:

1. **Create customer**

**TBD** :cd:

2. **Create contact**

**TBD** :cd:

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 66
< Server: veb
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/2
...
> GET /v1/customers/2 HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 30
< Server: veb
...
{"id":2,"name":"Noble Numbat"}
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/2/contacts
...
> GET /v1/customers/2/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 190
< Server: veb
...
[{"contact":"+35760X123456"},{"contact":"+35760Y1234578"},{"contact":"+35790Z12345890"},{"contact":"nn@example.org"},{"contact":"nnumbat@example.com"},{"contact":"noble.numbat@example.com"}]
```

6. **List contacts of a given type for a given customer**

**TBD** :cd:

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

---

**TBD** :dvd:
