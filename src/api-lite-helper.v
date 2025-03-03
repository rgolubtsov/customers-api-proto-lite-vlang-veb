/*
 * src/api-lite-helper.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.2.0
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The helper module for the daemon -------------------------------------------

module helper

import toml
import log
import veb
import os

import vseryakov.syslog as s

// Helper constants.
pub const exit_failure =    1 //    Failing exit status.
pub const exit_success =    0 // Successful exit status.
pub const space        =  ' '
pub const slash        =  '/'
pub const equals       =  '='
pub const v_bar        =  '|'
pub const o_bracket    =  '['
pub const c_bracket    =  ']'
pub const new_line     = '\n'

// Common error messages.
const err_port_valid_must_be_positive_int
    = 'Valid server port must be a positive integer value, '
    + 'in the range 1024 .. 49151. The default value of 8080 '
    + 'will be used instead.'
const err_settings_unable_to_get
    = 'FATAL: Unable to get daemon settings. Quitting...'
pub const err_database_cannot_connect
    = 'FATAL: Cannot connect to the database. Quitting...'
pub const err_cannot_start_server
    = 'FATAL: Cannot start server '
pub const err_addr_already_in_use
    = 'due to address requested already in use. Quitting...'
pub const err_serv_unknown_reason
    = 'for an unknown reason. Quitting...'
pub const err_eaddrinuse_glob = '*98*'
pub const err_req_malformed
    = 'HTTP 400 Bad Request: Request is malformed. Please check your inputs.'
pub const err_req_method_not_allowed
    = 'HTTP 405 Method Not Allowed. Allowed methods: '

// Common notification messages.
pub const msg_server_started = 'Server started on port '
pub const msg_server_stopped = 'Server stopped'

// settings_ The path and filename of the daemon settings.
pub const settings_ = './etc/settings.conf'

// min_port The minimum port number allowed.
pub const min_port = 1024

// max_port The maximum port number allowed.
pub const max_port = 49151

// daemon_name_ Daemon settings key for the microservice daemon name.
pub const daemon_name_ = 'daemon.name'

// server_port_ Daemon settings key for the server port number.
pub const server_port_ = 'server.port'

// log_enabled_ Daemon settings key for the debug logging enabler.
pub const log_enabled_ = 'logger.debug.enabled'

pub const log_dir_ = './log_/'
pub const logfile_ = 'customers-api-lite.log'
pub const logtime_ = '[YYYY-MM-DD][HH:mm:ss]'

// database_path_ Daemon settings key for the SQLite database path.
pub const database_path_ = 'sqlite.database.path'

// REST URI path-related constants.
pub const rest_version  = 'v1'
pub const rest_prefix   = 'customers'
pub const rest_contacts = 'contacts'
pub const phone         = 'phone'
pub const email         = 'email'

// HTTP request path variable names.
pub const cust_id   = 'customer_id'
pub const cont_type = 'contact_type'

// HTTP response-related constants.
pub const hdr_allow_1 = 'PUT, GET, HEAD'
pub const hdr_allow_2 = 'PUT'
pub const hdr_allow_3 = 'GET, HEAD'

// Regex patterns for contact phones and emails.
pub const phone_regex = '^\\+\\d{9,14}'
pub const email_regex = '.{1,63}@.{3,190}'

// get_settings_ Helper function. Used to get the daemon settings.
pub fn get_settings_() toml.Doc {
    return toml.parse_file(settings_) or {
        eprintln(err_settings_unable_to_get)

        exit(exit_failure)
    }
}

// get_server_port_ Retrieves the port number used to run
// the inbuilt web server, from daemon settings.
//
// @param `settings` The daemon settings as a `toml.Doc` struct.
// @param `l`        The main logger of the daemon.
//
// @returns The port number on which the server has to be run.
pub fn get_server_port_(settings toml.Doc, mut l log.Log) int {
    server_port := settings.value(server_port_).int()

    if server_port != 0 {
        if (server_port >= min_port) && (server_port <= max_port) {
            return server_port
        } else {
            l.error(err_port_valid_must_be_positive_int)

            return veb.default_port
        }
    } else {
        l.error(err_port_valid_must_be_positive_int)

        return veb.default_port
    }
}

// dbg_ Helper func. Used to log messages for debugging aims in a free form.
pub fn dbg_(dbg bool, mut l log.Log, message string) {
    if dbg {
        l.debug(message);
        s.debug(message);
    }
}

// cleanup_ Helper function. Makes final cleanups, closes streams, etc.
pub fn cleanup_(mut l log.Log) {
    l.info(msg_server_stopped)
    s.info(msg_server_stopped)

    l.close()

    // Closing the system logger.
    // Calling <syslog.h> closelog();
    s.close()
}

// cleanup__ Helper function. Does same things as the `cleanup_(mut l log.Log)`
// function, but gets called when an appropriate POSIX signal is received.
// There are two signals supported: `SIGINT` (<Ctrl-C>) and `SIGTERM`.
pub fn cleanup__(signal os.Signal) {
    eprintln(msg_server_stopped)
      s.info(msg_server_stopped)

    // Closing the system logger.
    // Calling <syslog.h> closelog();
    s.close()

    exit(exit_success)
}

// vim:set nu et ts=4 sw=4:
