/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.5
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The main module of the daemon and the entry point --------------------------

module main

import toml
import veb

// Helper constants.
const o_bracket = '['
const c_bracket = ']'

// CustomersApiLiteApp The struct containing data that are shared between
// different routes.
pub struct CustomersApiLiteApp {}

// RequestContext The struct containing data that are specific to each request.
struct RequestContext {
    veb.Context
}

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    // Getting the daemon settings.
    settings := get_settings()

    daemon_name := settings.value('daemon.name').string()

    // Getting the port number used to run the bundled web server.
    server_port := settings.value('server.port').int()

    // Identifying whether debug logging is enabled.
    dbg := settings.value('logger.debug.enabled').bool()

    println(o_bracket +    daemon_name   + c_bracket)
    println(o_bracket + '${server_port}' + c_bracket)
    println(o_bracket + '${dbg        }' + c_bracket)

    mut app := &CustomersApiLiteApp{}

    // Starting up the bundled web server.
    veb.run[CustomersApiLiteApp, RequestContext](mut app, server_port)
}

// get_settings Helper function. Used to get the daemon settings.
fn get_settings() toml.Doc {
    return toml.parse_file('./etc/settings.conf') or { panic(err) }
}

// vim:set nu et ts=4 sw=4:
