/*
 * src/api-lite-helper.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.8
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

import vseryakov.syslog as s

// Helper constants.
pub const empty_string =  ''
pub const o_bracket    = '['
pub const c_bracket    = ']'

// settings_ The path and filename of the daemon settings.
const settings_ = './etc/settings.conf'

// Daemon settings key for the microservice daemon name.
pub const daemon_name_ = 'daemon.name'

// Daemon settings key for the server port number.
pub const server_port_ = 'server.port'

// Daemon settings key for the debug logging enabler.
pub const log_enabled_ = 'logger.debug.enabled'

pub const log_dir_ = './log_/'
pub const logfile_ = 'customers-api-lite.log'
pub const logtime_ = '[YYYY-MM-DD][HH:mm:ss]'

// get_settings_ Helper function. Used to get the daemon settings.
pub fn get_settings_() toml.Doc {
    return toml.parse_file(settings_) or { panic(err) }
}

// dbg_ Helper func. Used to log messages for debugging aims in a free form.
pub fn dbg_(dbg bool, mut l log.Log, message string) {
    if dbg {
        l.debug(message);
        s.debug(message);
    }
}

// vim:set nu et ts=4 sw=4:
