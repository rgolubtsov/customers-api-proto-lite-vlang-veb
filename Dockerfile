#
# Dockerfile
# =============================================================================
# Customers API Lite microservice prototype (V port). Version 0.2.7
# =============================================================================
# A daemon written in V (vlang/veb), designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# === Stage 1: Install dependencies ===========================================
FROM       thevlang/vlang:alpine
RUN        ["apk", "add", "make"]

# === Stage 2: Build the microservice =========================================
USER       daemon
WORKDIR    var/tmp
COPY       src      api-lite/src/
COPY       etc      api-lite/etc/
COPY       data/db  api-lite/data/db/
COPY       Makefile api-lite/
WORKDIR    api-lite
USER       root
RUN        ["v", "/opt/vlang/cmd/tools/vpm" ]
RUN        ["mkdir", "-p", "/sbin/.vmodules"]
RUN        ["chown", "-R", "daemon:daemon", "/sbin/.vmodules", "."]
USER       daemon
RUN        ["v", "install", "vseryakov.syslog"]
RUN        ["make", "clean"]
RUN        ["make", "all"  ]

# === Stage 3: Run the microservice ===========================================
ENTRYPOINT ["bin/api-lited"]

# vim:set nu ts=4 sw=4:
