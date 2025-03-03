#
# Dockerfile
# =============================================================================
# Customers API Lite microservice prototype (V port). Version 0.1.2
# =============================================================================
# A daemon written in V (vlang/veb), designed and intended to be run
# as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

# === Stage 1: Install dependencies ===========================================
FROM       ubuntu:latest
RUN        ["apt-get", "update"]
RUN        ["apt-get", "install", "libsqlite3-0", "net-tools", "-y"]

# === Stage 2: Run the microservice ===========================================
USER       daemon
WORKDIR    var/tmp
COPY       bin     api-lite/bin/
COPY       etc     api-lite/etc/
COPY       data/db api-lite/data/db/
WORKDIR    api-lite
USER       root
RUN        ["chown", "-R", "daemon:daemon", "."]
USER       daemon
ENTRYPOINT ["bin/api-lited"]

# vim:set nu ts=4 sw=4:
