/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.10
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The main module of the daemon ----------------------------------------------

module main

import log
import veb
import os

import vseryakov.syslog as s

import helper     as h
import controller as c

// CustomersApiLiteApp The main web app struct containing arbitrary data
// that are accessible by all endpoints and shared between different routes.
pub struct CustomersApiLiteApp {
    dbg bool
mut:
    l   log.Log
}

// RequestContext The struct containing data that are specific to each request.
// It also holds a standard HTTP request/response pair.
pub struct RequestContext {
    veb.Context
}

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := h.get_settings_()

    daemon_name := settings.value(h.daemon_name_).string()

    // Getting the port number used to run the inbuilt web server.
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
    s.open(os.args[0], s.log_cons | s.log_pid, s.log_daemon)

//  if dbg { l.set_level(.debug) }

    l.info(h.msg_server_started + '${server_port}')
    s.info(h.msg_server_started + '${server_port}')

    h.dbg_(dbg, mut l, h.o_bracket + daemon_name + h.c_bracket)

    mut app := &CustomersApiLiteApp{
        dbg: dbg
        l:   l
    }

    // Trying to start up the inbuilt web server.
    veb.run_at[CustomersApiLiteApp, RequestContext](mut app, port: server_port,
        show_startup_message: false) or {
            h.cleanup_(mut l)
            panic(err)
        }
}

// list_customers The `GET /v1/customers` endpoint.
//
// Retrieves from the database and lists all customer profiles.
//
// @returns The `Result` dummy struct with the `200 OK` HTTP status code
//          and the response body in JSON representation, containing a list
//          of all customer profiles.
//          May return client or server error depending on incoming request.
@['/v1/customers']
pub fn (mut app CustomersApiLiteApp) list_customers(mut ctx RequestContext)
    veb.Result {

    c.list_customers_(app.dbg, mut app.l)

    logger := c.common_ctrl_hlpr_(app.dbg)

    return ctx.json(logger)
}

// vim:set nu et ts=4 sw=4:
