/*
 * src/api-lite-controller.v
 * ============================================================================
 * Customers API Lite microservice prototype (V port). Version 0.0.9
 * ============================================================================
 * A daemon written in V (vlang/veb), designed and intended to be run
 * as a microservice, implementing a special Customers API prototype
 * with a smart yet simplified data scheme.
 * ============================================================================
 * (See the LICENSE file at the top of the source tree.)
 */

// The controller module of the daemon ----------------------------------------

module controller

import veb

import helper as h

// Defining an alias for the `CustomersApiLiteApp` struct.
type App = h.CustomersApiLiteApp

// list_customers The `GET /v1/customers` endpoint.
//
// Retrieves from the database and lists all customer profiles.
//
// @returns The `Result` dummy struct with the `200 OK` HTTP status code
//          and the response body in JSON representation, containing a list
//          of all customer profiles.
//          May return client or server error depending on incoming request.
@['/v1/customers']
fn (mut app App) list_customers(mut ctx h.RequestContext) veb.Result {
    h.dbg_(app.dbg, mut app.l, h.o_bracket + '${app.dbg}' + h.c_bracket)

    return ctx.text(h.o_bracket + '${app.dbg}' + h.c_bracket)
}

// vim:set nu et ts=4 sw=4:
