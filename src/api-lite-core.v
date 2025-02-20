/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.8
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The main module of the daemon ----------------------------------------------

module main

import veb
import log
import os

import vseryakov.syslog as s

import helper as h

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := h.get_settings_()

    daemon_name := settings.value(h.daemon_name_).string()

    // Getting the port number used to run the bundled web server.
    server_port := settings.value(h.server_port_).int()

    // Identifying whether debug logging is enabled.
    dbg := settings.value(h.log_enabled_).bool()

    // Creating and configuring the main logger of the daemon.
    mut l := log.Log{}

    // Suppressing the following temporary service message:
    // NOTE: the `log.Log` output goes to stderr now by default, not to stdout.
    l.set_output_stream(os.stderr())

    if !os.exists(h.log_dir_) { os.mkdir(h.log_dir_, os.MkdirParams{})! }

    l.set_custom_time_format(h.logtime_)
    l.set_always_flush(true)
    l.set_full_logpath(h.log_dir_ + h.logfile_)
    l.log_to_console_too()

    // Opening the system logger.
    // Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    s.open(h.empty_string, s.log_cons | s.log_pid, s.log_daemon)

//  if dbg { l.set_level(.debug) }

    h.dbg_(dbg, mut l, h.o_bracket + daemon_name + h.c_bracket)

    mut app := &h.CustomersApiLiteApp{
        dbg: dbg
        l:   l
    }

    // Starting up the bundled web server.
    veb.run[h.CustomersApiLiteApp, h.RequestContext](mut app, server_port)

    l.close()

    // Closing the system logger.
    // Calling <syslog.h> closelog();
    s.close()
}

// vim:set nu et ts=4 sw=4:
