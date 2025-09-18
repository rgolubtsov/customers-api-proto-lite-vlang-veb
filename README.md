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
  * **[Creating a Docker image](#creating-a-docker-image)**
* **[Running](#running)**
  * **[Running a Docker image](#running-a-docker-image)**
  * **[Exploring a Docker image payload](#exploring-a-docker-image-payload)**
* **[Consuming](#consuming)**
  * **[Logging](#logging)**
  * **[Error handling](#error-handling)**

## Building

The microservice might be built and run successfully under **Ubuntu Server (Ubuntu 24.04.3 LTS x86-64)** and **Arch Linux** (both proven). &mdash; First install the necessary dependencies (`build-essential`, `tcc`, `libsqlite3-dev`, `docker.io`):

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

The V distribution can be installed differently for these Linux distros:

* In Ubuntu Server:

```
$ curl -LO https://github.com/vlang/v/releases/latest/download/v_linux.zip
...
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
$ curl -LO https://aur.archlinux.org/cgit/aur.git/snapshot/vlang.tar.gz
...
$ tar -xvf vlang.tar.gz
...
$ cd vlang/ && makepkg -sirc
...
```

Then V can be invoked from anywhere just like system default C compiler:

```
$ v --version
V 0.4.11 16c9bf2
```

> Since V is still in beta state and changing continuously, this project is currently developed using the version (and the last build commit) of V given above, from 17th of September, 2025.

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
  v -prod -o bin/api-lited . && \
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

### Creating a Docker image

**Build** a Docker image for the microservice:

```
$ # Pull the Ubuntu LTS image first, if not already there:
$ sudo docker pull ubuntu:latest
...
$ # Then build the microservice image:
$ sudo docker build -tcustomersapi/api-lite-v .
...
```

## Running

**Run** the microservice using its executable directly, built previously by the V frontend or GNU Make's `all` target:

```
$ ./bin/api-lited; echo $?
...
```

To run the microservice as a *true* daemon, i.e. in the background, redirecting all the console output to `/dev/null`, the following form of invocation of its executable can be used:

```
$ ./bin/api-lited > /dev/null 2>&1 &
...
```

**Note:** This will suppress all the console output only; logging to a logfile and to the Unix syslog will remain unchanged.

### Running a Docker image

**Run** a Docker image of the microservice, deleting all stopped containers prior to that (if any):

```
$ sudo docker rm `sudo docker ps -aq`; \
  export PORT=8765 && sudo docker run -dp${PORT}:${PORT} --name api-lite-v customersapi/api-lite-v; echo $?
...
```

### Exploring a Docker image payload

The following is not necessary but might be considered somewhat interesting &mdash; to look up into the running container, and check out that the microservice's daemon executable, config, logfile, and accompanied SQLite database are at their expected places and in effect:

```
$ sudo docker ps -a
CONTAINER ID   IMAGE                     COMMAND           CREATED              STATUS              PORTS                                       NAMES
<container_id> customersapi/api-lite-v   "bin/api-lited"   About a minute ago   Up About a minute   0.0.0.0:8765->8765/tcp, :::8765->8765/tcp   api-lite-v
$
$ sudo docker exec -it api-lite-v bash; echo $?
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ uname -a
Linux <container_id> 6.8.0-53-generic #55-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 17 15:37:52 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ ls -al
total 36
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:50 .
drwxrwxrwt 1 root   root   4096 Mar  7 19:20 ..
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:20 bin
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:20 data
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:20 etc
drwxr-xr-x 2 daemon daemon 4096 Mar  7 19:50 log_
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ ls -al bin/ data/db/ etc/ log_/
bin/:
total 1244
drwxr-xr-x 1 daemon daemon    4096 Mar  7 19:20 .
drwxr-xr-x 1 daemon daemon    4096 Mar  7 19:50 ..
-rwxrwxr-x 1 daemon daemon 1258216 Mar  7 19:10 api-lited

data/db/:
total 40
drwxr-xr-x 1 daemon daemon  4096 Mar  7 19:20 .
drwxr-xr-x 1 daemon daemon  4096 Mar  7 19:20 ..
-rw-rw-r-- 1 daemon daemon 24576 Mar  7 19:10 customers-api-lite.db

etc/:
total 16
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:20 .
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:50 ..
-rw-rw-r-- 1 daemon daemon  797 Mar  7 19:10 settings.conf

log_/:
total 16
drwxr-xr-x 2 daemon daemon 4096 Mar  7 19:50 .
drwxr-xr-x 1 daemon daemon 4096 Mar  7 19:50 ..
-rw-r--r-- 1 daemon daemon  176 Mar  7 19:50 customers-api-lite.log
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ ldd bin/api-lited
        linux-vdso.so.1 (0x00007ffed47e1000)
        libsqlite3.so.0 => /lib/x86_64-linux-gnu/libsqlite3.so.0 (0x00007546dfb91000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007546df97f000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007546df896000)
        /lib64/ld-linux-x86-64.so.2 (0x00007546dfe5b000)
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ netstat -plunt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp6       0      0 :::8765                 :::*                    LISTEN      1/bin/api-lited
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
daemon         1  0.0  0.5  28068  9344 ?        Ssl  19:50   0:00 bin/api-lited
daemon         8  0.0  0.2   4588  3840 pts/0    Ss   19:55   0:00 bash
daemon        25  0.0  0.2   7888  3968 pts/0    R+   20:00   0:00 ps aux
daemon@<container_id>:/var/tmp/api-lite$
daemon@<container_id>:/var/tmp/api-lite$ exit # Or simply <Ctrl-D>.
exit
0
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

```
$ curl -vXPUT http://localhost:8765/v1/customers \
       -H 'content-type: application/json' \
       -d '{"name":"Jamison Palmer"}'
...
> PUT /v1/customers HTTP/1.1
...
> content-type: application/json
> Content-Length: 25
...
< HTTP/1.1 201 Created
< Location: /v1/customers/3
< Content-Type: application/json
< Content-Length: 32
< Server: veb
...
{"id":3,"name":"Jamison Palmer"}
```

2. **Create contact**

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"+12197654320"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 44
...
< HTTP/1.1 201 Created
< Location: /v1/customers/3/contacts/phone
< Content-Type: application/json
< Content-Length: 26
< Server: veb
...
{"contact":"+12197654320"}
```

Or create **email** contact:

```
$ curl -vXPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"jamison.palmer@example.com"}'
...
> PUT /v1/customers/contacts HTTP/1.1
...
> content-type: application/json
> Content-Length: 58
...
< HTTP/1.1 201 Created
< Location: /v1/customers/3/contacts/email
< Content-Type: application/json
< Content-Length: 40
< Server: veb
...
{"contact":"jamison.palmer@example.com"}
```

3. **List customers**

```
$ curl -v http://localhost:8765/v1/customers
...
> GET /v1/customers HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 136
< Server: veb
...
[{"id":1,"name":"Jammy Jellyfish"},{"id":2,"name":"Noble Numbat"},{"id":3,"name":"Jamison Palmer"},{"id":4,"name":"Sarah Kitteringham"}]
```

4. **Retrieve customer**

```
$ curl -v http://localhost:8765/v1/customers/3
...
> GET /v1/customers/3 HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 32
< Server: veb
...
{"id":3,"name":"Jamison Palmer"}
```

5. **List contacts for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts
...
> GET /v1/customers/3/contacts HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 186
< Server: veb
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"},{"contact":"jamison.palmer@example.com"},{"contact":"jp@example.com"},{"contact":"jpalmer@example.com"}]
```

6. **List contacts of a given type for a given customer**

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/phone
...
> GET /v1/customers/3/contacts/phone HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 82
< Server: veb
...
[{"contact":"+12197654320"},{"contact":"+12197654321"},{"contact":"+12197654322"}]
```

Or list **email** contacts:

```
$ curl -v http://localhost:8765/v1/customers/3/contacts/email
...
> GET /v1/customers/3/contacts/email HTTP/1.1
...
< HTTP/1.1 200 OK
< Content-Type: application/json
< Content-Length: 105
< Server: veb
...
[{"contact":"jamison.palmer@example.com"},{"contact":"jpalmer@example.com"},{"contact":"jp@example.com"}]
```

> ^ The given names in customer accounts and in email contacts (in samples above) are for demonstrational purposes only. They have nothing common WRT any actual, ever really encountered names elsewhere.

### Logging

The microservice has the ability to log messages to a logfile and to the Unix syslog facility. To enable debug logging, the `debug.enabled` setting in the microservice main config file `etc/settings.conf` should be set to `true` *before starting up the microservice*. When running under Ubuntu Server or Arch Linux (not in a Docker container), logs can be seen and analyzed in an ordinary fashion, by `tail`ing the `log_/customers-api-lite.log` logfile:

```
$ tail -f log_/customers-api-lite.log
[2025-09-18][17:50:30] [DEBUG] [Customers API Lite]
[2025-09-18][17:50:30] [DEBUG] [sqlite.DB{ conn: 63d0e845b028 }]
[2025-09-18][17:50:30] [INFO ] Server started on port 8765
[2025-09-18][17:51:30] [DEBUG] [PUT]
[2025-09-18][17:51:30] [DEBUG] [Saturday Sunday]
[2025-09-18][17:51:30] [DEBUG] [5|Saturday Sunday]
[2025-09-18][17:52:30] [DEBUG] [PUT]
[2025-09-18][17:52:30] [DEBUG] customer_id=5
[2025-09-18][17:52:30] [DEBUG] [Saturday.Sunday@example.com]
[2025-09-18][17:52:30] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-09-18][17:53:40] [DEBUG] [GET]
[2025-09-18][17:53:40] [DEBUG] customer_id=5
[2025-09-18][17:53:40] [DEBUG] [5|Saturday Sunday]
[2025-09-18][17:54:50] [DEBUG] [GET]
[2025-09-18][17:54:50] [DEBUG] customer_id=5 | contact_type=email
[2025-09-18][17:54:50] [DEBUG] [Saturday.Sunday@example.com]
```

Messages registered by the Unix system logger can be seen and analyzed using the `journalctl` utility:

```
$ journalctl -f
...
Sep 18 19:50:30 <hostname> api-lited[<pid>]: [Customers API Lite]
Sep 18 19:50:30 <hostname> api-lited[<pid>]: [sqlite.DB{ conn: 63d0e845b028 }]
Sep 18 19:50:30 <hostname> api-lited[<pid>]: Server started on port 8765
Sep 18 19:51:30 <hostname> api-lited[<pid>]: [PUT]
Sep 18 19:51:30 <hostname> api-lited[<pid>]: [Saturday Sunday]
Sep 18 19:51:30 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Sep 18 19:52:30 <hostname> api-lited[<pid>]: [PUT]
Sep 18 19:52:30 <hostname> api-lited[<pid>]: customer_id=5
Sep 18 19:52:30 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Sep 18 19:52:30 <hostname> api-lited[<pid>]: [email|Saturday.Sunday@example.com]
Sep 18 19:53:40 <hostname> api-lited[<pid>]: [GET]
Sep 18 19:53:40 <hostname> api-lited[<pid>]: customer_id=5
Sep 18 19:53:40 <hostname> api-lited[<pid>]: [5|Saturday Sunday]
Sep 18 19:54:50 <hostname> api-lited[<pid>]: [GET]
Sep 18 19:54:50 <hostname> api-lited[<pid>]: customer_id=5 | contact_type=email
Sep 18 19:54:50 <hostname> api-lited[<pid>]: [Saturday.Sunday@example.com]
Sep 18 19:55:00 <hostname> api-lited[<pid>]: Server stopped
```

Inside the running container logs might be queried also by `tail`ing the `log_/customers-api-lite.log` logfile:

```
daemon@<container_id>:/var/tmp/api-lite$ tail -f log_/customers-api-lite.log
[2025-03-07][20:40:10] [DEBUG] [Customers API Lite]
[2025-03-07][20:40:10] [DEBUG] [sqlite.DB{ conn: 5c709503ad88 }]
[2025-03-07][20:40:10] [INFO ] Server started on port 8765
[2025-03-07][20:45:00] [DEBUG] [PUT]
[2025-03-07][20:45:00] [DEBUG] [Saturday Sunday]
[2025-03-07][20:45:00] [DEBUG] [5|Saturday Sunday]
[2025-03-07][20:47:00] [DEBUG] [PUT]
[2025-03-07][20:47:00] [DEBUG] customer_id=5
[2025-03-07][20:47:00] [DEBUG] [Saturday.Sunday@example.com]
[2025-03-07][20:47:00] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-03-07][20:49:00] [DEBUG] [GET]
[2025-03-07][20:49:00] [DEBUG] customer_id=5
[2025-03-07][20:49:00] [DEBUG] [5|Saturday Sunday]
[2025-03-07][20:49:30] [DEBUG] [GET]
[2025-03-07][20:49:30] [DEBUG] customer_id=5 | contact_type=email
[2025-03-07][20:49:30] [DEBUG] [Saturday.Sunday@example.com]
```

And of course, Docker itself gives the possibility to read log messages by using the corresponding command for that:

```
$ sudo docker logs -f api-lite-v
[2025-03-07][20:40:10] [DEBUG] [Customers API Lite]
[2025-03-07][20:40:10] [DEBUG] [sqlite.DB{ conn: 5c709503ad88 }]
[2025-03-07][20:40:10] [INFO ] Server started on port 8765
[2025-03-07][20:45:00] [DEBUG] [PUT]
[2025-03-07][20:45:00] [DEBUG] [Saturday Sunday]
[2025-03-07][20:45:00] [DEBUG] [5|Saturday Sunday]
[2025-03-07][20:47:00] [DEBUG] [PUT]
[2025-03-07][20:47:00] [DEBUG] customer_id=5
[2025-03-07][20:47:00] [DEBUG] [Saturday.Sunday@example.com]
[2025-03-07][20:47:00] [DEBUG] [email|Saturday.Sunday@example.com]
[2025-03-07][20:49:00] [DEBUG] [GET]
[2025-03-07][20:49:00] [DEBUG] customer_id=5
[2025-03-07][20:49:00] [DEBUG] [5|Saturday Sunday]
[2025-03-07][20:49:30] [DEBUG] [GET]
[2025-03-07][20:49:30] [DEBUG] customer_id=5 | contact_type=email
[2025-03-07][20:49:30] [DEBUG] [Saturday.Sunday@example.com]
Server stopped
```

### Error handling

When the URI path or request body passed in an incoming request contains inappropriate input, the microservice will respond with the **HTTP 400 Bad Request** status code, including a specific response body in JSON representation which may describe a possible cause of underlying client error, like the following:

```
$ curl http://localhost:8765/v1/customers/=qwerty4838=-i-.--089asdf..nj524987
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/3..,,7/contacts
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl http://localhost:8765/v1/customers/--089asdf../contacts/email
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
$
$ curl -XPUT http://localhost:8765/v1/customers/contacts \
       -H 'content-type: application/json' \
       -d '{"customer_id":"3","contact":"12197654320--089asdf../nj524987"}'
{"error":"HTTP 400 Bad Request: Request is malformed. Please check your inputs."}
```
