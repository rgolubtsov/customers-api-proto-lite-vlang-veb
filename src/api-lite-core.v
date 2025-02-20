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

// The main module of the daemon and the entry point --------------------------

module main

import veb
import toml
import log
import os

import vseryakov.syslog as s

// Helper constants.
const empty_string =  ''
const o_bracket    = '['
const c_bracket    = ']'

// settings_ The path and filename of the daemon settings.
const settings_ = './etc/settings.conf'

// Daemon settings key for the microservice daemon name.
const daemon_name_ = 'daemon.name'

// Daemon settings key for the server port number.
const server_port_ = 'server.port'

// Daemon settings key for the debug logging enabler.
const log_enabled_ = 'logger.debug.enabled'

const log_dir_ = './log_/'
const logfile_ = 'customers-api-lite.log'
const logtime_ = '[YYYY-MM-DD][HH:mm:ss]'

// CustomersApiLiteApp The struct containing data that are shared between
// different routes.
pub struct CustomersApiLiteApp {
    logger log.Log
}

// RequestContext The struct containing data that are specific to each request.
struct RequestContext {
    veb.Context
}

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := get_settings_()

    daemon_name := settings.value(daemon_name_).string()

    // Getting the port number used to run the bundled web server.
    server_port := settings.value(server_port_).int()

    // Identifying whether debug logging is enabled.
    dbg := settings.value(log_enabled_).bool()

    // Creating and configuring the main logger of the daemon.
    mut l := log.Log{}

    // Suppressing the following temporary service message:
    // NOTE: the `log.Log` output goes to stderr now by default, not to stdout.
    l.set_output_stream(os.stderr())

    if !os.exists(log_dir_) { os.mkdir(log_dir_, os.MkdirParams{})! }

    l.set_custom_time_format(logtime_)
    l.set_always_flush(true)
    l.set_full_logpath(log_dir_ + logfile_)
    l.log_to_console_too()

    // Opening the system logger.
    // Calling <syslog.h> openlog(NULL, LOG_CONS | LOG_PID, LOG_DAEMON);
    s.open(empty_string, s.log_cons | s.log_pid, s.log_daemon)

//  if dbg { l.set_level(.debug) }

    dbg_(dbg, mut l, o_bracket + daemon_name + c_bracket)

    mut app := &CustomersApiLiteApp{
        logger: l
    }

    // Starting up the bundled web server.
    veb.run[CustomersApiLiteApp, RequestContext](mut app, server_port)

    l.close()

    // Closing the system logger.
    // Calling <syslog.h> closelog();
    s.close()
}

// get_settings_ Helper function. Used to get the daemon settings.
fn get_settings_() toml.Doc {
    return toml.parse_file(settings_) or { panic(err) }
}

// dbg_ Helper func. Used to log messages for debugging aims in a free form.
fn dbg_(dbg bool, mut l log.Log, message string) {
    if dbg {
        l.debug(message);
        s.debug(message);
    }
}

// vim:set nu et ts=4 sw=4:
