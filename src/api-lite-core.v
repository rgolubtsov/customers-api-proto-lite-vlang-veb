/*
 * src/api-lite-core.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.1
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

// CustomersApiLiteApp The struct containing data that are shared between
// different routes.
struct CustomersApiLiteApp {}

// RequestContext The struct containing data that are specific to each request.
struct RequestContext {
    veb.Context
}

// server_port The port number used to run the bundled web server.
const server_port = 8765

// main The microservice entry point.
//
// @returns The exit code of the overall termination of the daemon.
fn main() {
    println('[Customers API Lite]')

    mut app := &CustomersApiLiteApp{}

    // Starting up the bundled web server.
    veb.run[CustomersApiLiteApp, RequestContext](mut app, server_port)
}

// vim:set nu et ts=4 sw=4:
